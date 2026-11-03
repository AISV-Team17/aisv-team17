# 10. Plan

## Purpose

Analyze an issue against the reference documents, write a confirmed spec, and break it into commit-unit tickets with dependencies.

## When to use

After `00-session-start`, once per issue, before writing the issue body or starting implementation. Run the three steps in order — do not skip or reverse.

## Inputs

- Issue scope confirmed in `00-session-start`
- `docs/specs/interfaces.md`, `docs/specs/api.md`, `docs/specs/erd.md`
- `docs/specs/policies.md`, `docs/specs/SDD.md`, `docs/specs/telemetry.md`
- Related ADRs selected in `00-session-start`

---

## Steps — /grill-with-docs

1. Read the reference documents from `00-session-start`.
2. For each item below, check whether the document covers it. List what is missing or ambiguous as a question.
   - Interface contract (input/output types, batch requirement) in `docs/specs/interfaces.md`
   - Exception paths: LLM failure, ONNX error, DB timeout, OTel export failure
   - State transitions and retry policy in `docs/specs/policies.md`
   - API paths, request/response, status codes in `docs/specs/api.md`
   - DB schema and constraints in `docs/specs/erd.md`
   - Whether `src/interfaces/` (CODEOWNERS) is in scope
   - Any applicable ADR decision
3. Output the question list. State whether another round is needed.

Human gate: the user answers all questions before /to-spec begins.

---

## Steps — /to-spec

Using the answers from /grill-with-docs:

1. Write the confirmed spec. Cite grounds as `document > section` for each item.
2. Required sections:
   - Feature summary (one line)
   - Input / output / exception paths
   - Interface contract change needed: yes/no
   - `src/interfaces/` in scope (CODEOWNERS): yes/no
   - Test scenarios by type: unit · integration · LLM

Human gate: the user approves the spec before /to-tickets begins.

---

## Steps — /to-tickets

Using the confirmed spec:

1. Break the work into commit-unit tickets. Each ticket must be independently committable.
2. Place interface contract changes first.
3. Set Blocked by relationships between tickets.
4. This list is the Stack order and the issue registration order.

Human gate: the user approves the ticket list. If an interface contract change is needed, handle the document issue before the implementation tickets.

---

## Output format

### /grill-with-docs

| # | 구분 | 질문 | 관련 문서 |
| --- | --- | --- | --- |

추가 라운드 필요 여부:

---

### /to-spec

**기능 요약:**

| 항목 | 내용 | 근거 |
| --- | --- | --- |
| 입력 | | |
| 출력 | | |
| 예외 경로 | | |
| 인터페이스 계약 변경 | yes / no | |
| CODEOWNERS 경로 포함 | yes / no | |
| 테스트 시나리오 | | |

---

### /to-tickets

| # | 커밋 메시지 | Blocked by |
| --- | --- | --- |
| 1 | {type}({domain}): {subject} | — |
| 2 | {type}({domain}): {subject} | #1 |

---

## Do not

- Skip /grill-with-docs or /to-spec and jump straight to /to-tickets.
- Add features not in the planning documents.
- Mark a question as settled without the user's answer.
- Guess API signatures, error codes, or state transitions not in the documents.
- Put anything in the output that would require a decision the user has not made.

## Human gate

- After /grill-with-docs: the user answers all questions.
- After /to-spec: the user approves the spec.
- After /to-tickets: the user approves the ticket list.

---

end.