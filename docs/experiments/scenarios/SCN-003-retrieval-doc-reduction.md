# SCN-003: 검색 문서 수 축소

| 항목 | 값 |
| --- | --- |
| **ID** | `SCN-003` |
| **변경 유형** | `RETRIEVAL_NARROW` |
| **발현 유형** | `OMISSION` |
| **난이도** | MEDIUM |
| **라벨** | 1 |

---

#### [모델 파트] 사고 대응 근거 ✅

**실제 사고 유형 참조**

- 근거: R2-① (중간) — 지연을 줄이려고 기본 추론 강도를 낮췄다가 품질이 떨어진 사례와 동기가 같다(지연 절감 목적의 기본값 하향). 바뀐 것이 추론 강도가 아니라 검색 개수라는 점에서 직접 동일하진 않다.
- 설명: 비용 절감을 위해 검색 문서 수를 줄이는 것은 RAG 운영에서 흔한 조정이다. 근거 문서가 줄면 모델이 부족한 근거로 답을 만들게 된다.
- 대응 강도: 중간

**탐지 포인트**

- 질문에 따라 영향이 크게 갈린다. top-1 문서만으로 답할 수 있는 질문은 영향이 없고, 여러 문서를 종합해야 하는 질문만 나빠진다.
- **평균보다 분산이 먼저 움직일** 것으로 예상. 고정 임계값보다 KS 검정이 유리할 것으로 보인다. 과제 C의 핵심 비교 사례다.

#### [모델 파트] 정답 라벨 정의 ✅

| 판정 | 기준 |
| --- | --- |
| POSITIVE (1) | `top_k: 5 → 2` 변경이 원인 |
| NEGATIVE (0) | 주입 전 구간 |

**경계 케이스**: `app.retrieval.doc_count`가 변경 직후에도 5로 남아 있으면 주입이 적용되지 않은 것 → 회차를 `ABORTED` 처리.

#### [모델 파트] 기대 신호 ✅

| 판정기 | 예상 반응 | 비고 |
| --- | --- | --- |
| 고정 임계값 | 약함 | 평균 하락 완만 |
| KS 검정 | 강함 | 분산 증가가 주된 신호 |
| 임베딩 거리 | 중간 | 일부 질문군에서만 변화 |

---

#### [서비스 파트] YAML ✅

```yaml
scenario_id: SCN-003
title: "검색 문서 수 축소"
change_type: RETRIEVAL_NARROW
expression_type: OMISSION
difficulty: MEDIUM
label: 1
injected: true

baseline:
  prompt: qa-v1.2
  model: claude-small-gen
  top_k: 5
  chunk_size: 512

traffic:
  question_set: msmarco_eval_v1
  rps: 0.5
  duration_min: 90

seed: 44

events:
  - at_minute: 18
    change: { notify_cooldown_min: 45 }
    is_decoy: true
    note: "디코이(D-NOTIFY). 알림 빈도만 변경"
  - at_minute: 30
    change: { top_k: 2 }
    is_decoy: false
    note: "정답. 근거 문서 수를 5에서 2로 축소"

expected:
  detectable_by: [ks_test]
  expected_delay_min: 15
  quality_drop: MODERATE

metadata:
  source: "RAG 운영의 비용 절감형 설정 하향, R2-① 참조"
  created_by: "AI-SVC"
  created_at: "2026-10-25T00:00:00Z"
```

#### [서비스 파트] 디코이 구성 ✅

- 디코이 수: 1건 (`D-NOTIFY`)
- 배치: 정답 주입 12분 전

#### [서비스 파트] 실행 주의 ✅

- `top_k`는 런타임에 즉시 반영된다(재인덱싱 불필요). **탐지 지연 측정의 기준 사례**로 쓰기 좋다.
- 검증: 주입 직후 트레이스의 `app.retrieval.doc_count`가 2로 바뀌는지 확인(telemetry 3.3).

---

end.