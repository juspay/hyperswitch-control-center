# GitHub Copilot Instructions — Hyperswitch Control Center

> Condensed guide for GitHub Copilot inline suggestions.
> Full details: see AGENTS.md and CLAUDE.md.

## Tech Stack
- **Language**: ReScript 11.1.1 (compiles to JavaScript) — NOT TypeScript
- **UI**: React 18.3.1 via `@rescript/react` 0.12.0
- **Styling**: Tailwind CSS 3 only — no inline styles, no other CSS frameworks
- **State**: Recoil 0.1.2 (`src/Recoils/`) for global state; `React.useState` for local
- **Stdlib**: `@rescript/core` 0.6.0, **globally opened** — use `Array`, `Dict`, `Option` directly

## Always Do
- Use `@react.component` decorator on every React component `let make`
- Use labeled props: `(~title: string, ~onClose: unit => unit)`
- Use `React.string`, `React.int`, `React.null` for JSX rendering
- Use `Option.getOr` (not `Belt.Option.getWithDefault`)
- Use `Js.Nullable.toOption` to convert nullable JS values
- Add API routes as variants in `APIUtilsTypes.res` and mappings in `APIUtils.res`
- Follow Tailwind class order: `layout → sizing → spacing → colors → typography → effects`

## Never Do
- Add TypeScript (`.ts`/`.tsx`) files to `src/`
- Write `open RescriptCore` inside modules — it is already global
- Add inline styles — use Tailwind utilities only
- Modify `config/config.toml` feature flag defaults
- Commit secrets, API keys, or credentials
- Edit `.res.js` compiled output files directly

## Commit Format (Conventional Commits)
```
feat(scope): description
fix(scope): description
docs(scope): description
chore(scope): description
refactor(scope): description
test(scope): description
```

## API Call Pattern
```rescript
// 1. Add variant in APIUtilsTypes.res
// 2. Add URL in APIUtils.res getURL function
// 3. In component:
let getData = APIUtils.useGetMethod()
let res = await getData(url)
```

## Key Files
- `src/APIUtils/APIUtils.res` — API layer
- `src/APIUtils/APIUtilsTypes.res` — entity variants
- `src/Recoils/` — global state atoms
- `src/screens/` — page modules
- `src/components/` — shared UI components
