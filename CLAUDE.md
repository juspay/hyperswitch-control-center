# CLAUDE.md — Claude Code Guide for Hyperswitch Control Center

> Claude Code-specific instructions. Read AGENTS.md first for the full picture.

---

## Read First (in order)

1. `AGENTS.md` — tech stack, setup, conventions, guardrails
2. `memory-bank/techContext.md` — local dev setup, key configuration
3. `memory-bank/systemPatterns.md` — architecture, API flow, component patterns
4. `rescript.json` — compiler flags, JSX mode, stdlib configuration

---

## Planning Preamble

Before making any non-trivial changes:
1. Produce a plan listing **concrete file paths** and the exact change in each
2. Confirm that all referenced files exist (`Glob` / `Read`)
3. State which ReScript variants or types will be added/modified
4. Only then begin editing

For documentation-only tasks, do **not** touch `src/`, `config/`, `aws/`, `cypress/`,
or `public/`.

---

## Tool Hints

- Prefer `rg` (ripgrep) over `grep` for codebase searches
- Before editing `.res` files, ensure `npm run re:start` is running in the background
- After edits, run `npm run re:build` to surface type errors without a full build
- Use `npm run re:format` to normalize ReScript formatting before committing
- Read `.resi` files to understand a module's public API before modifying `.res`

---

## ReScript Quick Reference

```rescript
// React component (JSX v4 classic mode, uncurried)
@react.component
let make = (~title: string, ~count: int=0, ~onClose: unit => unit) => {
  <div className="flex items-center gap-2">
    <span> {title->React.string} </span>
    <span> {count->React.int} </span>
    <button onClick={_ => onClose()}> {"Close"->React.string} </button>
  </div>
}

// Pattern matching — must be exhaustive (compiler enforces)
let label = switch status {
| Active  => "Active"
| Pending => "Pending"
| Closed  => "Closed"
}

// Stdlib: RescriptCore is opened globally via -open RescriptCore in bsc-flags
// Use Array, Dict, Option, String, etc. directly — no open needed
let doubled = items->Array.map(x => x * 2)
let fallback = maybeValue->Option.getOr("default")
let value = dict->Dict.get("key")  // returns option<'a>

// Belt is available but prefer RescriptCore APIs for new code
// Belt.Option.getWithDefault → Option.getOr
// Belt.Array.map → Array.map

// JS nullable interop
let opt = jsNullable->Js.Nullable.toOption  // option<'a>

// Module binding
@module("some-lib") @val external someValue: string = "exportName"

// %raw escape hatch (use sparingly — only at JS interop boundaries)
let jsObj = %raw(`{ key: "value" }`)

// Async/await (ReScript 11 uncurried)
let fetchData = async () => {
  let url = getURL(~entityName=V1(MyEntity), ~methodType=Get)
  let res = await getMyData(url)
  setData(_ => Some(res))
}
```

**Key rules:**
- `RescriptCore` is globally opened — **never** add `open RescriptCore` inside a module
- All modules are PascalCase; values are camelCase
- Every `.res` module should have a `.resi` interface file defining its public API
- No TypeScript; no JS object literals where records work

---

## Common Pitfalls

| Pitfall | Correct approach |
|---------|-----------------|
| Writing `open RescriptCore` inside a module | Don't — it's already global |
| Using `Belt.Option.getWithDefault` | Use `Option.getOr` instead |
| Editing `.res.js` compiled output | Edit `.res` source only |
| Missing `@react.component` on a component | Always add it — JSX won't compile |
| Ignoring `.resi` when calling a module | Read `.resi` first — unlisted functions are private |
| Modifying feature flag defaults | Never — use env var overrides |

---

## Where to Look

| Need | File |
|------|------|
| API call pattern | `.clinerules` (bottom section) |
| Architecture diagram | `memory-bank/architecture.md` |
| Copy-paste snippets | `memory-bank/rescript-patterns.md` |
| Payments glossary | `memory-bank/glossary.md` |
| AI scaffolding overview | `AUDIT.md` |
| All agent files | `AGENTS.md` |
