# 30. Implementation — model

## Purpose

Implement a confirmed issue scope in `model/` one commit at a time, with approval for each commit.

## When to use

After the user approves the stage 00 report and the stage 10 plan.

## Inputs

- The issue number and confirmed scope from stages 00 and 10
- The ADRs and reference documents chosen in stage 00
- `model/CLAUDE.md` — tech conventions
- `docs/specs/interfaces.md` — Detector interface contract
- Check existing code for precedents before planning:
  - `src/` — existing training, conversion, and evaluation patterns
  - `pyproject.toml` — current dependencies
  - `configs/` — existing hyperparameter and dataset split format

## Steps — A. Plan

1. Output the implementation plan first. Do not write code yet.
   - Order commits to follow the pipeline: data / preprocessing → training → ONNX conversion → evaluation / integration. Tests go in the same commit as the code they test.
   - Follow `model/CLAUDE.md` §3 for directory placement.
   - For each commit, list the files, the pipeline stage, and the commit message (`{type}({domain}): {subject}` from `CONTRIBUTING.md`).
   - Hyperparameters and dataset splits go in `configs/`, not hardcoded in source files.
   - Cite grounds for each decision as `document > section`.
2. List the following as option tables only. Do not decide.
   - Hyperparameter choices not confirmed in `configs/`, optimization tradeoffs
   - Values not in `docs/specs/interfaces.md` or the documents
3. If an ADR and a reference document differ, follow the ADR and list the difference.
4. If the work requires a change to `docs/specs/interfaces.md` (Detector contract), stop planning and propose the document change first. Changes to `src/interfaces/` require approval from both parts (CODEOWNERS).
5. For Stack PRs, note the base branch. Branch creation: `git switch -c {branch} {base}`.
6. Output the plan and wait for approval.

## Steps — B. Each commit

1. Write or change only the files in the plan for this commit. If another file is needed, say so and wait for approval.
2. Run the pre-commit routine and show results:
   ```bash
   uv run ruff check . && uv run ruff format --check .
   uv run pytest -q
   ```
3. Show `git diff --stat` and the commit message, and wait for approval.
4. Commit only after the user says to commit. Output the push command; do not run it.
5. After an ONNX conversion commit, measure and report before committing:
   - CPU p95 latency (ms): run inference with representative inputs
   - Model size (MiB)
   - Accuracy delta from PyTorch baseline (F1 or equivalent)
   These numbers must be included in the PR body (stage 50).
6. Before committing any Detector implementation, verify:
   - The `detect` method signature: `List[EvalInput] → List[DetectionResult]` — single-item input is prohibited.
   - The implementation is a pure function: no DB or network access. Model loading in `__init__` only.
   - Stage-1 `score` direction: 0.0 = clean, 1.0 = likely hallucinated (`docs/specs/erd.md` > `점수 방향`).
7. Do not commit model binary files (`.onnx`, `.pt`, `.bin`, `.safetensors`). Use Hugging Face Hub or Docker volumes.
8. If something fails during implementation, go to stage 60 (troubleshoot). Apply the fix through this step B after returning.

## Output format

```markdown
### 커밋 계획
| # | 단계 | 파일 | 커밋 메시지 | 근거 |
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
- Hardcode hyperparameters or dataset splits in source files — use `configs/`.
- Commit model binary files (`.onnx`, `.pt`, `.bin`, `.safetensors`).
- Commit an ONNX conversion without measuring CPU p95 latency and model size.
- Implement a single-item `detect` method — all Detector methods must accept a list.
- Access DB or network inside a Detector implementation.
- Change `src/interfaces/` without both parts' approval (CODEOWNERS).
- Commit while lint or tests fail.
- Push — output the push command for the user to run.

## Human gate

- Approve the plan; decide items under 결정 필요; create a document issue when a contract change is needed.
- Review `git diff --stat` and the commit message for each commit, then say to commit.
- After ONNX conversion commits, confirm the latency, size, and accuracy numbers before committing.

---

end.