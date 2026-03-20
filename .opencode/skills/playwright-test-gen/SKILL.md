---
name: playwright-test-gen
description: Generate Playwright E2E tests using plan-generate-heal pipeline for PRs, tags, modules, or custom scenarios. Triggers on "generate playwright tests for PR #123", "create playwright tests for module:auth", "generate playwright tests for scenario:user logs in", "test tag:v1.2.0 with playwright".
---

# Playwright Test Generation Skill

You generate Playwright E2E tests on demand using a plan-generate-heal pipeline powered by the Playwright MCP server. You follow exact test patterns from this repo and always ask the user before committing or pushing.

> **Quick ref:** Parse mode → Read infra files → Check duplicates → Plan (via planner agent) → Generate (via generator agent) → Heal (via healer agent) → Show output + ask user → Commit/push only after confirmation.
> **Output:** `playwright-tests/ai-generated/` (tests) | `playwright-tests/specs/` (test plans)
> **Key rule:** Let MCP discover selectors at runtime — no hardcoding. Fresh user per test via API helpers.

## Workflow Overview

```
User Request → Parse Input → Read SKILL.md
    ↓
[Setup Phase]
├── Create working directory
├── Write input-context.md
├── Start Backend Server → Health Check
├── Start Frontend Server → Health Check
└── Update status
    ↓
[Planning Phase - Delegate to Planner Agent]
├── Read input-context.md
├── Explore UI via MCP
├── Create test-plan.md
└── Update status → planning-complete
    ↓
[Generation Phase - Delegate to Generator Agent]
├── Read test-plan.md
├── Discover selectors
├── Generate .spec.ts file
├── Generate locators file
└── Update status → generation-complete
    ↓
[Run & Heal Loop - Delegate to Healer Agent]
├── Run generated test (scoped to file only)
├── Capture run-results.md
├─┬─ If FAIL: Delegate to Healer
│ ├── Diagnose failures
│ ├── Fix failing tests only (don't touch passing tests)
│ └── Re-run
│ ←─── Repeat until all tests PASS or max 3 attempts
└── Update status → ready-for-summary
    ↓
[Cleanup Phase]
├── Stop Frontend Server
├── Stop Backend Server (if we started it)
└── Generate summary.md
    ↓
[User Decision Phase]
└── Present summary + ask user for next step
```

## File Handoff Structure

```
.opencode/playwright-run/
├── input-context.md       ← Written by orchestrator: normalized user input
├── test-plan.md           ← Written by planner: structured scenarios
├── run-results.md         ← Written by healer: test execution results
├── status.md              ← Updated by all phases: current state
├── summary.md             ← Written by orchestrator: final report
└── locators/
    └── {module}.locators.ts   ← Written by generator: discovered selectors
```

---

## Phase 0: Parse and Initialize

### Step 0: Parse the Prompt

Detect the mode from the user's message:

| Pattern          | Mode         | Example                                                    |
| ---------------- | ------------ | ---------------------------------------------------------- |
| `#123` or PR URL | **pr**       | `generate playwright tests for #42`                        |
| Multiple `#N`    | **pr-batch** | `generate playwright tests for #42 #55 #78`                |
| `tag:<name>`     | **tag**      | `generate playwright tests for tag:2026.03.14`             |
| `module:<name>`  | **module**   | `generate playwright tests for module:payment-operations`  |
| Free text        | **scenario** | `generate playwright tests for "user creates a connector"` |

Print: `=== Playwright Test Generation === Mode: <mode> Target: <target>`

### Step 0.2: Create Working Directory

```bash
mkdir -p .opencode/playwright-run/locators
```

### Step 0.3: Write Input Context

Create **`.opencode/playwright-run/input-context.md`**:

