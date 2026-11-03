# CLAUDE.md — AISV-Team17

Working rules for Claude Code in this repository. To change a rule, edit only this file. Part-specific `CLAUDE.md` files under `backend/`, `frontend/`, `model/`, and `infra/` define tech conventions only; workflow rules live here.

This file points to reference documents rather than copying them. If this file and a reference document conflict, follow the reference document and report the conflict to the user.

A `CLAUDE.md` in a subdirectory also applies to work in that directory and wins on conflict. Before reading or editing files under a subdirectory, read its `CLAUDE.md` first.

Reference documents are written in Korean. Section titles below keep the original Korean so you can search them as written.

---

## 0. Absolute rules

1. Follow `CONTRIBUTING.md` for all branching, commit, issue, and PR conventions.
2. Repository documents are the source of truth. Use conversation history or earlier sessions as grounds only when the content is reflected in a repository document or ADR.
3. Do not fill in values you could not confirm in a document (dates, issue numbers, measurements, policy values). Leave them blank and ask the user.
4. Do not create or edit issues, PRs, or comments until the user approves. Do not run `git push`.

---

## 1. Before starting work

1. Confirm the part (`AI-SVC` or `AI-MDL`) and issue number. If either is unknown, ask before working.
2. Check which services and areas the part owns from §5. If files to change are not owned by that part, stop and ask.
3. Follow `CONTRIBUTING.md` > `브랜치 전략` for branches. Only propose branch create or switch commands; run them after the user approves.
4. Read related decision records in `docs/adr/` before working.
5. Read the reference documents for the task from §4 before writing any code. Do not write code based on a document you have not read.
6. If changes to `src/interfaces/` are needed, confirm that both parts agree before proceeding. This path is covered by CODEOWNERS.

---

## 2. Document rules

- Follow `CONTRIBUTING.md` for document changes.
- If an ADR conflicts with a reference document, follow the latest ADR and report the conflict (document · section · phrase) to the user.
- If the task requires a contract change (API, interfaces, ERD, policy), stop implementing and propose the document change first.
- Check what is implemented by reading code and configuration files, not PR descriptions.
- Give document locations as `document > section`, never as line numbers.

---

## 3. Scope and prohibitions

- Do not modify files outside the issue scope. If a change outside the scope is needed, state the target and reason; modify only after the user approves.
- Files owned by the other part (`AI-SVC` ↔ `AI-MDL`) are read-only. If a change is needed, state the target and reason; modify only after the user confirms the other part has agreed.
- Before each commit, show the changed file list and commit message and get approval.
- Follow the tech conventions in the part-specific `CLAUDE.md` for the area being changed.
- Never write secrets (tokens, passwords, keys) to files, commits, issues, or PRs. Leave example values empty.
- Output `git push` commands for the user to run; do not run them directly.
- Show the full issue or PR body before creating or updating. Create or update only after the user says "등록해" or "반영해".
- Do not assign reviewers. The user does this directly.
- After creating a branch, output the push command immediately. Open a Draft PR before starting implementation.
- Do not reference `.personal/` paths or file names in commits, code, issues, PRs, or any tracked file.

---

## 4. Reference documents

| Work | Read first |
| --- | --- |
| Any work | `docs/adr/` (ADR-001–029) |
| Feature scope, priority | `docs/specs/SDD.md` |
| Interface contracts | `docs/specs/interfaces.md` |
| API specifications | `docs/specs/api.md` |
| Domain policies, retry, routing | `docs/specs/policies.md` |
| DB schema, migrations | `docs/specs/erd.md` · `backend/alembic/` |
| OTel telemetry, cost | `docs/specs/telemetry.md` |
| System architecture, diagrams | `docs/specs/diagrams.md` |
| Injection scenarios | `docs/specs/injection-scenarios.md` |
| Model registry | `docs/specs/model-registry.md` |
| Branches, commits, issues, PRs | `CONTRIBUTING.md` |
| Build, lint, type check | Part-specific `CLAUDE.md` (`backend/` · `frontend/` · `model/` · `infra/`) |
| AI collaboration | `docs/ai/README.md` · `docs/ai/prompts/` |

---

## 5. Parts

| Part | Owns |
| --- | --- |
| `AI-SVC` | `backend/` (rag · ingest · worker · drift · agent · console) · `infra/` · operations UI |
| `AI-MDL` | `model/` · evaluation design · experiment UI |
| Both (CODEOWNERS) | `docs/specs/interfaces.md` · `docs/adr/` · `configs/` |

Changes to `src/interfaces/` require approval from both parts before merge.

---

## 6. Language

- Reply to the user in Korean.
- Write issue, PR, and commit subjects and bodies in Korean. Keep `<type>(<domain>)` prefixes, code identifiers, and file paths as-is.

---

## 7. Stage prompts

When the user requests one of the stages below, read the prompt file first and follow its steps and output format. Wait for the user's approval after each stage's output. Do not advance to the next stage on your own.

| Request | Prompt |
| --- | --- |
| Start a session | `docs/ai/prompts/00-session-start.md` |
| Plan, break down issues | `docs/ai/prompts/10-plan.md` |
| Write or register an issue | `docs/ai/prompts/20-issue-write.md` |
| Implement — backend | `docs/ai/prompts/30-implement-backend.md` |
| Implement — model | `docs/ai/prompts/30-implement-model.md` |
| Implement — frontend | `docs/ai/prompts/30-implement-ui.md` |
| Self-review, help review a PR | `docs/ai/prompts/40-review.md` |
| Write or register a PR | `docs/ai/prompts/50-pr-write.md` |
| Build/test failure, applying review comments | `docs/ai/prompts/60-troubleshoot.md` |

Use only `docs/ai/review-checklist.md` as the review standard.

---

end.