# RunBook 메뉴얼

> **최종 수정일**: 2026-10-31 
> **담당**: AI-SVC

---

## 목적
이 문서는 배포·롤백·장애 대응 절차를 기술한다. 실제 상황에서는 순서를 바꾸지 말고 이 절차를 따른다.

---

## 1. 일반 배포

### 1.1 자동 배포 (정상 케이스)

1. `develop` → `main` PR 생성 후 Squash merge
2. GitHub Actions `cd.yml` 자동 트리거
3. backend·frontend 이미지 빌드 + GHCR 푸시 (SHA 태그, ADR-019)
4. GitHub Secrets → 서버 `.env` SCP 주입 (ADR-021)
5. SSH Deploy Key로 서버 접속 → `docker compose pull && docker compose up -d` (ADR-020)
6. `alembic upgrade head` 자동 실행
7. Grafana 대시보드에서 컨테이너 상태 및 스팬 수신량 확인

**예상 소요 시간:** 이미지 빌드 3~5분 + 배포 1분

### 1.2 수동 배포 (긴급 또는 CD 실패 시)

```bash
ssh -i ~/.ssh/aisv_team17 root@<VULTR_SERVER_IP>
cd /opt/aisv-team17

# GHCR 로그인
echo "${GHCR_TOKEN}" | docker login ghcr.io -u <GITHUB_USERNAME> --password-stdin

# 최신 이미지 Pull
docker compose pull

# 서비스 재배포 (기존 컨테이너 교체)
docker compose up -d --remove-orphans

# DB 마이그레이션
docker compose exec -T console alembic upgrade head

# 배포 확인
docker compose ps
docker compose logs -f --tail=50
```

### 1.3 배포 후 확인 체크리스트

- [ ]  `docker compose ps` — 모든 컨테이너 `Up` 상태
- [ ]  `docker compose logs -f worker` — "Polling for tasks..." 로그 정상 출력
- [ ]  Grafana (`http://<IP>:3001`) — 스팬 수신량 0이 아닌지 확인
- [ ]  콘솔 UI (`http://<IP>:3000`) — 로그인 및 대시보드 로딩 확인
- [ ]  Prometheus (`http://<IP>:9090`) — `otel-collector` 타겟 UP 상태

---

## 2. 롤백

### 2.1 이전 이미지로 롤백

```bash
ssh -i ~/.ssh/aisv_team17 root@<VULTR_SERVER_IP>
cd /opt/aisv-team17

# SHA 태그로 이전 버전 지정
# 이전 SHA는 GitHub Actions 실행 이력 또는 GHCR 태그 목록에서 확인
export IMAGE_TAG=sha-<이전-커밋-SHA>

# docker-compose.yml의 image 태그를 환경변수로 오버라이드
IMAGE_TAG=${IMAGE_TAG} docker compose up -d

# 확인
docker compose ps
```

### 2.2 Git revert 후 재배포

```bash
# 로컬에서 문제 커밋을 revert (공유 브랜치는 reset 금지 — CONTRIBUTING.md §8.5)
git revert <commit-hash>
git push origin main

# → CD 파이프라인 자동 실행으로 revert된 상태가 배포됨
```

### 2.3 DB 스키마 롤백 (Alembic)

```bash
# 현재 revision 확인
docker compose exec console alembic current

# 전체 이력 확인
docker compose exec console alembic history

# 마지막 1단계 되돌리기
docker compose exec console alembic downgrade -1

# 특정 revision으로 되돌리기
docker compose exec console alembic downgrade <revision>
```

> ⚠️ 스키마 롤백은 데이터 손실이 발생할 수 있다. 반드시 DB 백업 후 진행한다.
> 

---

## 3. 장애 대응

### 3.1 서비스 전체 다운 (컨테이너 재시작)

```bash
# 모든 컨테이너 재시작
docker compose restart

# 특정 서비스만
docker compose restart worker
docker compose restart ingest
```

**원인 조사:**

```bash
docker compose logs --tail=200 <서비스명>
docker inspect $(docker compose ps -q <서비스명>)
```

### 3.2 DB 연결 불가

**증상:** `asyncpg.exceptions.ConnectionDoesNotExistError` 또는 연결 타임아웃

```bash
# PostgreSQL 컨테이너 상태 확인
docker compose ps postgres
docker compose logs postgres

# 재시작
docker compose restart postgres

# 연결 직접 테스트
docker compose exec postgres psql -U aisv aisv -c "\l"
```

**커넥션 풀 고갈 시:**

