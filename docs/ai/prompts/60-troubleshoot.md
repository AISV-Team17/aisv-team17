# 60. Troubleshooting

## Purpose

Find the cause of a build or test failure, or of a review comment, and produce a fix proposal with a structured troubleshooting record.

## When to use

- When a local or CI build or test fails
- When applying review comments

## Inputs

- The full error message or the review comment (paste in full)
- The related code and reference documents

## Steps

1. Summarize the symptom in one line.
2. List the possible causes from most to least likely, with a way to check each (command, log location, or file path).
3. Ask before running any check command. After approval, run the commands to narrow the cause.
4. When the cause is confirmed, propose a fix.
   - If the fix affects an interface contract (`src/interfaces/`), API contract, or transaction boundary, mark it **팀 협의 필요** and stop.
5. Write the fix commit message following `CONTRIBUTING.md` > `커밋 메시지 규칙`. Include the cause in the subject line.
6. Fixes are applied through stage 30 Step B — one commit at a time. Do not batch them.
7. Output a structured troubleshooting record for the session.

## Output format

```markdown
### 원인 후보
| 순위 | 후보 | 확인 방법 | 결과 |
| --- | --- | --- | --- |

### 수정 방안
- 대상:
- 커밋 메시지:
- 팀 협의 필요: 예 / 아니오

### 트러블슈팅 기록
- **증상**:
- **원인**:
- **해결**:
- **교훈**:
```

## Do not

- Propose a fix that hides the symptom without confirming the cause (disabling a test, ignoring an exception, raising a timeout). If unavoidable, state the reason and propose a follow-up issue.
- Proceed with a fix that needs team agreement without approval.
- Apply fixes in a batch — go through stage 30 Step B one commit at a time.
- Run check commands without asking first.

## Human gate

- The user approves running each check command.
- The user decides the fix, and it is applied through stage 30 Step B.
- For PR body updates after a fix, output the updated content in the 50-pr-write format and wait for "반영해".

---

end.