```markdown
# Input Context

## User Request

{raw user input}

## Parsed

- **Mode:** {pr/pr-batch/tag/module/scenario}
- **Target:** {#123/name/description}
- **Inferred Scope:** {what to test}
- **Input Type:** {explicit/implicit}

## Timestamp

{ISO timestamp}

## Skill Reference

- File: `.opencode/skills/playwright-test-gen/SKILL.md`
- Key conventions: [list relevant ones]
```

### Step 0.4: Initialize Status

Create **`.opencode/playwright-run/status.md`**:

```markdown
# Run Status

**Status:** initialized
**Started:** {timestamp}
**Phase:** setup
```

---

## Phase 1: Server Management & Gather Context

### Step 1.1: Check Backend Health

```bash
curl -s http://localhost:8080/health || echo "BACKEND_DOWN"
```

**If DOWN:**

1. Check if start script exists: `ls cypress/start_hyperswitch.sh`
2. Run: `sh cypress/start_hyperswitch.sh`
3. Wait loop: Poll health every 5s, max 120s
4. If still DOWN: Report error and STOP

### Step 1.2: Start Frontend Server

The Playwright webServer config auto-starts, but verify:

```bash
curl -s http://localhost:9000 || echo "FRONTEND_DOWN"
```

**If DOWN:**

1. Check for dev server script in package.json
2. Start: `npm run start` or `npm run dev` (background)
3. Wait loop: Poll every 2s, max 30s
4. If still DOWN: Report warning but continue (may start via webServer)

### Step 1.3: Read Test Infrastructure (ALWAYS)

Read ALL of these files to discover configuration, helpers, and patterns:

| File / Directory                                      | What to learn                                                    |
| ----------------------------------------------------- | ---------------------------------------------------------------- |
| `playwright.config.ts`                                | Base URL, webServer, testIgnore, screenshot settings             |
| `playwright-tests/helpers/api.ts`                     | API helper functions (signupUser, loginUser, createAPIKey, etc.) |
| `playwright-tests/specs/mcp-contract-verification.md` | MCP tool behavior and parameters                                 |
| `playwright-tests/ai-generated/*.spec.ts`             | Existing generated tests (if any)                                |
| `.opencode/prompts/playwright-test-planner.md`        | Planner agent prompt with Hyperswitch context                    |
| `.opencode/prompts/playwright-test-generator.md`      | Generator agent prompt with test patterns                        |
| `.opencode/prompts/playwright-test-healer.md`         | Healer agent prompt with debugging guidance                      |

### Step 1.4: Mode-Specific Context

**PR / PR-batch:** Fetch PR metadata and diff via `gh pr view` and `gh pr diff`. Read FULL source files touched by the PR to understand UI changes, new components, and data-\* attributes.

**Tag:** Find previous tag via `git tag --sort=-creatordate`, get merge commits between tags, extract PR numbers, then run PR mode for each. Max 10 PRs per batch — summarize if more.

**Module:** Map module name to dashboard URLs. See the full module list below.

**Scenario:** Grep/glob for components mentioned in the scenario text.

### Dashboard Modules

Map `module:<name>` to source paths and dashboard URLs.

- **Operations:**
  - `payments` → `/dashboard/payments` → `src/**/Payment*`, `src/**/Orders*`
  - `refunds` → `/dashboard/refunds` → `src/**/Refund*`
  - `disputes` → `/dashboard/disputes` → `src/**/Dispute*`
  - `payouts` → `/dashboard/payouts` → `src/**/Payout*`
  - `customers` → `/dashboard/customers` → `src/**/Customer*`

- **Connectors:**
  - `payment-processors` → `/dashboard/connectors` → `src/**/Connector*`, `src/**/PaymentProcessor*`
  - `payout-processors` → `/dashboard/payout-connectors` → `src/**/PayoutConnector*`
  - `3ds-authenticators` → `/dashboard/3ds-authenticators` → `src/**/ThreeDsAuthenticator*`
  - `fraud-risk` → `/dashboard/fraud-risk` → `src/**/FRM*`, `src/**/FraudRisk*`