```bash
docker compose exec postgres psql -U aisv aisv -c "
  SELECT count(*), state
  FROM pg_stat_activity
  WHERE datname = 'aisv'
  GROUP BY state;
"

# 유휴 연결 강제 종료
docker compose exec postgres psql -U aisv aisv -c "
  SELECT pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE state = 'idle'
    AND datname = 'aisv'
    AND pid <> pg_backend_pid();
"
```

### 3.3 OOM (Out of Memory) 컨테이너 종료

**증상:** `docker compose ps`에서 컨테이너 상태 `Exit 137`

```bash
# 원인 확인
docker inspect <container_id> | grep -A5 OOMKilled

# 메모리 사용량 확인
docker stats --no-stream

# Swap 상태 확인
free -h
swapon --show
```

**대응:**

1. `docker-compose.yml`에서 해당 서비스의 `mem_limit` 상향 조정
2. Swap 공간 확장 (`vultr.md §5.6` 참고)
3. worker의 경우 `WORKER_BATCH_SIZE`·`WORKER_CONCURRENCY` 축소 (`.env`)

### 3.4 Worker 검사 작업 적체

**증상:** Grafana에서 `PENDING` 작업이 계속 누적

```bash
# 적체 상태 확인 (eval_jobs는 PostgreSQL SKIP LOCKED 기반 큐, ADR-004)
docker compose exec postgres psql -U aisv aisv -c "
  SELECT status, COUNT(*), MIN(created_at), MAX(created_at)
  FROM eval_jobs
  GROUP BY status
  ORDER BY status;
"

# Worker 로그 확인
docker compose logs -f worker

# Worker 재시작
docker compose restart worker
```

**stale lock 수동 회수 (자동 회수가 안 될 때):**

```bash
# 5분 이상 RUNNING 상태인 작업 확인 (policies.md §2.1: stale lock TTL 5분)
docker compose exec postgres psql -U aisv aisv -c "
  SELECT id, trace_pk, locked_at, locked_by, attempts
  FROM eval_jobs
  WHERE status = 'RUNNING'
    AND locked_at < NOW() - INTERVAL '5 minutes';
"

# 수동으로 PENDING 복귀
docker compose exec postgres psql -U aisv aisv -c "
  UPDATE eval_jobs
  SET status = 'PENDING',
      locked_at = NULL,
      locked_by = NULL,
      available_at = NOW(),
      attempts = attempts + 1
  WHERE status = 'RUNNING'
    AND locked_at < NOW() - INTERVAL '5 minutes';
"
```

**FAILED 작업 강제 재처리:**

```bash
docker compose exec postgres psql -U aisv aisv -c "
  UPDATE eval_jobs
  SET status = 'PENDING',
      attempts = 0,
      available_at = NOW(),
      last_error = NULL
  WHERE status = 'FAILED';
"
```

### 3.5 디스크 공간 부족

```bash
# 확인
df -h
docker system df

# 안전 정리 (실행 중 이미지는 보호됨)
docker image prune -f
docker builder prune -f

# 로그 파일 정리
find /var/lib/docker/containers -name "*.log" -exec truncate -s 0 {} \;
```

### 3.6 ONNX 모델 로드 실패

```bash
# Worker 로그 확인
docker compose logs worker | grep -i "error\|onnx\|model"

# 모델 파일 존재 여부 확인
docker compose exec worker ls -lh /app/models

# SP2: LettuceDetect 기준선 모델 재다운로드 (ADR-027)
docker compose exec worker python -c "
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='KRLabsOrg/lettucedect-base-modernbert-en-v1',
    local_dir='/app/models',
    force_download=True
)
print('완료')
"

docker compose restart worker
```

### 3.7 OTel 스팬 수신 중단

**증상:** Grafana에서 스팬 수신량 0, 또는 ingest에 새 traces가 쌓이지 않음

```bash
# Collector 상태 확인
docker compose logs otel-collector | grep -E "Everything is ready|error"

# Collector가 Ingest API로 전송 중인지 확인
docker compose logs otel-collector | grep "otlphttp/ingest"

# Ingest API 수신 확인
docker compose logs ingest | tail -30

# 최근 1분간 수집된 traces 수 확인
docker compose exec postgres psql -U aisv aisv -c "
  SELECT COUNT(*) FROM traces
  WHERE created_at > NOW() - INTERVAL '1 minute';
"
```

---

## 4. 서비스별 점검 항목

### 4.1 RAG 서비스

