# Review checklist

The shared standard for self-review (`prompts/40-review.md`) and reviewer-assisted review.
Each item states only what to compare and where the grounds are. The judgment criteria are in the referenced document.

## Verdicts

- `통과`: include the grounds (file and line, or command run with its result).
- `미통과`: state the location and reason.
- `해당 없음`: state the reason.
- `미확인`: item not verified. Do not change to 통과.
- A·H·I·J·K·M always apply. L applies when Python or TypeScript code changes. All others apply when the relevant change is present.

---

## A. Scope

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| A1 | No files changed outside the issue scope | `git diff --stat <base>...HEAD` (normal: `develop`, Stack: preceding branch) | `CLAUDE.md` §3 |
| A2 | If `src/interfaces/` changed, both parts have approved (CODEOWNERS) | diff + confirmation from both parts | `CLAUDE.md` §5, `docs/specs/interfaces.md` |
| A3 | Commit messages follow the convention | `git log --oneline <base>..HEAD` | `CONTRIBUTING.md` > `브랜치·커밋 규칙` |
| A4 | Issue size is within guidelines | `git diff --shortstat <base>...HEAD` | `CONTRIBUTING.md` > `Issue 관리` |

---

## B. API specification (when API route or response changes)

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| B1 | HTTP method and path match the specification | route decorator ↔ spec | `docs/specs/api.md` > relevant service section |
| B2 | Request fields, required/optional, and validation match the specification | request schema ↔ spec | `docs/specs/api.md` > relevant API |
| B3 | Response fields and status codes match the specification | response schema ↔ spec | `docs/specs/api.md` > relevant API |
| B4 | No fields or endpoints not in the specification | diff | `docs/specs/api.md` |

---

## C. Interface contract (when `src/interfaces/` changes)

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| C1 | Signature matches `docs/specs/interfaces.md` | implementation ↔ Protocol definition | `docs/specs/interfaces.md` |
| C2 | All methods accept a **list** of inputs — single-item input prohibited | method signature | `docs/specs/interfaces.md` > `1.1 설계 방침` > 배치 우선 |
| C3 | Implementation is a pure function: no DB or network access | method body | `docs/specs/interfaces.md` > `1.1 설계 방침` > 순수 함수 지향 |
| C4 | Score direction is correct: stage-1 `0.0`=clean `1.0`=hallucinated; stage-2 `0.0`=bad `1.0`=good | score usage | `docs/specs/erd.md` > `1. 설계 원칙` > 점수 방향 |

---

## D. Policy and configuration (when domain logic or config values change)

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| D1 | Retry policy and backoff match the document | retry settings | `docs/specs/policies.md` |
| D2 | Threshold (τ), sample rate (r), and cooldown values match the document | constants / env vars | `docs/specs/policies.md` |
| D3 | Routing logic (τ threshold first, then r sample) is in the correct order | worker routing code | `docs/specs/policies.md` > 라우팅 정책 |
| D4 | Drift window size and incident cooldown satisfy the invariant (`cooldown ≥ window`) | config values | `docs/specs/policies.md` > 2.2 불변식 |
| D5 | Related ADR decision matches the code | `docs/adr/` > relevant ADR ↔ code | `docs/adr/` |

---

## E. Data and migrations (when DB schema or query changes)

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| E1 | Schema matches `docs/specs/erd.md` and an Alembic migration file exists in `backend/alembic/` | ORM model ↔ `erd.md` ↔ migration file | `docs/specs/erd.md` |
| E2 | No direct DDL — only Alembic | search for raw `CREATE`/`ALTER`/`DROP` in code | `docs/specs/erd.md` > `1. 설계 원칙` > 스키마 변경 |
| E3 | `eval_jobs` INSERT and trace INSERT are in the same transaction | transaction boundary | ADR-004 |
| E4 | Queue polling uses `FOR UPDATE SKIP LOCKED` | query pattern | ADR-004, `docs/specs/erd.md` > `작업 큐` |

---

## F. OTel instrumentation (when telemetry or tracing code changes)

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| F1 | `gen_ai.*` standard attributes used for LLM call spans | span attribute keys | `docs/specs/telemetry.md` |
| F2 | `app.version.*` custom attributes included for prompt, model, and retrieval version tracking | span attribute keys | `docs/specs/telemetry.md` |
| F3 | `BatchSpanProcessor` used; export failures are swallowed and do not affect the service response | exporter config | ADR-001, ADR-002 |
| F4 | Cost calculation uses the correct pricing table from `docs/specs/telemetry.md` | cost computation | `docs/specs/telemetry.md` > 비용 계산 |

---

## G. Model and ONNX (when model code changes)

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| G1 | No model binary files committed (`.onnx`, `.pt`, `.bin`, `.safetensors`) | `git diff --stat` | `model/CLAUDE.md` §3 |
| G2 | CPU p95 latency (ms) and model size (MiB) measured and recorded in the PR body | benchmark results | `model/CLAUDE.md` §5 |
| G3 | Accuracy delta from PyTorch baseline is within the accepted range | evaluation results | `docs/specs/model-registry.md` |
| G4 | ONNX export uses Hugging Face Optimum with `dynamic_axes` set | conversion code | `model/CLAUDE.md` §5 |
| G5 | `detect` method signature: `List[EvalInput] → List[DetectionResult]` | method signature | `docs/specs/interfaces.md` |