- **Analytics:**
  - `analytics-payments` → `/dashboard/analytics-payments` → `src/**/Analytics*Payment*`
  - `analytics-refunds` → `/dashboard/analytics-refunds` → `src/**/Analytics*Refund*`
  - `analytics-disputes` → `/dashboard/analytics-disputes` → `src/**/Analytics*Dispute*`

- **Workflow:**
  - `routing` → `/dashboard/routing` → `src/**/Routing*`
  - `surcharge` → `/dashboard/surcharge` → `src/**/Surcharge*`
  - `3ds-decision` → `/dashboard/3ds-decision` → `src/**/ThreeDS*Decision*`

- **Developers:**
  - `payment-settings` → `/dashboard/payment-settings` → `src/**/PaymentSettings*`
  - `api-keys` → `/dashboard/api-keys` → `src/**/APIKeys*`
  - `webhooks` → `/dashboard/webhooks` → `src/**/Webhook*`

- **Settings:**
  - `users` → `/dashboard/users` → `src/**/Users*`
  - `configure-pmts` → `/dashboard/configure-pmts` → `src/**/ConfigurePMTs*`
  - `compliance` → `/dashboard/compliance` → `src/**/Compliance*`

- **Auth:**
  - `auth` → `/dashboard/login`, `/dashboard/register` → `src/**/Auth*`, `src/**/Login*`, `src/**/SignIn*`

If the module name doesn't match any of the above, list these options and ask the user to pick.

### Step 1.5: Update Status

```markdown
# Run Status

**Status:** servers-ready
**Backend:** {url/status}
**Frontend:** {url/status}
**Phase:** planning
```

---

## Phase 2: Check for Duplicates

```bash
ls playwright-tests/ai-generated/PR-<NUMBER>-*.spec.ts 2>/dev/null
ls playwright-tests/ai-generated/module-<name>*.spec.ts 2>/dev/null
ls playwright-tests/ai-generated/scenario-*.spec.ts 2>/dev/null
```

If found, inform the user the file will be overwritten.

---

## Phase 3: Plan (Invoke Planner Agent)

Use the `playwright-test-planner` agent to explore the UI and create a test plan.

### Step 3.1: Invoke Planner

**Agent:** `playwright-test-planner`

**Inputs provided to agent:**

- `input-context.md` location
- Working directory: `.opencode/playwright-run/`

**Planner workflow:**

1. Calls `planner_setup_page` with target URL
2. Uses `browser_*` tools to explore and discover elements
3. Creates test scenarios covering: happy path, validation, error handling, navigation
4. Saves plan using `planner_save_plan` to `playwright-tests/specs/{mode}-{slug}.md`

**Plan output location:**

- PR: `playwright-tests/specs/PR-{number}-{slug}.md`
- Module: `playwright-tests/specs/module-{name}.md`
- Scenario: `playwright-tests/specs/scenario-{slug}.md`

**Plan must include:**

- Scenario titles
- Step-by-step instructions (specific enough for generator)
- Expected outcomes
- Data/state requirements

### Step 3.2: Verify Output

Check that `.opencode/playwright-run/test-plan.md` exists and has:

- [ ] Source reference
- [ ] Mode and target
- [ ] At least one scenario with steps
- [ ] Expected outcomes
- [ ] Data/state requirements

If missing: Report error and STOP

---

## Phase 4: Generate (Invoke Generator Agent)

Use the `playwright-test-generator` agent to create the test file from the plan.

### Step 4.1: Invoke Generator

**Agent:** `playwright-test-generator`

**Inputs provided to agent:**

- `test-plan.md` location
- `input-context.md` for context
- Output directory: `playwright-tests/ai-generated/`
- Locators directory: `.opencode/playwright-run/locators/`

**Generator workflow:**

1. Reads the plan file
2. Calls `generator_setup_page` with target URL
3. Executes each step using `browser_*` tools
4. Reads the execution log with `generator_read_log`
5. Writes test file using `generator_write_test`

