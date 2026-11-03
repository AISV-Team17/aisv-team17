# 00. Session start

## Purpose

Confirm the part, issue, and branch, and select the ADRs and reference documents to read for the work.

## When to use

- At the start of each AI session
- When switching to a different issue in the same session

## Environment checklist

### One-time setup (once per machine)

1. Docker Desktop installed and running: `docker ps` returns no error
2. Pull the GitHub MCP image: `docker pull ghcr.io/github/github-mcp-server`
3. Register `GITHUB_PAT` as a user environment variable and restart the terminal — see `docs/ai/README.md` §3
4. Run `/mcp` in Claude Code and confirm `github` connected

### Every session

1. Docker Desktop is running (the GitHub MCP server runs on Docker)
2. Working directory is the repository root
3. For work that involves GitHub Issues or PRs: run `/mcp` and confirm `github` connected
   - If CONNECTION_CLOSED: check the token length (`($env:GITHUB_PAT).Length` on Windows, `echo ${#GITHUB_PAT}` on macOS/Linux)
   - If 0: re-register `GITHUB_PAT` and restart the terminal

## Inputs

- `CLAUDE.md` (loaded automatically by Claude Code)
- The issue body — read through GitHub MCP

## Steps

Report results only. Do not write code in this stage.

1. Follow `CLAUDE.md` §1 in order.
2. Summarize the issue's purpose and scope. Mark missing values as empty.
3. Check the current branch and `git status`. Verify the branch name follows `CONTRIBUTING.md` > `브랜치 전략`.
4. Find and read the ADRs in `docs/adr/` related to the work.
5. Select the reference documents and sections to read from `CLAUDE.md` §4.
6. If an ADR and a reference document say different things, list each difference as `document > section > phrase`.
7. List scope items that have no grounds in the documents as questions.

---

## Output format

### 작업 준비 보고

| 항목 | 확인 결과 |
| --- | --- |
| 담당 파트 | AI-SVC / AI-MDL |
| 이슈 | 제목, 완료 기한 (없으면 "비어 있음") |
| 브랜치 | 이름, 규칙 일치 여부 |
| Stack base 브랜치 | (Stack인 경우만) |
| 관련 ADR | 파일명 |
| 읽을 기준 문서 | 문서 > 섹션 |

### ADR과 기준 문서의 차이

- 없음 / `document > section > phrase`: 차이 내용

### 확인이 필요한 항목

1.

## Do not

- Fill in the issue scope, due date, or assignee by guessing.
- Create or switch branches without approval.

## Human gate

- The user reviews the report and says to proceed before the next stage begins.
- The user answers the items under 확인이 필요한 항목 before proceeding.

---

end.