# frontend/CLAUDE.md — AISV-Team17

Also follow the root `CLAUDE.md`. If a rule below conflicts with the root file, follow this file.

## 1. Tech stack

The source of versions is `frontend/package.json`.

| Area | Library |
| --- | --- |
| Framework | Next.js (App Router) |
| Language | TypeScript |
| Styles | Tailwind CSS |
| Charts | Recharts |
| Package manager | npm |

- Use npm only. Check `package.json` > `engines` for the Node version.

## 2. Commands (run in `frontend/`)

The source of commands is `package.json` > `scripts`.

```bash
npm install
npm run dev      # dev server http://localhost:3000
npm run build
npm run lint     # ESLint (eslint.config.mjs)
```

- Run `npm run lint` before each commit.

## 3. Directory structure

Put new files in the existing structure below. If a new top-level directory under `src/` is needed, ask the user first.

| Path | Purpose |
| --- | --- |
| `src/app/` | App Router routes (page, layout, loading, error) |
| `src/components/` | Shared UI components |
| `src/features/` | Feature components per screen |
| `src/lib/` | API client, utilities |

- Use the tsconfig alias `@/*` (`./src/*`) for new imports.

## 4. Routing and components

- Use the App Router only. Do not create a `pages/` directory.
- Server Components are the default. Add `"use client"` only to files that need browser APIs, event handlers, or React hooks.

## 5. Styles

- Use Tailwind utility classes only. Do not add inline `style={{}}` or CSS Modules.
- Design tokens go in the Tailwind config or CSS variables, not as hardcoded values.

## 6. Data and API

- Use `/api/v1` as the base path for all API calls. The `next.config.ts` rewrite forwards requests to the console API.
- Do not put secrets in `NEXT_PUBLIC_` environment variables. These values are exposed to the browser.
- Align request and response types with `docs/specs/api.md`. Do not add fields not in the specification.
- For screens without a real API, prepare mock data in the format defined by `docs/specs/api.md`.

## 7. Charts

- Use only `recharts`. Wrap chart components in `<ResponsiveContainer>`.
- Use `<ReferenceLine>` to mark version change timestamps on time-series charts.

## 8. Types and packages

- Do not use `any`. If a type is unknown, use `unknown` and narrow it with a type guard.
- TypeScript strict mode is enabled. Do not suppress errors with `@ts-ignore` or `@ts-expect-error` without a comment explaining why.
- To add a package, explain why and get approval, then commit `package-lock.json` together.

---

end.