```bash
# Health check
curl http://localhost:8000/health

# 최근 traces 수신 확인
docker compose exec postgres psql -U aisv aisv -c "
  SELECT COUNT(*), MAX(started_at)
  FROM traces
  WHERE started_at > NOW() - INTERVAL '5 minutes';
"
```

### 4.2 Worker 정상 동작 확인

```bash
# 작업 처리 로그 (최근)
docker compose logs worker | grep -E "processing|completed|error" | tail -20

# 처리 통계 (최근 1시간)
docker compose exec postgres psql -U aisv aisv -c "
  SELECT status, COUNT(*), AVG(EXTRACT(EPOCH FROM (updated_at - created_at))) AS avg_sec
  FROM eval_jobs
  WHERE created_at > NOW() - INTERVAL '1 hour'
  GROUP BY status;
"

# 2단 구조 라우팅 분포 확인
docker compose exec postgres psql -U aisv aisv -c "
  SELECT routed_reason, stage, COUNT(*)
  FROM evaluations
  WHERE created_at > NOW() - INTERVAL '1 hour'
  GROUP BY routed_reason, stage
  ORDER BY stage, routed_reason;
"
```

### 4.3 OTel 파이프라인 점검

```bash
# Collector 수신 및 전송 확인
docker compose logs otel-collector | grep -E "received|exported|error" | tail -20

# traces·spans 저장 확인
docker compose exec postgres psql -U aisv aisv -c "
  SELECT
    (SELECT COUNT(*) FROM traces WHERE created_at > NOW() - INTERVAL '5 minutes') AS traces_5m,
    (SELECT COUNT(*) FROM spans  WHERE created_at > NOW() - INTERVAL '5 minutes') AS spans_5m;
"
```

### 4.4 Drift Monitor 점검

```bash
# 최근 quality_windows 집계 확인
docker compose exec postgres psql -U aisv aisv -c "
  SELECT metric, window_start, mean_score, is_drift, detector_name
  FROM quality_windows
  ORDER BY window_start DESC
  LIMIT 10;
"

# 미해결 인시던트 확인
docker compose exec postgres psql -U aisv aisv -c "
  SELECT id, metric, detected_at, status
  FROM incidents
  WHERE status IN ('OPEN', 'INVESTIGATING')
  ORDER BY detected_at DESC;
"
```

---

## 5. 긴급 알림 채널

| 상황 | 알림 경로 |
| --- | --- |
| 드리프트 감지 (자동) | Drift Monitor → Slack `#quality` (ADR-011) |
| 운영 이상 감지 (자동) | Drift Monitor → Slack `#ops` (ADR-011) |
| 수동 이상 발견 | 팀 Slack `#incident` 채널에 직접 공유 |

**인시던트 보고 양식 (Slack에 붙여 넣기):**

```
🚨 인시던트 보고
- 발생 시각:
- 증상:
- 영향 범위:
- 현재 상태: [조사 중 / 대응 중 / 해결됨]
- 조치 내용:
- 재발 방지:
```

---

## 6. 서버 Destroy 시점 규칙

비용 최소화를 위해 아래 기준에 따라 서버를 Destroy한다. (ADR-014 기간 가동 전략)

| 상황 | 조치 |
| --- | --- |
| 개발 작업이 없는 날 | Destroy → 다음 작업 전 재생성 |
| 주말 (비개발) | Destroy |
| 평가 제출 후 | Destroy (백업 필수) |
| 프로젝트 종료 | Destroy (최종 백업 후) |

**Destroy 전 필수 체크리스트:**

- [ ]  DB 백업 완료

```bash
# 서버에서 실행
docker compose exec postgres pg_dump -U aisv aisv > backup_$(date +%Y%m%d).sql

# 로컬로 복사 (로컬 Git Bash에서 실행)
scp -i ~/.ssh/aisv_team17 root@<SERVER_IP>:/opt/aisv-team17/backup_*.sql ./
```

- [ ]  백업 파일 로컬 보관 확인
- [ ]  팀 Slack에 Destroy 공지

**재생성 후 빠른 복구:**

→ `docs/ops/vultr.md` §5~§6을 순서대로 실행한다.

---

## 메모

- 이 런북은 실제 장애 대응 중에도 읽을 수 있도록 간결하게 유지한다.
- 절차가 변경되면 반드시 이 문서를 함께 업데이트한다.
- `docker-compose.yml` 변경 시 CODEOWNERS 규칙에 따라 AI-SVC 승인 필수.

---

end.