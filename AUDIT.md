# AI Scaffolding Audit — Hyperswitch Control Center

> Inventory of all existing AI agent context files, source tree map, command surface,
> ReScript gotchas, and unsafe areas. Keep this file under 400 lines.

---

## 1. Existing AI Scaffolding Inventory

### `.clinerules` (repo root)
- **Covers**: Cline memory-bank workflow, file-edit rules, API call pattern (variants →
  URL mapping → `useGetMethod`), commit-message body format, module-opening policy
  (`-open RescriptCore` is global — don't re-open).
- **Missing**: No project-specific guardrails for unsafe paths; no onboarding for agents
  other than Cline.

### `.opencode/agents/` — 5 agent files
| File | Mode | Covers |
|------|------|--------|
| `rescript-11-docs-advisor.md` | subagent | ReScript 11 idiom review (patterns, types, interop, stdlib) |
| `rescript-react-perf-reviewer.md` | subagent | React perf: memoisation, unnecessary re-renders, list keys |
| `rescript-structure-guardian.md` | subagent | Module structure, .res/.resi pairing, encapsulation |
| `reuse-reviewer.md` | subagent | Duplication detection, shared component/util extraction |
| `tailwind-css-reviewer.md` | subagent | Tailwind class ordering, no inline styles, config compliance |

**Missing**: No top-level agent entry point (AGENTS.md); no Cursor rules; no GitHub
Copilot instructions; no Claude Code guide.

### `memory-bank/` — Core files + thematic subfolders
| File | Covers |
|------|--------|
| `projectbrief.md` | Goals, target audience, functional/technical requirements |
| `productContext.md` | Product purpose, user experience goals |
| `activeContext.md` | Current sprint focus, recent changes, next steps |
| `systemPatterns.md` | Architecture, API flow, component composition, state management |
| `techContext.md` | Tech stack, local setup steps, MCP servers |
| `progress.md` | Implementation status, known issues |
| `thematic/` | Subdirectories: PageCreationWithTableAndChart, TableComponentPage, api, components, graphs, intelligent-routing, payments, rescript, state, ui |

**Missing**: `architecture.md` (request lifecycle), `rescript-patterns.md` (copy-paste
snippets), `glossary.md` (payments domain terms).

### `context7.json` (repo root)
Points to `https://context7.com/juspay/hyperswitch-control-center` — used by Cline's
Context7 MCP server to fetch up-to-date library docs. No agent reads it automatically;
must be invoked manually.

---

## 2. Source Tree Map (`src/` — two levels deep)

```
src/
├── APIUtils/           # Centralized API layer: fetchApi, useGetMethod, useUpdateMethod, responseHandler
├── Hypersense/         # Hypersense AI analytics feature module
├── IntelligentRouting/ # Smart routing rule configuration (volume, rule-based)
├── Interface/          # Low-level JS interop and type-safe wrappers
├── Orchestration/      # Payment orchestration v1 module
├── OrchestrationV2/    # Payment orchestration v2 module
├── Recoils/            # Global Recoil atoms (auth, user, toast, feature flags) ⚠️ UNSAFE
├── Recon/              # Reconciliation feature module
├── ReconEngine/        # Reconciliation engine logic
├── RevenueRecovery/    # Revenue recovery (smart retry) flows
├── Themes/             # Theme context and configuration
├── UIConifg/           # [sic] UI configuration module
├── Vault/              # Vault / tokenization UI
├── blend/              # Blend design system integration
├── components/         # Shared UI components (Button, Table, Modal, etc.)
├── container/          # App-level container / layout components
├── context/            # React context providers (auth, permissions, etc.)
├── embeddable/         # Embeddable widget entry point
├── entities/           # Domain entity type definitions
├── entryPoints/        # App routing & auth entry ⚠️ UNSAFE
├── fragments/          # GraphQL-style data fragments / partial type definitions
├── hooks/              # Custom React hooks
├── libraries/          # Internal utility libraries
├── mockData/           # Mock data for local development and tests
├── screens/            # Page-level screen modules (one per route/view)
├── server/             # Node.js dev-server and SSR glue
└── utils/              # Pure utility functions (LogicUtils, etc.)
```

---

## 3. Command Surface

### npm scripts (from `package.json`)
| Task | Command | Notes |
|------|---------|-------|
| Dev server | `npm run start` | Webpack dev server, default `http://localhost:9000` |
| Prod-like dev | `npm run prod:start` | `NODE_ENV=production` + webpack dev server |
| Serve built dist | `npm run serve` | `node dist/server/server.js` |
| ReScript watch | `npm run re:start` | Must run in background before editing `.res` files |
| ReScript one-shot build | `npm run re:build` | Run after type errors to check compilation |
| ReScript clean | `npm run re:clean` | Clears `.res.js` artifacts |
| ReScript format | `npm run re:format` | Format all `.res` files |
| Build prod | `npm run build:prod` | re:clean + re:build + webpack prod |
| Build custom | `npm run build:custom` | re:clean + re:build + webpack custom |
| Build test | `npm run build:test` | Coverage-enabled prod build |
| Cypress interactive | `npm run cy:open` | Opens Cypress Test Runner |
| Cypress headless | `npm run cy:run` | Headless Cypress run |
| Playwright | `npm run pw:test` | Run Playwright test suite |
| Playwright UI | `npm run pw:ui` | Playwright with interactive UI |
| Lint (no fix) | `npm run lint:hooks` | ESLint, max-warnings 0 |
| Lint + fix | `npm run lint:fix` | ESLint fix + Prettier write |
| Spell check | `typos` | External CLI tool (install separately) |

### Makefile — Docker targets
```
make run                # docker compose up (dev)
make build              # docker build
make stop               # docker compose down
```
> Check `Makefile` for exact targets; they wrap `docker compose` commands.

---

## 4. ReScript-Specific Gotchas

1. **`.res`/`.resi` pairing** — A `.resi` file is the public interface for the module.
   Anything not in the `.resi` is private. Always check `.resi` before assuming a
   function is accessible from another module.

2. **`@react.component` decorator** — Required on every React component `let make`.
   Without it, JSX compilation fails silently. Also triggers uncurried calling convention.

3. **JSX v4 classic mode** — `rescript.json` sets `"version": 4, "mode": "classic"`.
   Components use `React.string`, `React.int`, `React.null`, not the `<>` fragment shorthand
   seen in newer JSX transform examples.

4. **Uncurried mode** — `rescript.json` sets `"uncurried": true`. All functions are
   uncurried by default. Use `(. arg)` / `(.arg)` syntax only for explicit curried interop.
   Most standard patterns just work; watch out when passing higher-order functions to JS.

5. **`-open RescriptCore`** — `bsc-flags` globally opens `RescriptCore`. Use `Array.map`,
   `Option.getOr`, `Dict.get`, `String.startsWith` etc. directly. **Do not** write
   `open RescriptCore` inside modules — it is redundant and may cause shadowing warnings.
   Belt is still available but prefer RescriptCore APIs.

6. **`option<'a>` and `Js.Nullable`** — Use `Js.Nullable.toOption` to convert nullable
   JS values. `Option.getOr` (not `Belt.Option.getWithDefault`) is the idiomatic fallback.

7. **`%raw`** — Escape hatch for inline JavaScript. Limit to interop boundaries.
   Never use `%raw` for business logic; prefer typed bindings.

8. **Compiled output** — Each `.res` file compiles to a `.res.js` (ESModule) in-source.
   These are checked in (or generated). Do not edit `.res.js` files directly.

---

## 5. Unsafe Areas — Proceed With Caution

| Path | Risk |
|------|------|
| `src/entryPoints/` | Auth routing and session bootstrap — touches auth tokens and redirect logic |
| `src/Recoils/` | Global state atoms — changes here affect every screen that reads those atoms |
| `config/config.toml` | Feature flag defaults shipped to production — never flip a default without intent |
| `aws/` | Deployment scripts and infrastructure — infra changes require explicit human sign-off |
| Any file containing `apiKey`, `secret`, `credential` | Processor credentials — never log or expose |

---

*Last updated: 2026-04-22 by AI scaffolding task.*
