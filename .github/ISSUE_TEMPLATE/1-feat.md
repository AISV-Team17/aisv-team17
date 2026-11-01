---
name: 기능 구현
about: 새로운 기능 구현 작업을 등록합니다.
title: "feat(<scope>): "
labels: feat
assignees: ""
---

<!--
[AI 작성 안내]

이 템플릿은 기능 구현 이슈용이다. 아래 규칙을 지켜 작성한다.

제목 형식: feat(<scope>): <한 줄 요약>
- scope는 CONTRIBUTING.md 1.3절 표에서만 골라야 한다.
- 예: feat(sdk): RAG 서비스에 OTel GenAI 스팬 데코레이터 추가
- 예: feat(worker): ONNX INT8 1단계 전수 탐지 파이프라인 구현
- 예: feat(ingest): OTel Collector → DB 저장 + eval_job 등록 API 구현
- 예: feat(drift): 5분 창 단위 품질 집계·드리프트 판정 구현
- 예: feat(agent): DB 조회 전용 MCP 도구 추가
- 예: feat(evaluate): RAGTruth 기반 채점자 신뢰도 평가 스크립트 구현

각 섹션을 채울 때 기준:
  - "작업 목적": 누가 무엇을 할 수 있도록 무엇을 구현하는지 한두 문장
  - "구현 내용": 이번 이슈 범위에서 완료해야 할 항목만. 미확정 사항을 확정처럼 쓰지 않는다
  - "기술 결정 사항": 실제로 선택지가 2개 이상이었고 나중에 되돌리기 비싼 결정만 기록한다
  - 선택 섹션에 내용이 없으면 섹션 전체를 삭제한다
  - 체크박스 문구는 바꾸지 않는다
  - 코드·명령어·파일 경로·함수명·테이블명은 반드시 `코드블록`으로 감싼다

게시 전 삭제: 모든 HTML 주석 블록 전체을 삭제한다.
-->

## 🎯 작업 목적

<!--
작성 형식: [담당자 또는 시스템]이 [어떤 목적]을 달성할 수 있도록 [무엇]을 구현합니다.

이 프로젝트 맥락 예시:
- 계측 SDK가 RAG 서비스의 모든 생성 요청에 OTel GenAI 스팬을 자동으로 붙일 수 있도록 `@trace_generation` 데코레이터를 구현합니다.
- `Eval Worker`가 `PostgreSQL` 작업 큐에서 `SKIP LOCKED`로 작업을 선점해 1단계 ONNX 전수 탐지를 수행할 수 있도록 워커 루프를 구현합니다.
- 운영자가 관제 콘솔에서 인시던트 타임라인과 에이전트 조사 과정을 확인할 수 있도록 인시던트 상세 API와 화면을 구현합니다.
-->

- 여기에 작성

## ✅ 구현 내용

<!--
이번 이슈 범위에서 완료할 항목만 나열한다. 구현 결과는 PR에 작성한다.
각 항목은 완료 여부를 독립적으로 판정할 수 있는 단위로 쓴다.

작성 형식:
- [대상]에 [기능]을 추가합니다.
- [대상]의 [기존 동작]을 [변경할 동작]으로 수정합니다.

이 프로젝트 맥락 예시:
SDK 계측:
- `backend/src/sdk/decorator.py`에 `@trace_generation` 데코레이터를 구현합니다.
- 스팬에 `gen_ai.prompt.version`, `gen_ai.model.version`, `gen_ai.retrieval.version`
  속성을 포함시킵니다 (`telemetry.md` §2 기준).
Worker:
- `backend/src/worker/main.py`에 `SKIP LOCKED` 폴링 루프를 구현합니다.
- 1단계 ONNX 추론 결과(`hallucination_score`)와 `routed_reason`을 DB에 저장합니다.
- `eval_jobs` 상태가 `PENDING → RUNNING → DONE / FAILED`로 전이됩니다.
API:
- `POST /api/v1/injections` 엔드포인트를 추가합니다
  (req: `scenarioId` / res: `runId`, `status`).
