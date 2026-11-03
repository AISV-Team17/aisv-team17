# 20. Issue writing

## Purpose

Write an issue body from a confirmed spec, and register it after the user approves.

## When to use

After stage 10 confirms the scope and decisions, once per issue. Also used to update an existing issue to match the confirmed plan.

## Inputs

- One issue confirmed in stage 10
- The issue template in `.github/ISSUE_TEMPLATE/`
- `CONTRIBUTING.md` > `Issue 관리`, `AI로 Issue·PR을 작성할 때`

## Steps

1. If the issue already exists (manually created):
   - Read the title and body through GitHub MCP.
   - Compare against the scope from the stage 10 output.
   - Report all discrepancies (title mismatch, missing fields, placeholder text still present).
   - Propose corrections and wait for approval before proceeding.
2. Choose the template that fits the type of work.
3. Write only the confirmed scope in the body. Do not include implementation choices that are not yet decided.
4. Put reference document locations and prerequisite issue numbers in the reference section.
5. Leave values not provided in the inputs empty (due date, assignee, issue numbers), and list them as questions outside the body.
6. Outside the body, give one line on why you chose the priority and size.
7. Before outputting, verify that no placeholder text remains:
   - 🎯 작업 목적: not "여기에 작성"
   - ✅ 구현 내용: specific items, not "구현 상세 내용"
   - 🧭 중요도: one checkbox checked
   - 📏 예상 작업 규모: one checkbox checked
   - 📅 완료 기한: actual date in `yyyy-mm-dd(요일)` format
   - 이슈 확인 체크박스: leave ALL unchecked — the author checks after posting, not the AI
8. Output the body and wait for approval. Register on GitHub only after the user says "등록해".

## Output format

- Issue 제목
- Issue 본문 (template format, guidance comments removed)
- Outside the body: template selection reason, priority and size rationale, empty values and questions

## Do not

- Copy template example sentences as facts.
- Fill empty values by guessing.
- Register without approval.
- Check the 이슈 확인 체크박스 on behalf of the author.

## Human gate

- The user reviews the body, fills the empty values, and says "등록해".
- After registration, the user sets the milestone, assignee, and labels.

---

end.