### Step 4.2: Test File Output Location

- PR: `playwright-tests/ai-generated/PR-{number}-{slug}.spec.ts`
- Module: `playwright-tests/ai-generated/module-{name}.spec.ts`
- Scenario: `playwright-tests/ai-generated/scenario-{slug}.spec.ts`

### File naming rules

- Slug: lowercase, hyphens, max 50 chars
- All test files go in `playwright-tests/ai-generated/`

### Header comment (required on every file)

```typescript
/**
 * Auto-generated Playwright test
 * Source: <PR #42 - title / module:name / scenario description>
 * Generated: <YYYY-MM-DD>
 * This test was auto-generated and may need manual adjustments.
 */
```

### Imports and setup (follow existing patterns)

```typescript
import { test, expect } from "@playwright/test";
import { signupUser, loginUser, generateUniqueEmail } from "../helpers/api";

test.beforeEach(async ({ page }) => {
  const email = generateUniqueEmail();
  const password = "Test@123";
  await signupUser(email, password);
  const { token, merchantId } = await loginUser(email, password);

  // If feature-flagged, enable before navigation
  // await page.route("/dashboard/config/feature*", async (route) => {
  //   const response = await route.fetch();
  //   const json = await response.json();
  //   json.features.feature_name = true;
  //   await route.fulfill({ response, json });
  // });

  // Navigate to target page
  await page.goto("/dashboard/target");
});
```

When the PR or module involves a feature-flagged page (payouts, 3DS, fraud-risk, webhooks, etc.), **uncomment and adapt** the route block above.

### Selector priority

Pick the highest available tier. Let MCP discover selectors at runtime via `browser_snapshot` — never hardcode from memory.

| Tier | Selector                       | When to use                                                                           |
| ---- | ------------------------------ | ------------------------------------------------------------------------------------- |
| 1    | `[data-testid="..."]`          | Default choice for any element                                                        |
| 2    | Other `[data-*]` attributes    | `data-button-for`, `data-component`, `data-table-location`, `data-icon`, `data-toast` |
| 3    | `[name="..."]` or `#id`        | Form fields, only when no `data-*` attributes exist                                   |
| 4    | `page.getByText("exact text")` | Text-based, when element has no targetable attributes                                 |
| 5    | CSS class/tag                  | **Last resort only** — add `// TODO: replace with data-testid`                        |

### Test structure rules

1. **test.describe block** MUST include source: `test.describe("Payment Filters - PR #42", () => { ... })`
2. **API-first setup**: Create data via API helpers, not UI:
   ```typescript
   const { token, merchantId } = await loginUser(email, password);
   await createDummyConnector(merchantId, token, "test_connector");
   await createPayment(merchantId, apiKey);
   ```
3. **Navigation**: Use `page.goto("/dashboard/path")` or discovered selectors
4. **Assertions**: Use Playwright-idiomatic:
   - `expect(locator).toBeVisible()`
   - `expect(page).toHaveURL(/\/dashboard\/path/)`
   - `expect(locator).toHaveText("expected")`
5. **Timeouts**: Explicit for slow elements: `{ timeout: 10000 }` — default 5s may be too short for API-dependent renders
6. **Locator API**: Always use locator methods (auto-waiting) instead of `page.$()` (no auto-wait)

### What to test — generate tests covering these categories

| Category             | What to test                      | Example                               |
| -------------------- | --------------------------------- | ------------------------------------- |
| Component visibility | All UI elements render            | Headings, buttons, inputs, cards      |
| Happy path           | Primary flow works end-to-end     | Create, save, activate                |
| Validation           | Form validation catches bad input | Invalid email, empty required fields  |
| Empty state          | Behavior when no data exists      | "No results found" message            |
| Error handling       | Graceful failure handling         | API errors, invalid credentials       |
| Navigation           | Links and routing work            | URL assertions, sidebar nav           |
| Data display         | Tables/lists show correct data    | Column values match expected          |
| Interaction          | Modals, dropdowns, filters work   | Open/close modal, apply/clear filters |