- 응답은 `api.md` §1 스키마를 기준으로 구현합니다.
LLM·모델:
- 평가셋 `ragtruth_v1.jsonl`(N문항) 기준 F1 ≥ 0.XX를 달성합니다.
- ONNX INT8 변환 후 CPU p95 추론 지연 ≤ XXms를 확인합니다.
MCP 도구:
- `query_traces(filters: dict, limit: int = 20)` 도구를 추가합니다.
- DB 조회 전용으로만 동작하며 쓰기 권한을 주지 않습니다.
-->

- 구현 항목 1
- 구현 항목 2

## 📐 기술 결정 사항 (선택)

<!--
구현 전에 선택이 필요한 기술적 판단을 정리한다.
실제로 대안이 2개 이상 있었고, 나중에 바꾸면 여러 모듈 수정이 필요한 결정만 기록한다.
그 이하는 코드 주석이나 PR 본문으로 충분하다.
결정이 ADR로 남길 만큼 크다면 "docs/adr/ 에 ADR 추가" 항목을 구현 내용에 함께 넣는다.

이 프로젝트 맥락 예시:
| 항목 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 탐지 임계값 기준 | 고정값 `0.5` / `τ` 파라미터화 | `τ` 파라미터화 | 라우팅 정책 화면에서 실험용으로 조정해야 함 |
| 임베딩 모델 | `text-embedding-3-small` / `all-MiniLM` | `all-MiniLM` | CPU 추론 가능, 별도 API 비용 없음 |
| 드리프트 탐지기 | 점수 평균 / KL 발산 / MMD | 3종 모두 | 방식별 비교가 과제 C 실험 목표이므로 |
-->

| 항목 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| (항목) | 선택지A / 선택지B | 결정 | 이유 |

## 🔗 선행 작업 (선택)

<!--
이 이슈를 시작하기 전에 완료되어야 하는 다른 이슈를 적는다.
선행 작업이 없으면 이 섹션을 삭제한다.

이 프로젝트에서 자주 나타나는 의존 관계:
- `interfaces/` 계약이 확정되어야 `worker` ↔ `model` 구현을 병렬로 시작할 수 있다.
- SDK가 스팬을 붙이기 전에는 `Ingest API` 연동 테스트를 할 수 없다.
- ONNX 모델이 HuggingFace Hub에 업로드되어야 `worker`가 다운로드해 쓸 수 있다.
-->

- Depends on #

## 🧭 우선순위

<!-- 하나만 체크한다. 체크 문구는 바꾸지 않는다. -->

- [ ] 🌋 Urgent — 지금 처리 안 하면 다른 작업이 막힘
- [ ] 🏔 High — MVP 핵심 기능 또는 일정에 직접 영향
- [ ] 🏕 Medium — 일반 기능 구현, 개선, 예외 처리
- [ ] 🏝 Low — 후순위 정리, 문서, 단순 개선

## 📏 예상 작업 규모

<!-- 하나만 체크한다. Large라면 쪼갤 수 없는 이유를 참고 자료에 한 줄 남긴다. -->

- [ ] 🦑 Large — 2일 이상
- [ ] 🐂 Medium — 하루 내외
- [ ] 🐇 Small — 반나절 이내
- [ ] 🦔 Tiny — 30분 이내

## 📅 완료 기한

yyyy-mm-dd (요일)

## 📎 참고 자료 (선택)

<!--
관련 문서 링크, ADR 번호, API 명세 섹션을 적는다.
없으면 이 섹션을 삭제한다.

이 프로젝트에서 자주 참조하는 문서:
- `docs/specs/api.md` §N — API 엔드포인트 스키마
- `docs/specs/interfaces.md` — Detector·DriftDetector 계약
- `docs/specs/telemetry.md` §N — OTel 스팬 속성 기준
- `docs/specs/erd.md` §N — DB 테이블 스키마
- `docs/adr/NNNN-*.md` — 관련 ADR
- `docs/experiments/protocol.md` §N — 실험 과제 정의
-->

- 여기에 작성