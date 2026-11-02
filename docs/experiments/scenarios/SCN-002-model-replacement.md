# SCN-002: 생성 모델 교체

| 항목 | 값 |
| --- | --- |
| **ID** | `SCN-002` |
| **변경 유형** | `MODEL_SWAP` |
| **발현 유형** | `FACTUAL_ERROR` |
| **난이도** | EASY |
| **라벨** | 1 |

---

#### [모델 파트] 사고 대응 근거 ✅

**실제 사고 유형 참조**

- 근거: R3 (강함) — GPT-4o 업데이트가 오프라인 평가를 통과했지만 운영에서 아첨 경향이 나타난 사례. 모델 업데이트가 기존 평가로 잡히지 않는 새로운 품질 저하를 일으키는 패턴.
- 설명: 운영 중 모델을 바꾸거나 제공자 측에서 라우팅이 달라져 다른 모델이 응답하는 상황을 모사한다. telemetry의 `gen_ai.response.model`을 따로 기록하는 이유와 직접 연결된다.
- 대응 강도: 강함

**탐지 포인트**

- 성능이 낮은 모델로 바뀌면 사실 오류와 근거 불일치가 함께 늘어 세 판정기 모두 탐지할 것으로 예상.
- 주요 관찰 포인트는 **탐지 지연**이다. 변화가 크면 5분 창 하나로 잡히는지가 관심사다.

#### [모델 파트] 정답 라벨 정의 ✅

| 판정 | 기준 |
| --- | --- |
| POSITIVE (1) | `model` 변경이 원인 |
| NEGATIVE (0) | 주입 전 구간 |

**경계 케이스**: 교체 모델의 응답 지연이 크게 달라 타임아웃이 늘면 `status='ERROR'` 증가 → 품질 저하가 아니라 가용성 문제이므로 **분리해 보고**한다.

#### [모델 파트] 기대 신호 ✅

| 판정기 | 예상 반응 | 비고 |
| --- | --- | --- |
| 고정 임계값 | 강함 | 1단계 점수 상승 |
| KS 검정 | 강함 | 분포 이동 |
| 임베딩 거리 | 강함 | 응답 성향 변화 |

---

#### [서비스 파트] YAML ✅

```yaml
scenario_id: SCN-002
title: "생성 모델 교체"
change_type: MODEL_SWAP
expression_type: FACTUAL_ERROR
difficulty: EASY
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

seed: 43

events:
  - at_minute: 25
    change: { routing_threshold: 0.55 }
    is_decoy: true
    note: "디코이(D-ROUTING). 검사 비용만 변하고 생성 품질은 변하지 않는다"
  - at_minute: 30
    change: { model: claude-small-gen-prev }
    is_decoy: false
    note: "정답. 이전 세대 소형 모델로 교체"

expected:
  detectable_by: [fixed_threshold, ks_test, embedding_distance]
  expected_delay_min: 5
  quality_drop: LARGE

metadata:
  source: "Anthropic 2025-09-17 사후 분석 — 인프라 결함(R1), OpenAI 2025 — 모델 업데이트(R3)"
  created_by: "AI-SVC"
  created_at: "2026-10-25T00:00:00Z"
```

#### [서비스 파트] 디코이 구성 ✅

- 디코이 수: 1건 (`D-ROUTING`)
- 배치: 정답 주입 5분 전
- `source='console'`로 기록되어 출처가 다른 변경이 섞이는 것이 이 디코이의 의도다.

#### [서비스 파트] 실행 주의 ✅

- **교체 모델을 채점 모델과 같은 것으로 쓰지 않는다.** 자기 선호 편향 통제 근거가 무너진다(ADR-015).
- `configs/pricing.yaml`에 교체 모델이 등록되어 있어야 한다. 없으면 `PricingNotFoundError`(interfaces.md 6장).

---

end.