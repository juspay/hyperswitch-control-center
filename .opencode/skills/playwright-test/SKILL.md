---
name: playwright-test
description: Entry point for Playwright test automation. ALWAYS delegates to orchestrator.md. The orchestrator (YOU) detects execution mode (full pipeline or heal-only) and manages the complete workflow including setup, execution, summary, bug reports, and cleanup. Triggers on phrases like "generate tests", "create tests", "run tests", "test flow", "end-to-end test", "e2e test", "test PR", "test module", "test scenario", "analyze for testing", "generate test cases", "write test code", "create test file", "heal tests", "fix failing tests", "debug tests", "repair tests".
---

# Playwright Test Automation

**READ `orchestrator.md` and EXECUTE its instructions directly. YOU are the orchestrator DO NOT delegate orchestrator.md.**

The orchestrator.md contains the full pipeline logic that YOU (the main agent) should execute. YOU are the orchestrator - you coordinate the workflow and delegate to sub-agents via task() calls.

**Execution Flow:**

1. **You (main agent)** read and execute orchestrator.md instructions
2. **You** delegate planning to playwright-planner agent via task()
3. **You** delegate generation to playwright-generator agent via task()
4. **You** delegate healing to playwright-healer agent via task() if tests fail
5. **You** produce the final summary

> **ENTRY POINT - Always delegates to orchestrator.md**

### Execution Flow

```
User Request
    ↓
SKILL.md (entry point)
    ↓ (You READ orchestrator.md and EXECUTE it)
You execute orchestrator.md instructions:
    - Step 1: Parse input
    - Step 2: Environment setup
    - Step 3: Delegate to _planner.md via task(subagent_type="playwright-planner", ...)
    - Step 4: Delegate to _generator.md via task(subagent_type="playwright-generator", ...)
    - Step 5: Delegate to _healer.md via task(subagent_type="playwright-healer", ...) if tests fail
    - Step 6: Generate summary & Options
    ↓
Wait for user choice (re-run healing, end session, etc.)
```

### Sub-Agent Delegation Pattern (Executed by Main Agent)

The main agent (you) delegates to sub-agents using the following pattern:

```typescript
// Step 3: Delegate to playwright-planner
await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "playwright-planner", // Loads _planner.md instructions
  run_in_background: false,
  description: "Create test plan via playwright-planner",
  prompt: `
    You are the playwright-planner agent.
    
    Read: .opencode/sessions/playwright-run/input-context.json
    Use browser tools (Refer for navigation NAVIGATION_REFERENCE.md) to explore the app, then create test-plan.json.
    
    OUTPUT: .opencode/sessions/playwright-run/test-plan.json
  `,
});

// Step 4: Delegate to playwright-generator
await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "playwright-generator", // Loads _generator.md instructions
  run_in_background: false,
  description: "Generate test code via playwright-generator",
  prompt: `
    You are the playwright-generator agent.
    
    Read: .opencode/sessions/playwright-run/test-plan.json
    Use browser tools to verify selectors, then generate test files.
    
    OUTPUT: playwright-tests/ai-generated/*.spec.ts
  `,
});

// Step 6: Delegate to playwright-healer - if tests fail
await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "playwright-healer", // Loads _healer.md instructions
  run_in_background: false,
  description: "Fix failing tests via playwright-healer",
  prompt: `
    You are the playwright-healer agent.
    
    Read: .opencode/sessions/playwright-run/run-results.json
    Use browser tools to debug failures and fix test files.
    
    OUTPUT: Fixed test files in playwright-tests/ai-generated/*.spec.ts
  `,
});
```

## Sub-Agent Responsibilities

| Agent        | File              | Called By          | Uses Browser       | Input                | Output                          |
| ------------ | ----------------- | ------------------ | ------------------ | -------------------- | ------------------------------- |
| Orchestrator | `orchestrator.md` | User request       | Session management | No (coordinates)     |
| planner      | `_planner.md`     | Step 3             | **YES**            | `input-context.json` | `test-plan.json`                |
| generator    | `_generator.md`   | Step 4 (Full only) | **YES**            | `test-plan.json`     | `*.spec.ts`                     |
| healer       | `_healer.md`      | Step 5             | **YES**            | Test files           | Fixed tests, `run-results.json` |

## Execution Modes and flow

| Mode          | Trigger Phrases                                                    | Pipeline                                           |
| ------------- | ------------------------------------------------------------------ | -------------------------------------------------- |
| **Full**      | "generate tests", "create test", "test PR #123", "write test code" | Setup → Plan → Generate → Heal → Summary → Cleanup |
| **Heal-Only** | "fix failing tests", "fix tests", "heal tests", "repair tests"     | Setup → Plan → Heal → Summary → Cleanup            |

---

## Project Context

This project is a dashboard for managing payments, refunds, disputes, and payouts built with React + ReScript on the frontend, a Rust-based Hyperswitch backend, and a Node.js dashboard server. The Playwright test suite covers critical user flows across modules like auth, payments, refunds, disputes, customers, connectors, routing, analytics, and settings.

### Technology Stack

- **Frontend**: React + ReScript, Webpack
- **Testing**: Playwright + MCP tools
- **Backend**: Hyperswitch (Rust) on :8080
- **Dashboard**: Node.js on :9000

### URLs

- Backend API: `http://localhost:8080`
- Dashboard: `http://localhost:9000`
- Base Path: `/dashboard`

---

## Module-to-URL Mapping

| Module            | URL                             | Prerequisites               |
| ----------------- | ------------------------------- | --------------------------- |
| auth              | `/dashboard/login`              | -                           |
| home              | `/dashboard/home`               | User                        |
| payments          | `/dashboard/payments`           | User + Connector            |
| refunds           | `/dashboard/refunds`            | User + Connector + Payment  |
| disputes          | `/dashboard/disputes`           | User + Connector + Payment  |
| connectors        | `/dashboard/connectors`         | User                        |
| payout-connectors | `/dashboard/payout-connectors`  | User                        |
| routing           | `/dashboard/routing`            | User + Connector            |
| customers         | `/dashboard/customers`          | User + Payments             |
| analytics         | `/dashboard/analytics-payments` | User + Connector + Payments |
| users             | `/dashboard/users`              | User (admin)                |
| api-keys          | `/dashboard/developer-api-keys` | User                        |
| webhooks          | `/dashboard/webhooks`           | User                        |
| settings          | `/dashboard/settings`           | User                        |

---

## API Helpers (`playwright-tests/support/commands.ts`)

```typescript
// User Management
signupUser(email, password, context): Promise<void>
generateUniqueEmail(): string

// Connector Setup
createDummyConnectorAPI(merchantId, label, context): Promise<void>
deleteConnector(mcaId, merchantId, token, context): Promise<void>

// Payments & Data
createAPIKey(merchantId, token, context): Promise<string>
createDummyConnector(merchantId: string, token: string, name: string): Promise<void>
createPaymentAPI(merchantId, context): Promise<PaymentData>

// Utilities
ompLineage(page): Promise<{orgId, merchantId, profileId}>
```

---

## Browser exploration - handle authentication (Sub-Agents)

- Navigate to login page
- If already in `dashboard/home` → logout via UI
- Create a test user via `signup_with_merchant_id` API
- Handle 2FA screen by clicking on skip button

```typescript
// 1. Create user via API
await signupUser(`test_${timestamp}@example.com`, "Test@123456", context);

// 2. Login via UI
await browser_navigate({ url: "http://localhost:9000/dashboard/login" });
await browser_fill_form({
  fields: [
    { name: "email", type: "textbox", value: email, ref: "email-input" },
    {
      name: "password",
      type: "textbox",
      value: "Test@123456",
      ref: "password-input",
    },
  ],
});
await browser_click({ element: "Continue button", ref: "continue-btn" });

// 3. Handle 2FA
await browser_click({ element: "Skip now button", ref: "skip-now" });
```

---

## Playwright MCP Browser Tools

All sub-agents (planner, generator, healer) **MUST** use browser tools to explore and verify the application. Refer for navigation NAVIGATION_REFERENCE.md

## Browser Tools (All Sub-Agents)

| Tool                             | Purpose                                           |
| -------------------------------- | ------------------------------------------------- |
| `browser_navigate`               | Navigate to URL                                   |
| `browser_snapshot`               | **PRIMARY** - Get page structure and element refs |
| `browser_click`                  | Click element by ref                              |
| `browser_fill_form`              | Fill form fields                                  |
| `browser_type`                   | Type into input                                   |
| `browser_select_option`          | Select dropdown                                   |
| `browser_wait_for`               | Wait for text/element/time                        |
| `browser_console_messages`       | Capture JS errors                                 |
| `browser_network_requests`       | Inspect API calls                                 |
| `browser_generate_locator`       | Generate stable locator                           |
| `browser_verify_element_visible` | Assert visibility                                 |

---

## Selector Strategy (Priority Order)

1. `getByRole()` - Buttons, links, headings
2. `getByLabel()` - Form inputs
3. `getByPlaceholder()` - Placeholder text
4. `getByText()` - Visible text
5. `getByTestId()` - Fallback
6. `data-*`
7. CSS/XPath - Last resort

### Example

**Payments Module:**

```typescript
await page.getByRole("grid").waitFor();
await page.getByPlaceholder("Search by ID or amount").fill("pay_123");
```

---

## Page Object Models

Location: `playwright-tests/support/pages/`

| Page              | Path                                        | Key Elements                              |
| ----------------- | ------------------------------------------- | ----------------------------------------- |
| SignInPage        | `auth/SignInPage.ts`                        | emailInput, passwordInput, continueButton |
| SignUpPage        | `auth/SignUpPage.ts`                        | signupForm, emailInput, passwordInput     |
| HomePage          | `homepage/HomePage.ts`                      | sidebar, dashboardElements                |
| PaymentOperations | `operations/PaymentOperations.ts`           | paymentList, filters, search              |
| PaymentConnector  | `connector/PaymentConnector.ts`             | connectorSearch, addButton, config        |
| PaymentRouting    | `workflow/paymentRouting/PaymentRouting.ts` | routingRules, volumeConfig                |

**Pattern:**

```typescript
export class PageName {
  constructor(readonly page: Page) {}
  get elementName(): Locator {
    return this.page.locator("[data-testid='...']");
  }
}
```

---

## State Machine

Pipeline state is tracked in `session.json` using the `phase` field:

### Valid Phases

```json
[
  "parse",
  "setup",
  "planning",
  "planning-complete",
  "generating",
  "generating-complete",
  "healing",
  "healing-complete",
  "awaiting-user-choice",
  "cleanup",
  "complete",
  "failed"
]
```

### Phase Flows

| Mode          | Flow                                                                                                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Full**      | `parse` → `setup` → `planning` → `planning-complete` → `generating` → `generating-complete` → `healing` → `healing-complete` → `awaiting-user-choice` → `cleanup` → `complete` |
| **Heal-Only** | `parse` → `setup` → `planning` → `planning-complete` → `healing` → `healing-complete` → `awaiting-user-choice` → `cleanup` → `complete`                                        |

### Allowed Transitions

```json
{
  "parse": ["setup", "failed"],
  "setup": ["planning", "failed"],
  "planning": ["planning-complete", "failed"],
  "planning-complete": ["generating", "healing", "failed"],
  "generating": ["generating-complete", "failed"],
  "generating-complete": ["healing", "failed"],
  "healing": ["healing-complete", "failed"],
  "healing-complete": ["awaiting-user-choice", "failed"],
  "awaiting-user-choice": ["cleanup"],
  "cleanup": ["complete"],
  "failed": []
}
```

**Status Field:**

- `"in_progress"` - Pipeline running
- `"failed"` - Step failed, pipeline stopped
- `"complete"` - All steps finished

## File Naming

| Mode     | Pattern                      | Example                       |
| -------- | ---------------------------- | ----------------------------- |
| PR       | `PR-{number}-{slug}.spec.ts` | `PR-123-payment-form.spec.ts` |
| Module   | `module-{name}.spec.ts`      | `module-auth.spec.ts`         |
| Scenario | `scenario-{slug}.spec.ts`    | `scenario-checkout.spec.ts`   |

## Session Files

Location: `.opencode/sessions/playwright-run/`

| File                 | Purpose                  |
| -------------------- | ------------------------ |
| `input-context.json` | Parsed user request      |
| `session.json`       | Pipeline state & metrics |
| `test-plan.json`     | Planner output           |
| `run-results.json`   | Test execution results   |
| `bug-report.md`      | Failure analysis         |
| `summary.json`       | Final summary            |

### Session Schema

```json
{
  "sessionId": "uuid",
  "mode": "full|heal-only",
  "status": "in_progress|failed|complete",
  "phase": "parse|setup|...",
  "startedAt": "ISO",
  "servers": {
    "backendWasStarted": false,
    "frontendWasStarted": false
  },
  "metrics": {
    "testsPlanned": 0,
    "testsGenerated": 0,
    "testsPassed": 0,
    "testsFailed": 0,
    "testsFixed": 0,
    "healingAttempts": 0
  }
}
```

## Common Fixes Reference

| Issue              | Fix                                                       |
| ------------------ | --------------------------------------------------------- |
| Selector not found | `await page.locator("...").waitFor({ state: "visible" })` |
| Timing issue       | `await page.waitForLoadState("networkidle")`              |
| API dependent      | `await page.waitForResponse("**/api/...")`                |
| Feature flag       | Route intercept to enable feature                         |
| Optional element   | `if (await element.isVisible().catch(() => false))`       |