---

## H. Security and secrets

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| H1 | No secrets in code, config, tests, or docs | `git grep -nE "password=\|api_key=\|ANTHROPIC_API_KEY=\|ghp_\|github_pat_\|BEGIN.*PRIVATE"` | `CLAUDE.md` §0 |
| H2 | `NEXT_PUBLIC_` environment variables contain no secrets | env var names | `frontend/CLAUDE.md` §6 |
| H3 | Agent uses only the read-only DB account (`aisv_ro`) | agent DB DSN config | ADR-007, `backend/CLAUDE.md` §8 |

---

## I. Tests

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| I1 | Normal and exception scenarios both have tests | test list | `docs/specs/SDD.md` > 인수 기준 |
| I2 | Integration tests marked `@pytest.mark.integration` | test decorators | `backend/CLAUDE.md` §2 |
| I3 | LLM call tests marked `@pytest.mark.llm` | test decorators | `backend/CLAUDE.md` §2 |
| I4 | Only commands actually run in stage 40 are recorded in the PR test section | PR body ↔ stage 40 result | `prompts/50-pr-write.md` §3 |

---

## J. Build

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| J1 | backend pre-commit routine passes | `uv run ruff check . && uv run ruff format --check . && uv run mypy src && uv run pytest -q -m "not llm and not integration"` | `backend/CLAUDE.md` §2 |
| J2 | model pre-commit routine passes | `uv run ruff check . && uv run ruff format --check . && uv run pytest -q` | `model/CLAUDE.md` §2 |
| J3 | frontend pre-commit routine passes | `npm run lint` | `frontend/CLAUDE.md` §2 |

---

## K. Document update

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| K1 | If a contract changed, the document PR was merged before the implementation PR | related doc PR merge status | `CLAUDE.md` §2 |
| K2 | ADR contains the decision only — no progress notes or follow-up tasks | ADR diff | `CONTRIBUTING.md` > 결정 기록 규칙 |
| K3 | If a reference document section was renamed, `CLAUDE.md` §4, prompts, and this checklist were updated too | `grep` | `CLAUDE.md` §4 |

---

## L. Code structure (when Python or TypeScript code changes)

| # | Check | Method | Reference |
| --- | --- | --- | --- |
| L1 | (backend) Layer order: router → service → repository. No DB access from the router layer | file imports | `backend/CLAUDE.md` §4 |
| L2 | (backend) DB access only through SQLAlchemy async session | query code | `backend/CLAUDE.md` §6 |
| L3 | (backend) OTel span attributes follow `backend/CLAUDE.md` §5 | span attribute keys | `backend/CLAUDE.md` §5 |
| L4 | (frontend) Server Component is the default; `"use client"` only for browser APIs, event handlers, or hooks | component files | `frontend/CLAUDE.md` §4 |
| L5 | (frontend) No `any` type — `unknown` + type guard used | TypeScript types | `frontend/CLAUDE.md` §8 |
| L6 | (frontend) Tailwind utility classes only — no inline `style={{}}` | component files | `frontend/CLAUDE.md` §5 |
| L7 | (frontend) All API calls use `/api/v1` base path, not a hardcoded host | fetch calls | `frontend/CLAUDE.md` §6 |
| L8 | (all) No hardcoded values — use `configs/` for hyperparameters, env vars for secrets | code search | `backend/CLAUDE.md`, `model/CLAUDE.md`, `frontend/CLAUDE.md` |

---

## M. Documents and AI output

Applies to documents, configuration, issues, PRs, comments, and AI-generated code.

| # | Check | Method |
| --- | --- | --- |
| M1 | Implemented features confirmed in code or config, not just in the PR description | open the relevant file directly |
| M2 | No components or services described as existing that are not actually present | confirm file or config location for each described element |
| M3 | Tool behavior (ruff, mypy, CI) confirmed in config files, not assumed | `pyproject.toml`, `.github/workflows/` |
| M4 | No vague expressions (e.g., "if needed", "appropriately", "as necessary") | sentence review |
| M5 | No sentences that imply checks can be skipped | sentence review |
| M6 | One topic per document or issue | table of contents, scope of changes |
| M7 | Locations cited as `document > section > phrase`, never as line numbers | citation format |
| M8 | No secrets — empty values only (H1 result) | H1 result |
| M9 | Unknown values (issue numbers, due dates, assignees) left empty, not guessed | blank field check |
| M10 | AI-filled dates, numbers, names, and versions cross-checked against actual values | calendar, GitHub issues, `package.json`, `pyproject.toml` |
| M11 | Design scope matches project timeline and issue size | `CONTRIBUTING.md` > Issue 관리 |
| M12 | Code comments follow the commenting convention for the part | `backend/CLAUDE.md`, `frontend/CLAUDE.md`, `model/CLAUDE.md` |

---

end.