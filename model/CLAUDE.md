# model/CLAUDE.md — AISV-Team17

Also follow the root `CLAUDE.md`. If a rule below conflicts with the root file, follow this file.

## 1. Tech stack

| Area | Library / Tool |
| --- | --- |
| Language | Python 3.12 |
| Training | PyTorch · Hugging Face Transformers |
| ONNX conversion | Hugging Face Optimum |
| Inference | ONNX Runtime |
| Dependency manager | uv |
| Linter / Formatter | ruff |
| Testing | pytest |

## 2. Commands (run in `model/`)

```bash
uv sync
uv run ruff check . && uv run ruff format --check .   # lint + format check
uv run pytest -q
```

- Run lint, format check, and tests before each commit.

## 3. Directory structure

| Path | Purpose |
| --- | --- |
| `src/` | Training, ONNX conversion, evaluation code |
| `tests/` | pytest tests |

- If a new top-level directory (e.g., `experiments/`) is needed, ask the user first.
- Do not commit model files (`.onnx`, `.pt`, `.bin`, `.safetensors`) to Git. Use Hugging Face Hub or Docker volumes.

## 4. Training pipeline

Follow RAGTruth dataset → preprocessing → fine-tuning → ONNX export → INT8 quantization → worker load.

## 5. ONNX conversion rules

- Use Hugging Face Optimum for ONNX export.
- Set `dynamic_axes` for variable sequence lengths.
- After conversion, verify that accuracy stays within the accepted delta from the PyTorch baseline.
- Measure and record CPU p95 latency (ms) and model size (MiB) after every conversion. Include these numbers in the PR body.

## 6. Interface compliance

- Implement `Detector` from `docs/specs/interfaces.md`.
- The `detect` method accepts a **list** of `EvalInput` and returns a **list** of `DetectionResult`. Single-item input is prohibited.
- Implementations must be pure functions: no DB or network access. Initialize the model in `__init__`; do not reload it per call.
- `score` direction for stage-1: 0.0 = clean, 1.0 = likely hallucinated. See `docs/specs/erd.md` > `점수 방향`.

## 7. Experiments and reproducibility

- Hyperparameters and dataset splits go in `configs/`. Do not hardcode them in source files.
- Every experiment must include a reproduction command in its docstring or an accompanying README section.

---

end.