### What NOT to test

Pure backend/API changes, config files, docs, CI changes, type-only changes.

### API host distinction

- Backend API (user signup, connectors, payments): `http://localhost:8080`
- Dashboard Base URL: `http://localhost:9000`

### Step 4.3: Verify Output

Check that:

- [ ] `.spec.ts` file exists in `playwright-tests/ai-generated/`
- [ ] Locators file exists (if applicable)
- [ ] File has proper header comment
- [ ] File imports from `../helpers/api`

If missing: Report error and STOP

---

## Phase 5: Run & Heal Loop (CRITICAL: Iterate Until All Pass)

### Step 5.1: First Test Run (Delegate to Healer Agent)

**Agent:** `playwright-test-healer`

**Inputs provided to agent:**

- Test file path: `playwright-tests/ai-generated/{filename}.spec.ts`
- Locators file (if exists): `.opencode/playwright-run/locators/{module}.locators.ts`
- Status file: `.opencode/playwright-run/status.md`

**MUST DO (for healer agent):**

1. Read `status.md` (should be `generation-complete`)
2. Read `test-plan.md` for reference
3. Run `test_run` ONLY on the generated file:
   ```
   test_run({
     file_path: "playwright-tests/ai-generated/{filename}.spec.ts"
   })
   ```
4. Write `run-results.md` with results
5. **If ALL PASS:** Update `status.md` to `healing-complete`, STOP
6. **If ANY FAIL:** Proceed to healing

### Step 5.2: Healing Loop (Max 3 Attempts)

**WHILE** status != `healing-complete` AND attempts < 3:

1. **Delegate to healer agent** with:
   - Current test failures from `run-results.md`
   - Attempt number: N of 3

2. **Healer MUST DO:**
   - Run `test_debug` on failing tests only
   - Use `browser_snapshot`, `browser_console_messages` to diagnose
   - Analyze failure type (stale selector, feature flag, timeout, etc.)
   - **Fix ONLY failing tests** - never touch passing tests
   - Use `edit` tool to update the test file
   - Update locators file if selector changed
   - Re-run with `test_run`
   - Update `run-results.md`

3. **After healing attempt:**
   - Read `run-results.md` for new status
   - If ALL PASS: Update `status.md` to `healing-complete`, exit loop
   - If STILL FAIL: Increment attempt counter, continue loop

### Common failure patterns (healer should handle)

- **Stale selector**: Element re-rendered — re-query with fresh locator
- **Feature flag not active**: Ensure `page.route()` intercept registered BEFORE navigation
- **2FA redirect**: Handle via API token flow or skip endpoint
- **API timeout**: Increase `{ timeout: 10000 }` on assertions
- **Element detached**: Use locator API (auto-waiting), not `page.$()`

### test.fixme() rules

Only mark as `test.fixme()` after 3+ fix attempts. Always add comment explaining what the app does instead of expected behavior.

### Step 5.3: Handle Persistent Failures (After 3 Attempts)

If still failing after 3 healing attempts:

1. **Delegate to healer agent** to mark fixme:
   - Add `test.fixme()` to failing tests
   - Add detailed comment explaining why
   - Update `run-results.md`:
     ```markdown
     **Status:** PARTIAL (some tests marked as fixme)
     **Fixme Tests:** [list]
     **Reason:** [explanation per test]
     ```

2. Update `status.md` to `healing-complete-with-fixme`

---

## Phase 6: Cleanup

### Step 6.1: Stop Servers

**Stop Frontend:**

- Find PID: `lsof -ti:9000` or `pgrep -f "npm run start"`
- Kill: `kill {pid}` or `pkill -f "npm run start"`

**Stop Backend (ONLY if we started it):**

- If we ran `start_hyperswitch.sh`, run cleanup
- Otherwise leave running