---

## Reference Files

| File              | Purpose                                      |
| ----------------- | -------------------------------------------- |
| `orchestrator.md` | Main coordinator - delegates to sub-agents   |
| `_planner.md`     | Creates test plans using browser exploration |
| `_generator.md`   | Generates tests with verified selectors      |
| `_healer.md`      | Fixes failures using browser debugging       |

---

## File Editing Guidelines for All Agents

When any agent in this skill modifies files, **ALWAYS use surgical edits**:

- **Use `edit` tool** with precise `oldString`/`newString` to change only what needs changing
- **Preserve existing content** - never overwrite entire files just to update a field or fix a test
- **Target specific sections** - modify only the failing test case, the field that changed, or the line that needs updating
- **NEW files only** - use `write` only when creating files that don't exist

This applies to:

- `session.json` updates (change only the phase/metrics fields)
- `test-plan.json` updates (append scenarios, don't rewrite)
- Test files (fix only broken tests, preserve working ones)
- Page objects (add methods/locators, don't regenerate classes)

## Next Step

**YOU (the main agent) must READ and EXECUTE orchestrator.md directly.**

Do NOT delegate orchestrator.md - it contains the instructions YOU should follow to coordinate the workflow. The orchestrator.md will guide you on when to delegate to sub-agents (playwright-planner, playwright-generator, playwright-healer).

**Your role:**

1. Read orchestrator.md
2. Follow its step-by-step instructions
3. Delegate planning/generation/healing to appropriate sub-agents via task() when instructed
