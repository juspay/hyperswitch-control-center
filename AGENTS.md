# AGENTS.md — Hyperswitch Control Center

> **Primary entry point for ALL AI coding agents.**
> Hyperswitch Control Center — open-source payments dashboard for the Hyperswitch payments switch
> (https://github.com/juspay/hyperswitch)

---

## Tech Stack (exact versions from `package.json`)

| Library | Version |
|---------|---------|
| `rescript` | 11.1.1 |
| `react` / `react-dom` | 18.3.1 |
| `@rescript/react` | 0.12.0 |
| `@rescript/core` | 0.6.0 |
| `tailwindcss` | 3.0.0 |
| `webpack` | 5.99.9 |
| `recoil` | 0.1.2 |
| `cypress` | 13.6.0 |
| `@playwright/test` | 1.58.2 |

ReScript config: `rescript.json` — JSX v4 classic mode, uncurried, `-open RescriptCore` global.

---

## Setup

```bash
# 1. Clone the repo
git clone https://github.com/juspay/hyperswitch-control-center
cd hyperswitch-control-center

# 2. Install dependencies
npm install

# 3. Configure backend URLs
# Edit config/config.toml:
#   [default.endpoints]
#   api_url="http://localhost:8080/api"
#   sdk_url="http://localhost:9050/HyperLoader.js"

# 4. Start Hyperswitch backend (in sibling hyperswitch/ directory)
cd ../hyperswitch
docker compose up -d --scale hyperswitch-control-center=0

# 5. Start ReScript compiler in watch mode (keep running in background)
cd ../hyperswitch-control-center
npm run re:start &

# 6. Start dev server
npm run start
# Open http://localhost:9000
```

---

## Daily Commands

| Task | Command | Notes |
|------|---------|-------|
| ReScript watch | `npm run re:start` | Run in background before editing `.res` files |
| Dev server | `npm run start` | Webpack dev server at `http://localhost:9000` |
| Build prod | `npm run build:prod` | re:clean + re:build + webpack prod |
| ReScript build (type check) | `npm run re:build` | One-shot compile; check for errors |
| ReScript format | `npm run re:format` | Format all `.res` files |
| Cypress interactive | `npm run cy:open` | Opens Cypress Test Runner |
| Cypress headless | `npm run cy:run` | Headless Cypress run |
| Playwright | `npm run pw:test` | Run Playwright suite |
| Playwright UI | `npm run pw:ui` | Playwright interactive UI |
| Lint (check) | `npm run lint:hooks` | ESLint, zero warnings |
| Lint + fix | `npm run lint:fix` | ESLint fix + Prettier write |
| Spell check | `typos` | External CLI — install separately |

---

## Repository Map

```
hyperswitch-control-center/
├── src/
│   ├── APIUtils/           # Centralized API layer (fetchApi, useGetMethod, useUpdateMethod)
│   ├── Recoils/            # Global Recoil state atoms  ⚠️ UNSAFE
│   ├── entryPoints/        # App routing and auth bootstrap  ⚠️ UNSAFE
│   ├── screens/            # Page-level screen modules (one per route)
│   ├── components/         # Shared UI components
│   ├── hooks/              # Custom React hooks
│   ├── entities/           # Domain entity type definitions
│   ├── context/            # React context providers
│   ├── utils/              # Pure utility functions
│   ├── IntelligentRouting/ # Smart payment routing feature
│   ├── Hypersense/         # AI analytics feature
│   ├── Recon/              # Reconciliation feature
│   ├── Vault/              # Vault / tokenization UI
│   └── ...                 # Other feature modules
├── config/
│   └── config.toml         # Feature flags and endpoint configuration  ⚠️ UNSAFE defaults
├── memory-bank/            # AI agent context files (Cline memory bank)
├── .opencode/agents/       # OpenCode agent definitions (5 subagents)
├── .cursor/rules/          # Cursor MDC rules
├── .github/                # PR templates, Copilot instructions, CI workflows
├── cypress/                # Cypress E2E tests
├── playwright-tests/       # Playwright E2E tests
├── docs/                   # Contributor documentation
├── aws/                    # Deployment scripts  ⚠️ UNSAFE
├── AUDIT.md                # AI scaffolding inventory
├── AGENTS.md               # This file — agent entry point
├── CLAUDE.md               # Claude Code-specific guide
├── llms.txt                # LLM index (llmstxt.org spec)
└── rescript.json           # ReScript compiler configuration
```

---

## Coding Conventions (ReScript-first)

### Module & File Naming
- **PascalCase** for module files: `PaymentList.res`, `APIUtils.res`
- **camelCase** for values and functions: `let fetchPayments`, `let handleSubmit`
- Every significant `.res` module should have a companion `.resi` interface file
- File names match module names exactly

### React Components
```rescript
@react.component
let make = (~title: string, ~onClose: unit => unit) => {
  <div className="flex flex-col gap-4">
    <p> {title->React.string} </p>
    <button onClick={_ => onClose()}> {"Close"->React.string} </button>
  </div>
}
```

### Adding a New Screen
1. Create `src/screens/MyFeature/MyFeatureScreen.res` (and `.resi`)
2. Register route in the appropriate entryPoints routing file
3. Fetch data using `useGetMethod` from `APIUtils`

### Adding a New API Call
```
1. Add variant to APIUtilsTypes.res  (entityName type)
2. Add URL mapping in APIUtils.res   (getURL function, V1(MyEntity) => "/api/...")
3. In component: useGetMethod() hook → async fetch → typed state
```
See `.clinerules` for the full step-by-step pattern.

### Feature Flag Consumption
Flags are defined in `config/config.toml` under `[default.features]` and exposed via
`window.__env__` at runtime. Read them through the feature flag Recoil atom or context
in `src/`. Never read `config.toml` directly from components.

### Tailwind Class Ordering
`layout → sizing → spacing → colors → typography → effects`
Two Tailwind configs: `tailwind.config.js` (main) and `tailwindHyperSwitch.config.js` (overrides).

---

## Guardrails — DO NOT

- Do **not** port ReScript to TypeScript or add `.ts`/`.tsx` files to `src/`
- Do **not** introduce new CSS frameworks (only Tailwind utilities)
- Do **not** add runtime dependencies without explicit justification and maintainer approval
- Do **not** modify `aws/` scripts unless explicitly instructed
- Do **not** change `config/config.toml` feature flag defaults
- Do **not** hardcode secrets, API keys, or credentials anywhere
- Do **not** bypass the `typos` spell-checker with `--force`
- Do **not** create unsigned commits (GPG signing is required)
- Do **not** modify `src/` files for documentation-only tasks

---

## Testing Expectations

| Layer | Tool | How to run |
|-------|------|-----------|
| Unit logic | Jest | `npm test` (if configured) |
| E2E flows | Cypress | `npm run cy:open` (interactive), `npm run cy:run` (headless) |
| New E2E | Playwright | `npm run pw:test` |
| Single Cypress spec | Cypress | `cypress run --spec cypress/e2e/my.spec.cy.js` |

---

## Commit & PR Rules

### Commit Format (Conventional Commits)
```
<type>(<scope>): <description>

Types: feat | fix | chore | refactor | docs | test | style
Example: feat(payments): add retry button to failed payment card
```

- Commits must be **GPG-signed**
- Branch naming: `feature/<slug>` or `fix/<slug>`

### PR Checklist
- [ ] Conventional Commit format in title
- [ ] GPG-signed commit
- [ ] `typos` check clean
- [ ] `npm run re:build` passes
- [ ] Jest green (if applicable)
- [ ] Cypress / Playwright green locally
- [ ] No `src/` changes for doc-only PRs

---

## Where to Look

| Need | Where |
|------|-------|
| Project conventions | `CLAUDE.md`, `.clinerules`, `AGENTS.md` (this file) |
| Detailed AI context | `memory-bank/` core files |
| Architecture & request lifecycle | `memory-bank/architecture.md` |
| Copy-paste ReScript snippets | `memory-bank/rescript-patterns.md` |
| Payments domain glossary | `memory-bank/glossary.md` |
| AI scaffolding audit | `AUDIT.md` |
| Contributor guide | `docs/CONTRIBUTING.md` |
| AI scaffolding maintenance | `docs/ai-contributing.md` |
