# ADR-014: 인프라는 Vultr vhp-4c-8gb 단일 서버 + Docker Compose로 하고 필요 기간만 가동한다

| 항목 | 값 |
| --- | --- |
| **상태** | 수락됨 |
| **날짜** | 2026-10-31 |
| **작성자** | `AI-SVC` |
| **검토자** | `AI-MDL` |

---

## 컨텍스트

스택에는 RAG 서비스, Collector, Ingest API, PostgreSQL+pgvector, 검사 워커(모델 적재), Drift Monitor, 에이전트·MCP, Console API, Next.js 콘솔, Prometheus, Grafana가 포함된다. 메모리 합계가 4GiB를 넘어 소형 인스턴스로는 부족하다. 예산은 학생 팀 수준이며, 학교 지원은 선불 결제 가능한 클라우드만 허용된다. AWS는 기업용 카드 선불 결제를 지원하지 않아 제외됐고, GCP Education Credit은 승인에 최대 15 영업일이 소요되어 SP2 일정(11/18)에 맞지 않는다.

## 결정 근거

- 스택 전체의 메모리 요구량.
- 비용 통제 가능성.
- 8주 일정 안에서의 운영 복잡도.
- 확장 경로를 설명할 수 있는지.

## 고려한 옵션들

- 옵션 1: Vultr vc2-4c-8gb (4vCPU, 8GB, HDD) 기간 가동
- 옵션 2: Vultr vhp-4c-8gb (4vCPU, 8GB, NVMe AMD) 기간 가동
- 옵션 3: k3s 또는 Vultr Kubernetes Engine 다중 노드 구성

## 결정

옵션 2 **vhp-4c-8gb, 필요 기간만 가동**을 선택한다. AMD EPYC 기반 NVMe 플랜으로, 멀티스레드 벤치마크(sysbench)에서 동급 HDD 플랜(vc2-4c-8gb) 대비 약 2배 처리량을 기록한다. ONNX 추론 + 다중 컨테이너 동시 기동 환경에서 유리하다. 선불 크레딧($40) 결제를 지원하며 Seoul(icn) 리전이 있어 팀 학교 지원 조건을 충족한다.

## 결과

**긍정적**

- 모든 컨테이너가 한 서버에 올라가 네트워크 구성과 배포 경로가 단순하다.
- 가동 시간 기준으로 비용을 끊을 수 있어 예산 리스크가 작다.
- `terraform destroy`로 실험 종료 후 자원을 완전히 정리할 수 있다.

**부정적**

- 수평 확장과 무중단 배포가 불가능하다.
- 서버를 꺼 두는 동안에는 데모·수집이 불가하므로 일정 조율이 필요하다.
- 단일 장애점이다.

**후속 작업**

- 컨테이너별 `mem_limit` 배분표 작성 (메모리 리스크 대응)
- Terraform Vultr provider로 VM·방화벽 코드화 (T1-16)
- 서버 기동/정지 절차를 런북에 기록

---

## 옵션별 장단점

### 옵션 1 — vc2-4c-8gb (HDD)

- 장점: vhp보다 시간당 $4 저렴하다.
- 단점: HDD 기반이라 I/O 집약 작업(PostgreSQL, ONNX 모델 로드)에서 느리다.

### 옵션 2 — vhp-4c-8gb AMD NVMe (채택)

- 장점: NVMe로 I/O 성능이 높고, 멀티스레드 처리량이 옵션 1 대비 약 2배다.
- 단점: vc2 대비 시간당 비용이 소폭 높다.

### 옵션 3 — k3s / VKE

- 장점: 확장성과 배포 안정성이 높다.
- 단점: 학습·운영 비용이 8주 일정에 비해 과도하다.

## 연관 ADR

- Related to ADR-004, ADR-013 (컨테이너 수 절감 근거)
- Related to ADR-018, ADR-019, ADR-020 (배포 파이프라인)

## 참조

- 기획서 6.4 리스크, 6.3 예산
- Vultr Seoul icn 플랜 비교 ([roundfigure.tistory.com/147](http://roundfigure.tistory.com/147))

---

end.