### Step 6.2: Update Status

```markdown
# Run Status

**Status:** ready-for-summary
**Servers:** stopped
**Phase:** completing
```

---

## Phase 7: Generate Summary & Present to User

### Step 7.1: Collect All Data

Read:

- `input-context.md` - original request
- `test-plan.md` - what was planned
- `run-results.md` - actual results
- `status.md` - final status

### Step 7.2: Write Summary

**`.opencode/playwright-run/summary.md`**:

```markdown
# Playwright Test Generation Summary

## Request

- **Mode:** {pr/module/scenario/tag}
- **Target:** {#123/module-name/description}
- **Timestamp:** {start time}
- **Duration:** {total time}

## Test Plan

- **File:** `playwright-tests/specs/{name}.md`
- **Scenarios:** {count}
- **Priority:** {high/medium/low mix}

## Generated Files

- **Test File:** `playwright-tests/ai-generated/{name}.spec.ts`
- **Locators:** `.opencode/playwright-run/locators/{module}.locators.ts`
- **Lines of Code:** {approx}

## Test Results

- **Status:** {all-pass / partial / failed}
- **Total Tests:** {count}
- **Passed:** {count}
- **Failed:** {count}
- **Fixme:** {count} (if applicable)

## Details

{test-by-test breakdown}

## Notes

- Server management: {started/stopped}
- Healing attempts: {count}
- Persistent issues: {if any}
```

### Step 7.3: Show Summary

Display:

```
=== Playwright Test Generation Complete ===

Mode: {mode}
Target: {target}
Status: {status}
Files Generated:
  - playwright-tests/ai-generated/{name}.spec.ts
  - playwright-tests/specs/{name}.md (test plan)
  - .opencode/playwright-run/locators/{module}.locators.ts

Test Results: {X passed, Y failed, Z fixme}
Duration: {time}
```

### Step 7.4: Ask User for Next Step

```
What would you like to do next?

1. **Commit tests to current branch**
   → git add playwright-tests/ai-generated/ playwright-tests/specs/
   → git commit -m "test(playwright): add tests for {target}"

2. **Create new branch and raise PR**
   → git checkout -b test/playwright-{target}
   → git add playwright-tests/ai-generated/ playwright-tests/specs/
   → git commit -m "test(playwright): add tests for {target}"
   → git push -u origin HEAD
   → gh pr create --title "test: playwright tests for {target}"

3. **Clean up and start over**
   → rm -rf .opencode/playwright-run/
   → rm playwright-tests/ai-generated/{name}.spec.ts
   → rm playwright-tests/specs/{name}.md

4. **Do nothing** (keep files as-is for manual review)

Please reply with the number (1, 2, 3, or 4):
```

---

## Playwright Folder Structure

```
playwright-tests/
├── ai-generated/              # Auto-generated tests go here
│   ├── PR-*.spec.ts
│   ├── module-*.spec.ts
│   └── scenario-*.spec.ts
├── specs/                     # Test plans from planner
│   ├── PR-*.md
│   ├── module-*.md
│   └── scenario-*.md
├── helpers/
│   └── api.ts                 # API helper functions
├── example.spec.ts            # Example test — NEVER modify
├── signinpage.spec.ts         # Signin test — NEVER modify
└── seed.spec.ts               # Seed test — NEVER modify
playwright.config.ts           # Config with baseURL, webServer, testIgnore
```

---

## Error Handling & Troubleshooting

### Tool/input errors:

- `gh` not authenticated → tell user to run `gh auth login`
- PR/tag not found → report clearly with available alternatives
- No testable UI changes → skip with reason
- Module not recognized → list available modules and ask user to pick
- No `data-*` attributes found in source → use text-based selectors, add warning comment
- Git push fails → report error with guidance

### Backend Not Starting

```
Backend failed to start after 120s.
Options:
1. Check if hyperswitch is already running elsewhere
2. Run backend manually: [instructions]
3. Skip backend (if testing non-API features)
```

