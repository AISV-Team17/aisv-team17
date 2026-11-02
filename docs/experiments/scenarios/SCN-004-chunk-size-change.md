# SCN-004: 청크 크기 변경

| 항목 | 값 |
| --- | --- |
| **ID** | `SCN-004` |
| **변경 유형** | `CHUNK_CHANGE` |
| **발현 유형** | `PARTIAL_TRUTH` |
| **난이도** | HARD |
| **라벨** | 1 |

---

#### [모델 파트] 사고 대응 근거 ✅

**실제 사고 유형 참조**

- 근거: R1-① (약함) — 요청이 다른 문맥 창 설정의 서버에서 처리되면서 품질이 떨어진 사례처럼 "모델이 받는 문맥 조건이 바뀌는" 유형으로 분류한다. 직접 동일하지는 않다(실제 사례는 라우팅 결함, 이쪽은 의도적 설정 변경).
- 설명: 청크가 커지면 한 청크에 관련 없는 내용이 섞여 모델이 엉뚱한 부분을 인용하고, 작아지면 문장이 끊겨 맥락이 사라진다.
- 대응 강도: 약함 (포함 근거는 기획서 5장·7.3에서 정한 시나리오라는 점)

**탐지 포인트**

- 하락 폭이 작고 질문 유형에 따라 갈려 5분 창으로는 잡기 어려울 것으로 예상.
- **5분 창이 실패하고 15분 창이 성공하면** 그 자체가 탐지 지연과 민감도의 상충을 보여 주는 결과다. 실패도 보고 대상이다.

#### [모델 파트] 정답 라벨 정의 ✅

| 판정 | 기준 |
| --- | --- |
| POSITIVE (1) | `chunk_size: 512 → 1024` 변경이 원인 |
| NEGATIVE (0) | 주입 전 구간 및 재인덱싱 공백 구간 |

**경계 케이스**: 재인덱싱 중에는 검색이 불안정하다. **재인덱싱 구간은 탐지율·오탐 집계에서 모두 제외**하고 제외 구간 길이를 보고한다.

#### [모델 파트] 기대 신호 ✅

| 판정기 | 예상 반응 | 비고 |
| --- | --- | --- |
| 고정 임계값 | 불확실 | 저하 확인 필수 |
| KS 검정 | 불확실 | 동일 |
| 임베딩 거리 | 불확실 | 동일 |

---

#### [서비스 파트] YAML ✅

```yaml
scenario_id: SCN-004
title: "청크 크기 변경"
change_type: CHUNK_CHANGE
expression_type: PARTIAL_TRUTH
difficulty: HARD
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
  duration_min: 120        # 재인덱싱 공백과 지연 발현을 고려해 30분 연장

seed: 45

events:
  - at_minute: 22
    change: { llm_timeout_sec: 40 }
    is_decoy: true
    note: "디코이(D-TIMEOUT). 정상 구간에서는 발동하지 않는다"
  - at_minute: 30
    change: { chunk_size: 1024 }
    is_decoy: false
    note: "정답. 재인덱싱이 수반된다"

expected:
  detectable_by: [ks_test]
  expected_delay_min: 30
  quality_drop: SMALL

metadata:
  source: "RAG 인덱싱 파이프라인 변경, R1-① 참조"
  created_by: "AI-SVC"
  created_at: "2026-10-25T00:00:00Z"
```

#### [서비스 파트] 디코이 구성 ✅

- 디코이 수: 1건 (`D-TIMEOUT`)
- 배치: 정답 주입 8분 전

#### [서비스 파트] 실행 주의 ✅

- **이 시나리오만 재인덱싱이 필요하다.** 코퍼스를 다시 청크 분할해 임베딩을 다시 생성해야 하므로 수 분의 공백이 생긴다.
- `injection_events.applied_at`은 **재인덱싱 완료 시각**으로 적어야 탐지 지연이 왜곡되지 않는다.
- 재인덱싱 소요 시간 실측 후 회차 길이 120분 적정성을 확인한다(미결정).
- 재인덱싱 실패 시 회차를 `ABORTED`로 두고 데이터를 폐기한다(policies.md 3.7).

---

end.