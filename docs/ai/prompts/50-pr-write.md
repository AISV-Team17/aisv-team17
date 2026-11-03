# 50. PR writing

## Purpose

Write a PR body from the actual changes and verification results, and register it as a Draft after the user approves.

## When to use

After stage 40 Mode A shows no 미통과 items and the branch has been pushed.

## Inputs

- `git diff <base>...HEAD`, `git log --oneline <base>..HEAD` — use `develop` for a normal PR and the preceding branch for a Stack PR
- `.github/pull_request_template.md`
- `CONTRIBUTING.md` > `PR 작성`, `AI로 Issue·PR을 작성할 때`
- The stage 40 Mode A result

## Steps

1. Follow `CONTRIBUTING.md` > `PR 작성`, `AI로 Issue·PR을 작성할 때`, and the PR template.
2. List only changes visible in the current diff.
3. In the test section, check only what appears under 실행한 명령 in stage 40. Give the commands and results in the details block.
4. In the checklist, check only items that passed in stage 40.
5. If the diff includes `src/interfaces/` (CODEOWNERS path), note in the `💬 리뷰어에게` section that both parts must approve before merge.
6. If a related ADR is applicable, name the file in the `💬 리뷰어에게` section.
7. Output the body and wait for approval. Register on GitHub only after the user says "등록해".

## Output format

- PR 제목
- PR 본문 (template format, guidance comments removed)
- Outside the body: base branch, Draft status, label suggestions, empty values and questions

## Do not

- Describe planned work as done.
- Check tests not in the stage 40 result.
- Register without approval.
- Assign reviewers — the user does this directly after registration.
- Include CI check results in the PR body.
- Report test results of services not in the diff — only the owner part's services.

## Human gate

- The user reviews the body, fills empty values, and says "등록해". The PR is registered as a Draft.
- After registration, the user switches it to Ready for review when ready to merge.
- Merge (Squash and merge to `develop`) does not require teammate approval except for `src/interfaces/` changes (CODEOWNERS).

---

end.