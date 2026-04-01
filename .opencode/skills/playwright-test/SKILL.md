---
name: playwright-test
description: Entry point for Playwright test automation. ALWAYS delegates to orchestrator.md. The orchestrator (YOU) detects execution mode (full pipeline or heal-only) and manages the complete workflow including setup, execution, summary, bug reports, and cleanup. Triggers on phrases like "generate tests", "create tests", "run tests", "test flow", "end-to-end test", "e2e test", "test PR", "test module", "test scenario", "analyze for testing", "generate test cases", "write test code", "create test file", "heal tests", "fix failing tests", "debug tests", "repair tests".
---

# Playwright Test Automation

**READ `orchestrator.md` and EXECUTE it. YOU are the orchestrator.**

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

## Execution Modes

| Mode          | Trigger Phrases                                                    | Pipeline                                           |
| ------------- | ------------------------------------------------------------------ | -------------------------------------------------- |
| **Full**      | "generate tests", "create test", "test PR #123", "write test code" | Setup → Plan → Generate → Heal → Summary → Cleanup |
| **Heal-Only** | "fix failing tests", "fix tests", "heal tests", "repair tests"     | Setup → Plan → Heal → Summary → Cleanup            |

## Sub-Agent Delegation

| Agent     | File            | Called By          | Uses Browser | Input                | Output                          |
| --------- | --------------- | ------------------ | ------------ | -------------------- | ------------------------------- |
| planner   | `_planner.md`   | Step 3             | **YES**      | `input-context.json` | `test-plan.json`                |
| generator | `_generator.md` | Step 4 (Full only) | **YES**      | `test-plan.json`     | `*.spec.ts`                     |
| healer    | `_healer.md`    | Step 5             | **YES**      | Test files           | Fixed tests, `run-results.json` |

**Sub-Agent Delegation Pattern:**

```typescript
await task({
  subagent_type: "playwright-planner|playwright-generator|playwright-healer",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "...",
  prompt:
    "Read SKILL.md for conventions. Read your .md file for instructions. Execute.",
});
```

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

## Module-to-URL Mapping

| Module            | URL                            | Prerequisites               |
| ----------------- | ------------------------------ | --------------------------- |
| auth              | `/dashboard/login`             | -                           |
| home              | `/dashboard/home`              | User                        |
| payments          | `/dashboard/payments`          | User + Connector            |
| refunds           | `/dashboard/refunds`           | User + Connector + Payment  |
| disputes          | `/dashboard/disputes`          | User + Connector + Payment  |
| connectors        | `/dashboard/connectors`        | User                        |
| payout-connectors | `/dashboard/payout-connectors` | User                        |
| routing           | `/dashboard/routing`           | User + Connector            |
| customers         | `/dashboard/customers`         | User + Payments             |
| analytics         | `/dashboard/analytics`         | User + Connector + Payments |
| users             | `/dashboard/users`             | User (admin)                |
| api-keys          | `/dashboard/api-keys`          | User                        |
| webhooks          | `/dashboard/webhooks`          | User                        |
| settings          | `/dashboard/settings`          | User                        |

## Selector Strategy (Priority Order)

1. `getByRole()` - Buttons, links, headings
2. `getByLabel()` - Form inputs
3. `getByPlaceholder()` - Placeholder text
4. `getByText()` - Visible text
5. `getByTestId()` - Fallback
6. `data-*`
7. CSS/XPath - Last resort

## API Helpers (`playwright-tests/support/commands.ts`)

```typescript
// User Management
signupUser(email, password, context): Promise<void>
loginUI(page, email, password): Promise<void>
generateUniqueEmail(): string

// Connector Setup
createDummyConnectorAPI(merchantId, label, context): Promise<void>
deleteConnector(mcaId, merchantId, token, context): Promise<void>

// Payments & Data
createPaymentAPI(merchantId, context): Promise<PaymentData>
createAPIKey(merchantId, token, context): Promise<string>

// Utilities
ompLineage(page): Promise<{orgId, merchantId, profileId}>
```

## Browser exploration - handle authentication (Sub-Agents)

Handle 2FA screen by clicking on skip button

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

## Test Setup Pattern (All Tests)

```typescript
test.beforeEach(async ({ page, context }) => {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
});
```

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

## Project Context

- **Frontend**: React + ReScript, localhost:9000
- **Backend**: Hyperswitch Rust, localhost:8080
- **Test Dir**: `playwright-tests/`
- **Generated**: `playwright-tests/ai-generated/`

## Next Step

**READ and EXECUTE `orchestrator.md`. DO NOT delegate it.**
