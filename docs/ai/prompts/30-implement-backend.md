# 30. Implementation — backend

## Purpose

Implement a confirmed issue scope in `backend/` one commit at a time, with approval for each commit.

## When to use

After the user approves the stage 00 report and the stage 10 plan.

## Inputs

- The issue number and confirmed scope from stages 00 and 10
- The ADRs and reference documents chosen in stage 00
- `backend/CLAUDE.md` — tech conventions
- `docs/specs/interfaces.md`, `docs/specs/api.md`, `docs/specs/erd.md`, `docs/specs/policies.md`, `docs/specs/telemetry.md`
- Check existing code for precedents before planning:
  - `src/` service modules — layer and naming patterns
  - `pyproject.toml` — current dependencies
  - `src/interfaces/` — existing interface contracts

## Steps — A. Plan

1. Output the implementation plan first. Do not write code yet.
   - Order commits so that each one runs independently: lower layers first (repository → service → router). Tests go in the same commit as the code they test.
   - Follow `backend/CLAUDE.md` §3 for directory placement and §4 for layer architecture.
   - For each commit, list the files, the layer, and the commit message (`{type}({domain}): {subject}` from `CONTRIBUTING.md`).
   - Cite grounds for each decision as `document > section`.
2. List the following as option tables only. Do not decide.
   - Transaction boundaries, retry policy choices, exception paths not in the specification
   - Values or behaviors not in the documents
3. If an ADR and a reference document differ, follow the ADR and list the difference.
4. If the work requires a contract change (`docs/specs/interfaces.md`, `docs/specs/api.md`, `docs/specs/erd.md`, `docs/specs/policies.md`), stop planning and propose the document change first. Changes to `src/interfaces/` require approval from both parts (CODEOWNERS).
5. For Stack PRs, note the base branch. Branch creation: `git switch -c {branch} {base}`.
6. Output the plan and wait for approval.

## Steps — B. Each commit

1. Write or change only the files in the plan for this commit. If another file is needed, say so and wait for approval.
2. Run the pre-commit routine and show the results:
   ```bash
   uv run ruff check . && uv run ruff format --check .
   uv run mypy src
   uv run pytest -q -m "not llm and not integration"
   ```
   For integration tests (when DB or OTel is involved): `uv run pytest -q -m integration`
3. Show `git diff --stat` and the commit message, and wait for approval.
4. Commit only after the user says to commit. Output the push command; do not run it.
5. For DB schema changes, the migration file goes in `backend/alembic/` via Alembic. Do not run DDL directly.
   ```bash
   alembic revision --autogenerate -m "{description}"
   alembic upgrade head
   ```
6. If the change affects runtime behavior (DB connection, OTel pipeline, LLM call, secret handling), recommend verifying in a separate terminal:
   > 비밀값이 필요한 명령은 Claude Code 터미널이 아닌 별도 터미널에서 직접 실행한다.
7. If something fails during implementation, go to stage 60 (troubleshoot). Apply the fix through this step B after returning.

## Output format

```markdown
### 커밋 계획
| # | 레이어 | 파일 | 커밋 메시지 | 근거 |
| --- | --- | --- | --- | --- |

### 결정 필요
| 판단 | 선택지 | 장점 | 단점 | 근거 문서 |
| --- | --- | --- | --- | --- |

### ADR과 기준 문서의 차이
-
```

## Do not

- Write code before the plan is approved.
- Change files outside the plan without approval.
- Use a response format, status code, or error code not in the specification.
- Guess values not in the documents.
- Change `src/interfaces/` without both parts' approval (CODEOWNERS).
- Commit while lint, mypy, or unit tests fail.
- Run DDL directly — use Alembic (`backend/alembic/`).
- Run commands with secret values in the Claude Code terminal.
- Push — output the push command for the user to run.

## Human gate

- Approve the plan; decide items under 결정 필요; create a document issue when a contract change is needed.
- Review `git diff --stat` and the commit message for each commit, then say to commit.

---

end.