### PR Not Found

```
PR #{number} not found.
Recent PRs:
{list recent 5}

Please verify the PR number and try again.
```

### No UI Changes Detected

```
PR #{number} has no testable UI changes.
Changed files: [list]

Options:
1. Generate tests anyway (coverage)
2. Skip this PR
```

### Generator Failed

```
Test generation failed.
Error: [details]

Plan file location: .opencode/playwright-run/test-plan.md
Please review the plan and retry.
```

### Healer Max Attempts Reached

```
Could not fix all test failures after 3 attempts.

Failed tests marked with test.fixme():
- [list]

These tests need manual review.
```

### Common test failures:

- **Stale selector** → selector exists in source but test fails: the component may render conditionally. Add `{ timeout: 10000 }` or guard with `.toBeVisible()` before interacting.
- **Element detached from DOM** → re-query the element instead of caching: use `page.locator(...)` again rather than storing references.
- **Feature flag intercept not firing** → ensure the intercept is registered BEFORE `page.goto()` triggers the navigation that loads the config endpoint.
- **Auth failures** → verify `signupUser`/`loginUser` from `helpers/api.ts` are working correctly.

---

## Key Rules

**File modification boundaries:**

- **NEVER** modify `playwright-tests/example.spec.ts`, `signinpage.spec.ts`, or `seed.spec.ts`
- **NEVER** create page objects — selectors are discovered at runtime via MCP
- **NEVER** use `storageState` for auth — fresh user per test via API helpers
- **ONLY** edit files in `playwright-tests/ai-generated/` (healer scope restriction)

**Test generation rules:**

- ALWAYS use `test.beforeEach` with `signupUser` + `loginUser` for fresh user isolation
- ALWAYS use `../helpers/api` relative import path (tests are 1 level deep in `ai-generated/`)
- ALWAYS scope `test_run` to the target file only (never run all tests)
- For PR-batch/tag modes, generate ONE test file per PR
- ALWAYS ask user before committing, pushing, or creating PRs

**Key Orchestrator Rules:**

1. **ALWAYS read SKILL.md first** - Follow project conventions exactly
2. **NEVER run all tests** - Always scope to the generated file only
3. **ALWAYS iterate healing until all pass** - Max 3 fix attempts, then mark fixme
4. **NEVER touch passing tests** - Healer only fixes failures
5. **ALWAYS start/stop servers cleanly** - Don't leave zombie processes
6. **ALWAYS ask before git operations** - Never commit/push automatically
7. **NEVER modify existing tests** - Only ai-generated/ directory
8. **ALWAYS use fresh users per test** - Via signupUser/loginUser API helpers

**MCP tool usage:**

- Planner uses: `planner_setup_page`, `planner_save_plan`, `browser_*` tools
- Generator uses: `generator_setup_page`, `generator_write_test`, `generator_read_log`, `browser_*` tools
- Healer uses: `test_run`, `test_debug`, `test_list`, `browser_*` tools, `edit` tool

**Max batch size:**

- PR-batch and tag modes: max 10 PRs per invocation
- If more than 10, process first 10 and summarize the rest

---

## Commands Reference

### Direct Commands (orchestrator runs these):

```bash
# Health checks
curl http://localhost:8080/health
curl http://localhost:9000

# Server management
sh cypress/start_hyperswitch.sh  # Start backend
kill $(lsof -ti:9000)            # Stop frontend

# Git operations
git add playwright-tests/ai-generated/ playwright-tests/specs/
git commit -m "..."
git push -u origin HEAD

# Cleanup
rm -rf .opencode/playwright-run/
```

### Agent Delegation (MUST use task()):

```typescript
Planner: task(subagent_type="playwright-test-planner", ...)
Generator: task(subagent_type="playwright-test-generator", ...)
Healer: task(subagent_type="playwright-test-healer", ...)
```
