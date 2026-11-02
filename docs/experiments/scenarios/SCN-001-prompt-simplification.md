# SCN-001: 프롬프트 간결화 변경

| 항목 | 값 |
| --- | --- |
| **ID** | `SCN-001` |
| **변경 유형** | `PROMPT_CHANGE` |
| **발현 유형** | `OMISSION` |
| **난이도** | MEDIUM |
| **라벨** | 1 |

---

#### [모델 파트] 사고 대응 근거 ✅

**실제 사고 유형 참조**

- 근거: R2-③ (강함) — 장황함을 줄이려는 시스템 프롬프트 변경이 코딩 품질을 3% 떨어뜨린 사례. 기획서 1.1의 핵심 근거 사례다.
- 설명: 모델 가중치는 그대로인데 지시만 바뀌어 품질이 떨어지는 패턴. 기획서의 "원인은 변경이다"에 가장 직접적으로 대응하며 SP2 데모의 시연 대상이다.
- 대응 강도: 강함

**탐지 포인트**

- 응답이 짧아지면서 근거 인용이 빠진다. 1단계 탐지 모델은 "근거 없는 생성"을 보는데 **누락은 생성이 아니다.** 환각 점수가 크게 오르지 않을 수 있다.
- 품질 점수(2단계 채점)와 임베딩 분포는 움직일 것으로 예상. 세 판정기의 결과가 갈릴 가능성이 높아 비교 가치가 높다.

#### [모델 파트] 정답 라벨 정의 ✅

| 판정 | 기준 |
| --- | --- |
| POSITIVE (1) | `prompt: qa-v1.2 → qa-v1.3-terse` 변경이 원인. 이 `version_change_id`를 지목하면 정답 |
| NEGATIVE (0) | 주입 전 30분 구간 |

**경계 케이스**

- 저하가 주입 시각(30분)보다 앞서 시작된 것으로 추정되면 → 해당 회차 제외 후 원인 조사.
- 에이전트가 디코이(`D-NOOP`)를 1순위로 지목하면 → 오답. Top-3에 정답이 있으면 Top-3 정확도에만 반영.

#### [모델 파트] 기대 신호 ✅

| 판정기 | 예상 반응 | 비고 |
| --- | --- | --- |
| 고정 임계값 | 약함 | 환각 점수 변화 작을 수 있음 |
| KS 검정 | 강함 | 분포 변화 |
| 임베딩 거리 | 강함 | 응답 성향·길이 변화 |

---

#### [서비스 파트] YAML ✅

```yaml
scenario_id: SCN-001
title: "프롬프트 간결화 변경"
change_type: PROMPT_CHANGE
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

seed: 42

events:
  - at_minute: 20
    change: { chunk_size: 512 }      # 주석만 바꾼 동일 설정 재배포로 해시 변경
    is_decoy: true
    note: "디코이(D-NOOP). 정답 주입 직전에 무관한 변경을 섞어 규칙 기반 기준선을 무력화한다"
  - at_minute: 30
    change: { prompt: qa-v1.3-terse }
    is_decoy: false
    note: "정답. 간결하게 답하라는 지시를 추가해 근거 인용이 빠지게 한다"

expected:
  detectable_by: [ks_test, embedding_distance]
  expected_delay_min: 10
  quality_drop: MODERATE

metadata:
  source: "Anthropic 2026-04-23 사후 분석 — 시스템 프롬프트 변경(R2-③)"
  created_by: "AI-SVC"
  created_at: "2026-10-25T00:00:00Z"
```

#### [서비스 파트] 디코이 구성 ✅

- 디코이 수: 1건 (`D-NOOP`)
- 배치: 정답 주입 10분 전
- 주의: 동일 내용 재적용은 해시가 같아 변경 이력이 남지 않는다(policies.md 3.3). **주석 한 줄을 추가해 해시만 바꾼 파일**을 별도 준비해야 한다.

#### [서비스 파트] 실행 주의 ✅

- `qa-v1.3-terse` 프롬프트 파일이 `configs/prompts/`에 미리 커밋되어 있어야 한다.
- SP2 시연에서는 `immediate: true`로 호출. **실험(`mode: experiment`)에서는 쓰지 않는다** — 탐지 지연 측정이 왜곡된다.

---

end.