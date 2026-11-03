# 40. Review

## Purpose

Check changes against `docs/ai/review-checklist.md`. Mode A is the author's self-review before creating a PR. Mode B helps analyze a teammate's PR. People make all decisions in both modes.

## When to use

- Mode A: after all commits of stage 30, before creating the PR
- Mode B: when reviewing a teammate's PR

## Inputs

- Mode A: `git diff <base>...HEAD` — use `develop` for a normal PR and the preceding branch for a Stack PR
- Mode B: the PR number, the PR body (especially `💬 리뷰어에게`)
- `docs/ai/review-checklist.md`

---

## Steps — A. Self-review

1. Run `git diff --stat <base>...HEAD` and select the checklist sections that apply.
2. Open the grounds document for each checklist item and judge it as 통과, 미통과, 해당 없음, or 미확인. For 통과, give the file and line, or the command run and its result.
3. Run the commands in the build/test section. If a command could not be run, mark it 미확인.
4. For 미통과 items, propose a fix only. Do not make any changes.
5. Output the result and wait for approval.

---

## Steps — B. Review assist

1. Read the `💬 리뷰어에게` section of the PR body first. Check each request before anything else and record the result per request.
2. Select the checklist sections that apply. Always include the interface contract section if `src/interfaces/` is in the diff (CODEOWNERS path — both parts must approve).
3. Analyze from three viewpoints: function (gaps or mismatches against the specification), code (layers, transactions, exceptions), and tests (scenarios and coverage).
4. List separately anything in the PR body that differs from the actual code.
5. Write each finding in this form:
   - **지적**: file path and line range, what is wrong
   - **근거**: checklist number and `document > section > phrase`, or a code permalink (if you do not know the commit SHA, give path and lines and mark it for the reviewer to add)
   - **대안**: code or method to change. Use a suggestion block for small changes. List all valid options if there are several.
6. Assign severity and type:
   - 필수 (Request changes): build or test failure, security issue, API contract violation, ADR decision violation
   - 권장 (Comment): convention, consistency, readability, performance
   - 질문 (Comment): unclear intent, needs confirmation
7. If there are no 필수 findings, draft an approval comment: the PR subject in one line, the result for each `💬 리뷰어에게` request, and (if prior change requests exist) confirmation that each was addressed.
8. Output the analysis only. Do not post anything on GitHub.

---

## Output format

Mode A:

```markdown
### 적용 섹션
(적용 / 해당 없음과 이유)

### 판정
| # | 판정 | 근거 |
| --- | --- | --- |

### 실행한 명령
| 명령 | 결과 |
| --- | --- |

### 수정 필요
| # | 위치 | 수정 방안 |
| --- | --- | --- |
```

Mode B:

```markdown
### 리뷰어에게 확인 결과
| 확인 요청 | 결과 | 근거 |
| --- | --- | --- |

### 지적
(per finding)
**지적**: `파일경로` L시작-L끝 — 무엇이 문제인지 한 줄
**근거**: [체크리스트 번호] `문서 > 섹션 > 찾을 문구` 또는 permalink
**대안**: 바꿀 코드나 방법
**심각도**: Request changes / Comment

### PR 본문과 코드의 차이
-

### 승인 코멘트 초안 (필수 지적이 없을 때)
처음 리뷰인 경우:
  {PR 주제} 확인했습니다.
  - {확인 요청 항목} 확인했습니다.
  승인합니다.

이전 변경 요청이 있었던 경우: 위 내용에 반영 확인 항목 추가.
```

---

## Do not

- Mark a command you did not run as 통과.
- Mode A: fix 미통과 items without approval.
- Mode B: post comments, approvals, or change requests on GitHub directly. Always output the draft and let the user post manually.
- Mode B: mark a matter of taste as 필수 without documentary grounds.
- Mode B: write a finding without all of 지적, 근거, and 대안.

## Human gate

- Mode A: the author decides how to fix each 미통과 item and fixes it through stage 30 Step B. Do not create the PR until there are no 미통과 items.
- Mode B: the reviewer decides which findings to post and posts them manually on GitHub, including approvals and change requests. Changes to `src/interfaces/` require both parts to approve before merge.

---

end.