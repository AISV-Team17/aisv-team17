# SCN-005: 검색 인덱스 손상

| 항목 | 값 |
| --- | --- |
| **ID** | `SCN-005` |
| **변경 유형** | `INDEX_CORRUPTION` |
| **발현 유형** | `HALLUCINATION` |
| **난이도** | EASY |
| **라벨** | 1 |

---

#### [모델 파트] 사고 대응 근거 ✅

**실제 사고 유형 참조**

- 근거: R1 (중간), R2-② (보조) — R1의 인프라 결함이 모델에 가야 할 신호를 왜곡했고, R2-②의 캐싱 결함으로 이전 추론이 조용히 빠진 사례와 같이 "오류 없이 발생하는 품질 저하"를 모사한다.
- 설명: 근거 문서 일부가 인덱스에서 빠져도 서비스는 아무 오류를 내지 않는다. 모델은 남은 문서로 답을 만들거나, 근거가 없으면 지어낸다.
- 대응 강도: 중간

**탐지 포인트**

- 근거가 사라진 질문에서 환각이 직접 늘어나므로 1단계 탐지 모델이 가장 잘 잡을 시나리오.
- `app.retrieval.doc_count < top_k` 불일치 자체도 결정적 신호다. 에이전트가 근거로 활용할 수 있도록 텔레메트리에 기록한다.

#### [모델 파트] 정답 라벨 정의 ✅

| 판정 | 기준 |
| --- | --- |
| POSITIVE (1) | `index_drop_ratio: 0 → 0.3` 변경이 원인 |
| NEGATIVE (0) | 주입 전 구간 |

**경계 케이스**: 제외된 문서와 무관한 질문은 영향을 받지 않는다. **영향받은 질문의 비율을 함께 보고**한다.

#### [모델 파트] 기대 신호 ✅

| 판정기 | 예상 반응 | 비고 |
| --- | --- | --- |
| 고정 임계값 | 중간 | 일부 질문군에 집중, 평균에 묻힐 수 있음 |
| KS 검정 | 중간 | 분포 변화 |
| 임베딩 거리 | 약함 | 평균적 성향 변화 작을 수 있음 |

---

#### [서비스 파트] YAML ✅

```yaml
scenario_id: SCN-005
title: "검색 인덱스 손상"
change_type: INDEX_CORRUPTION
expression_type: HALLUCINATION
difficulty: EASY
label: 1
injected: true

baseline:
  prompt: qa-v1.2
  model: claude-small-gen
  top_k: 5
  chunk_size: 512
  index_drop_ratio: 0.0

traffic:
  question_set: msmarco_eval_v1
  rps: 0.5
  duration_min: 90

seed: 46

events:
  - at_minute: 15
    change: { log_level: DEBUG }
    is_decoy: true
    note: "디코이(D-LOGLEVEL)"
  - at_minute: 25
    change: { routing_sample_rate: 0.1 }
    is_decoy: true
    note: "디코이(D-ROUTING). 디코이 2건으로 후보를 늘린다"
  - at_minute: 30
    change: { index_drop_ratio: 0.3 }
    is_decoy: false
    note: "정답. 근거 문서의 30%를 검색 대상에서 제외"

expected:
  detectable_by: [fixed_threshold, ks_test, embedding_distance]
  expected_delay_min: 5
  quality_drop: LARGE

metadata:
  source: "RAG 문서 동기화 실패, R1·R2-② 참조"
  created_by: "AI-SVC"
  created_at: "2026-10-25T00:00:00Z"
```

#### [서비스 파트] 디코이 구성 ✅

- 디코이 수: **2건** (`D-LOGLEVEL`, `D-ROUTING`)
- 배치: 정답 주입 15분 전, 5분 전
- 이 시나리오는 하락 폭이 커서 원인 지목이 쉬워질 위험이 있어 디코이를 2건 넣어 난이도를 맞춘다.

#### [서비스 파트] 실행 주의 ✅

- `index_drop_ratio`는 인덱스를 실제로 손상시키지 않고 **검색 결과를 시드 기반으로 필터링하는 방식**으로 구현한다. 회차마다 재인덱싱하지 않아도 된다.
- 제외할 문서는 시드 기반으로 고정 선택한다. 회차마다 다른 문서가 빠지면 재현성이 깨진다.
- `index_drop_ratio` → `version_changes` 기록 방식은 미결정 사항 참조.

---

end.