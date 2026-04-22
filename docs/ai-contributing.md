# AI Scaffolding — Maintainer Guide

> For human maintainers. Explains what AI scaffolding exists, which agent reads what,
> and how to keep everything in sync when conventions change.

---

## What AI Scaffolding Exists

| File / Directory | Purpose |
|-----------------|---------|
| `AGENTS.md` | Primary entry point for ALL AI agents — tech stack, setup, conventions, guardrails |
| `CLAUDE.md` | Claude Code-specific guide — planning preamble, tool hints, ReScript quick reference |
| `AUDIT.md` | Inventory of all AI scaffolding, source tree map, command surface, gotchas |
| `llms.txt` | LLM index (llmstxt.org spec) — links to all entry points |
| `.clinerules` | Cline memory-bank rules, API call pattern, commit message format, module policy |
| `.opencode/agents/` | OpenCode subagent definitions (5 files) |
| `.cursor/rules/` | Cursor MDC rules (5 files) |
| `.github/copilot-instructions.md` | GitHub Copilot condensed guide |
| `memory-bank/` | Cline + general AI context (6 core files + thematic subfolders) |
| `context7.json` | Points to context7.com for library documentation |

---

## Which Agent Reads Which File

| Agent / Tool | Primary files read |
|-------------|-------------------|
| **Cline** | `.clinerules`, all `memory-bank/` files |
| **Claude Code** | `CLAUDE.md`, `AGENTS.md`, `memory-bank/techContext.md`, `memory-bank/systemPatterns.md` |
| **Cursor** | `.cursor/rules/*.mdc` (applied via `alwaysApply` or context matching) |
| **GitHub Copilot** | `.github/copilot-instructions.md` |
| **OpenCode** | `.opencode/agents/*.md` (invoked as subagents) |
| **Any LLM** | `llms.txt`, `AGENTS.md`, `AUDIT.md` |

---

## File Descriptions

### `AGENTS.md`
The single source of truth for onboarding any AI agent. Contains:
- Project one-liner and repository links
- Exact dependency versions
- Setup commands (clone → install → configure → start)
- Daily command table
- Repository map with source directories
- Coding conventions (ReScript-first)
- Guardrails (DO NOT list)
- Testing expectations
- Commit and PR rules

### `CLAUDE.md`
Claude Code-specific. Under 200 lines. Contains:
- Read-first list
- Planning preamble
- Tool hints (rg, re:build, re:start)
- ReScript quick reference snippets

### `.cursor/rules/`
Five MDC files:
- `rescript.mdc` — always applied; ReScript style, JSX, stdlib, interop
- `tailwind.mdc` — applied on styling tasks; class ordering, no inline styles
- `feature-flags.mdc` — applied on flag-related tasks; flag list, consumption pattern
- `payments-domain.mdc` — applied on payments code; glossary, module locations
- `security.mdc` — always applied; hard prohibitions, high-risk paths

### `.github/copilot-instructions.md`
Condensed, ~60-line guide for Copilot inline suggestions. Points to `AGENTS.md` for details.

### `memory-bank/`
Cline's persistent context. Core files (300-line limit each per `.clinerules`):
- `projectbrief.md` — goals, requirements, audience
- `productContext.md` — product purpose and UX goals
- `activeContext.md` — current sprint, recent changes, next steps
- `systemPatterns.md` — architecture, data flow, component patterns
- `techContext.md` — tech stack, local setup, MCP servers
- `progress.md` — implementation status, known issues
- `architecture.md` — request lifecycle, key modules (new)
- `rescript-patterns.md` — copy-pasteable snippets (new)
- `glossary.md` — payments domain glossary (new)

### `.clinerules`
Cline's learning journal. Contains: general tool rules, memory-bank workflow, API call
recipe, commit message format, module-opening policy (`-open RescriptCore` is global).

---

## Keeping Scaffolding in Sync

When conventions change, update these files:

### If the API call pattern changes
- Update `.clinerules` (canonical source)
- Update `memory-bank/architecture.md`
- Update `memory-bank/rescript-patterns.md` (snippet)
- Update `AGENTS.md` (Adding a New API Call section)

### If new dependencies are added
- Update `AGENTS.md` Tech Stack table
- Update `CLAUDE.md` if it affects ReScript quick reference
- Update `memory-bank/techContext.md`

### If feature flags change
- Update `.cursor/rules/feature-flags.mdc`
- Update `AGENTS.md` Feature Flag Consumption section
- Update `AUDIT.md` command surface if a new npm script is added

### If a new unsafe area is identified
- Update `.cursor/rules/security.mdc` High-Risk Paths table
- Update `AGENTS.md` Guardrails section
- Update `AUDIT.md` Unsafe Areas section

### If the repository structure changes significantly
- Update `AGENTS.md` Repository Map
- Update `AUDIT.md` Source Tree Map
- Update `llms.txt` Source Entry Points section
- Update `memory-bank/architecture.md`

---

## Memory Bank File Size Rule

Per `.clinerules`: each `memory-bank/` file must stay under **300 lines**. When a file
approaches this limit:
1. Split into logical sub-files in a dedicated subdirectory
2. Create an index file summarizing the split contents
3. Update all cross-references

---

## Files to NEVER Modify Via AI Scaffolding Tasks

These files are working code and must not be touched by documentation-only tasks:
- `src/` — all ReScript source code
- `config/config.toml` — feature flag defaults
- `aws/` — deployment scripts
- `cypress/` — E2E test files
- `public/` — static assets
- `package.json`, `rescript.json`, webpack configs, Tailwind configs

---

## Cross-References

| Need | File |
|------|------|
| Full scaffolding inventory | `AUDIT.md` |
| Agent entry point | `AGENTS.md` |
| Claude-specific guide | `CLAUDE.md` |
| LLM file index | `llms.txt` |
| Architecture & request lifecycle | `memory-bank/architecture.md` |
| Copy-paste ReScript snippets | `memory-bank/rescript-patterns.md` |
| Payments glossary | `memory-bank/glossary.md` |
| Cline rules & API pattern | `.clinerules` |
| Cursor rules | `.cursor/rules/` |
| OpenCode agents | `.opencode/agents/` |
| Copilot guide | `.github/copilot-instructions.md` |
