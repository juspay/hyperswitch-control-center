---
name: playwright-test
description: Entry point for Playwright test automation. ALWAYS delegates to orchestrator.md. The orchestrator (YOU) detects execution mode (full pipeline or heal-only) and manages the complete workflow including setup, execution, summary, bug reports, and cleanup. Triggers on phrases like "generate tests", "create tests", "run tests", "test flow", "end-to-end test", "e2e test", "test PR", "test module", "test scenario", "analyze for testing", "generate test cases", "write test code", "create test file", "heal tests", "fix failing tests", "debug tests", "repair tests".
---

# Playwright Test Generation Skill

**READ `orchestrator.md` and EXECUTE its instructions directly. DO NOT delegate orchestrator.md.**

The orchestrator.md contains the full pipeline logic that YOU (the main agent) should execute. YOU are the orchestrator - you coordinate the workflow and delegate to sub-agents via task() calls.

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
    - Step 3: Delegate to _planner.md via task(subagent_type="playwright-planner")
    - Step 4: Delegate to _generator.md via task(subagent_type="playwright-generator")
    - Step 5: Run tests via CLI
    - Step 6: Delegate to _healer.md via task(subagent_type="playwright-healer") if needed
    - Step 7: Summary & Options
    ↓
Cleanup
```

---

### Execution Modes

The orchestrator automatically detects mode based on your input:

| Mode              | Trigger Phrases                                                    | What Happens                                                                   |
| ----------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| **Full Pipeline** | "generate tests", "create test", "test PR #123", "write test code" | Setup env → Plan → Generate → Run tests → Heal (if needed) → Summary → Cleanup |
| **Heal-Only**     | "fix failing tests", "fix tests", "heal tests", "repair tests"     | Setup env → Plan → Run tests → Heal → Summary → Cleanup                        |

### Sub-Agent Responsibilities

| Agent        | File              | Input              | Output             | Must Use Browser Tools           |
| ------------ | ----------------- | ------------------ | ------------------ | -------------------------------- |
| Orchestrator | `orchestrator.md` | User request       | Session management | -                                |
| Planner      | `_planner.md`     | input-context.json | test-plan.json     | **YES** - Explore page structure |
| Generator    | `_generator.md`   | test-plan.json     | \*.spec.ts         | **YES** - Verify selectors       |
| Healer       | `_healer.md`      | run-results.json   | Fixed tests        | **YES** - Debug failures         |

### **IMPORTANT** Sub-Agent Delegation Pattern (Executed by Main Agent)

The main agent (you) delegates to sub-agents using the following pattern:

```typescript
// Step 3: Delegate to playwright-planner
await task({
  mode: "subagent",
  load_skills: ["playwright-test", "playwright-planner"],
  mcp: ["playwright"],
  description: "Create test plan via playwright-planner",
  prompt: `
    You are the playwright-planner agent. Your job is to create a comprehensive test plan. 

    **MANDATORY ACTIONS:**
    1. Read: .opencode/skills/playwright-test/_planner.md for instructions.
    2. Read: .opencode/sessions/playwright-run/input-context.json
    3. Use browser tools to explore the application:
       - create a test user for exploration (if needed)
       - browser_navigate to http://localhost:9000/dashboard/login (or appropriate URL)
       - browser_snapshot to analyze page structure
       - Identify all interactive elements, forms, buttons, navigation
    4. Create test-plan.json with detailed scenarios
    
    The test plan must include:
    - Scenarios array with detailed steps
    - Selectors for elements
    - Preconditions for each test
    - Expected outcomes

    Retrieve selector strategy from skill
    Use timeouts sparsly

    After writing test-plan.json, report: "Planning complete. N scenarios created."

    **OUTPUT**: .opencode/sessions/playwright-run/test-plan.json
  `,
});

// Step 4: Delegate to playwright-generator
await task({
  mode: "subagent",
  load_skills: ["playwright-test", "playwright-generator"],
  mcp: ["playwright"],
  description: "Generate test code via playwright-generator",
  prompt: `
    You are the playwright-generator agent. Your job is to generate executable Playwright tests.
    
    **MANDATORY ACTIONS:**
    1. Read: .opencode/skills/playwright-test/_generator.md for instructions.
    2. Read: .opencode/sessions/playwright-run/test-plan.json
    3. Read relevant modules in source code to understand context (if needed)
    4. Read relevant existing tests in playwright-tests/ to understand patterns
    5. Use API helpers from support/commands.ts for setup steps (signupUser, etc.)
    6. Read existing Page Object Models in playwright-tests/support/pages/ 
    7. Use browser tools to verify selectors from the test plan actually exist:
       - create a test user for exploration (if needed)
       - browser_navigate to target page
       - browser_snapshot to verify selectors
    8. Generate test file: playwright-tests/ai-generated/{filename}.spec.ts

    After writing test files, report: "Generation complete. N tests written to {filename}."
    
    OUTPUT: playwright-tests/ai-generated/*.spec.ts
  `,
});

// Step 6: Delegate to playwright-healer - if tests fail
await task({
  mode: "subagent",
  load_skills: ["playwright-test", "playwright-healer"],
  mcp: ["playwright"],
  description: "Fix failing tests via playwright-healer",
  prompt: `
    You are the playwright-healer agent. Your job is to diagnose and fix failing tests.
    
    **MANDATORY ACTIONS:**
    1. Read: .opencode/skills/playwright-test/_healer.md for instructions.
    2. Read: .opencode/sessions/playwright-run/run-results.json
    3. Check if user prompting to test full PR, specific test case, or tests in a module. If so, focus on those tests first.
    4. Flow flow
       - Read run-results.json to identify failing tests and failure reasons ELSE run tests to get fresh results.
       - Seggregate failures by type: selector not found, timeout, assertion failure, etc.
       - Prioritize fixes that are likely to succeed (e.g. selector issues)
       - For each failure type, apply fixes.
       - Run the full flow till no failures remain or max 3 attempts reached.
       - Create a detailed report of fixes applied and remaining failures.
    
    OUTPUT: Fixed test files in playwright-tests/ai-generated/*.spec.ts

    **Common Fixes:**
    - Fix selectors: based on skill selector strategy and browser_snapshot findings
    - Add preconditions: e.g. create test user, create payments, create connectors etc
    - Add waits: await page.locator("...").waitFor({ state: "visible" })
    - Add timing: await page.waitForLoadState("networkidle")
    - Handle conditional elements: Check isVisible() before clicking
    
    **Max 3 attempts per test.**
    
    **Document fixes in comments:**
    // Fixed: Added wait for API response
    // Was failing because element rendered before data loaded
    
    After completing, report: "Healing complete. N tests fixed, M still failing"
  `,
});
```

---

## Playwright MCP Browser Tools

All sub-agents (planner, generator, healer) **MUST** use browser tools to explore and verify the application.

### Browser Tools

| Tool                             | Purpose                                           | Used By |
| -------------------------------- | ------------------------------------------------- | ------- |
| `browser_snapshot`               | PRIMARY — get page structure and element refs     | All     |
| `browser_navigate`               | Go to a URL                                       | All     |
| `browser_click`                  | Click elements using ref                          | All     |
| `browser_fill_form`              | Fill multiple form fields                         | All     |
| `browser_type`                   | Type into a single input                          | All     |
| `browser_select_option`          | Select dropdown value                             | All     |
| `browser_hover`                  | Reveal tooltips and hidden elements               | All     |
| `browser_press_key`              | Keyboard interactions                             | All     |
| `browser_wait_for`               | Wait for text, element, or time                   | All     |
| `browser_evaluate`               | Run custom JS to extract state                    | All     |
| `browser_run_code`               | Execute and validate playwright snippet instantly | All     |
| `browser_generate_locator`       | Generate stable locator from snapshot ref         | All     |
| `browser_network_requests`       | Inspect API calls                                 | All     |
| `browser_console_messages`       | Capture JS errors and logs                        | All     |
| `browser_take_screenshot`        | Visual capture for diagnosis only                 | All     |
| `browser_storage_state`          | Save auth/cookie state to file                    | All     |
| `browser_set_storage_state`      | Restore auth/cookie state from file               | All     |
| `browser_verify_element_visible` | Assert element exists                             | All     |
| `browser_verify_text_visible`    | Assert text is visible                            | All     |
| `browser_verify_value`           | Assert input or checkbox value                    | All     |

---

## Module-to-URL Mapping

| Module           | URL                          | Feature Flag | Description                      |
| ---------------- | ---------------------------- | ------------ | -------------------------------- |
| auth             | /dashboard/login             | -            | Sign in, sign up, password reset |
| home             | /dashboard/home              | -            | Homepage dashboard view          |
| payments         | /dashboard/payments          | -            | Payment operations list          |
| refunds          | /dashboard/refunds           | -            | Refund management                |
| disputes         | /dashboard/disputes          | -            | Chargeback handling              |
| payouts          | /dashboard/payouts           | -            | Payout processing (FF)           |
| customers        | /dashboard/customers         | -            | Customer management              |
| connectors       | /dashboard/connectors        | -            | Payment processor setup          |
| payoutConnectors | /dashboard/payout-connectors | -            | Payout processor setup           |
| routing          | /dashboard/routing           | -            | Payment routing rules            |
| analytics        | /dashboard/analytics         | -            | Reporting & insights             |
| users            | /dashboard/users             | -            | User management                  |
| api-keys         | /dashboard/api-keys          | -            | API key management               |
| webhooks         | /dashboard/webhooks          | -            | Webhook config (FF)              |
| settings         | /dashboard/settings          | -            | General settings                 |

---

## Selector Strategy

Priority order (highest to lowest):

1. **`getByRole()`** - Buttons, links, headings, textboxes
2. **`getByLabel()`** - Form inputs with labels
3. **`getByPlaceholder()`** - Placeholder text
4. **`getByText()`** - Visible text content
5. **`getByTestId()`** - Fallback when semantic unavailable
6. **CSS/XPath** - Last resort only

### Example

**Payments Module:**

```typescript
await page.getByRole("grid").waitFor();
await page.getByPlaceholder("Search by ID or amount").fill("pay_123");
```

---

## Authentication for Browser exploration

When exploring protected routes, sub-agents MUST authenticate first. (If already logged in (navigated to /home), logout and continue with fresh login to ensure clean session)

### Quick Auth Flow

```typescript
// 1. Check if logged in (navigate to protected route)
const nav = await browser_navigate({
  url: "http://localhost:9000/dashboard/home",
});
if (nav.url.includes("/login")) {
  // Need to authenticate

  // 2. Create test account via API
  await bash({
    command: `curl -X POST http://localhost:8080/user/signup_with_merchant_id \
      -H "Content-Type: application/json" \
      -H "api-key: test_admin" \
      -d '{"email":"test_'$(date +%s)'@example.com","password":"Test@123456","company_name":"Test Co $(date +%s)"}'`,
  });

  // 3. Login via UI
  await browser_navigate({ url: "http://localhost:9000/dashboard/login" });
  await browser_fill_form({
    fields: [
      { name: "email", type: "textbox", value: email, ref: "email-input-ref" },
      {
        name: "password",
        type: "textbox",
        value: "Test@123456",
        ref: "password-input-ref",
      },
    ],
  });
  await browser_click({ element: "Continue button", ref: "continue-btn-ref" });

  // 4. Skip 2FA if shown
  try {
    await browser_click({ element: "Skip now button", ref: "skip-now" });
  } catch (e) {
    // 2FA not shown, proceed
  }
}
```

### Happy Path test case to navigate to dashboard homepage

Navigate to homepage and start actual test steps should be added as before each step for all tests except auth

Read playwright-test/seed.spec.ts for a reference test case.

```typescript
test.beforeEach(async ({ page }) => {
  email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, page.context().request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
});
```

---

### State Management

**Session Directory:** `.opencode/sessions/playwright-run/{sessionId}/`

## STATE MACHINE RULE

Before executing any step:

1. Read session.json
2. Verify current status is in allowedTransitions
3. If status is a terminal failure state: STOP, report to user
4. Never skip a status transition
5. Write new status to session.json BEFORE executing the step
6. If step fails: write failure status, STOP immediately

{
"status": "initialized",
"allowedTransitions": {
"initialized": ["server-ready"],
"server-ready": ["planning"],
"planning": ["planning-complete", "planning-failed"],
"planning-complete": ["generating"],
"generating": ["generating-complete", "generating-failed"],
"generating-complete":["running"],
"running": ["all-pass", "some-pass", "none-pass"],
"all-pass": ["complete"],
"some-pass": ["healing"],
"none-pass": ["healing"],
"healing": ["complete", "healing-failed"]
}
}

**Session JSON Schema:**

```json
{
  "sessionId": "uuid",
  "mode": "full|heal-only",
  "status": "initialized|running|complete|failed",
  "phase": "parse|setup|planning|generating|running|healing|summary|cleanup",
  "startedAt": "ISO",
  "servers": {
    "backendWasStarted": false,
    "frontendWasStarted": false
  },
  "metrics": {
    "testsGenerated": 0,
    "testsPassed": 0,
    "testsFailed": 0,
    "fixesApplied": 0
  },
  "files": {
    "testPlan": "test-plan.json",
    "testFile": "playwright-tests/ai-generated/*.spec.ts",
    "results": "run-results.json",
    "summary": "summary.json"
  }
}
```

---

## API Helpers

Location: `playwright-tests/support/commands.ts`

```typescript
// User Management
signupUser(email: string, password: string): Promise<void>

// Merchant Setup
createAPIKey(merchantId: string, token: string): Promise<string>
createDummyConnector(merchantId: string, token: string, name: string): Promise<void>
createPayment(merchantId: string, apiKey: string): Promise<void>

// Utilities
generateUniqueEmail(): string
generateDateTimeString(): string
```

---

## File Naming

| Mode     | Pattern                      | Example                          |
| -------- | ---------------------------- | -------------------------------- |
| PR       | `PR-{number}-{slug}.spec.ts` | `PR-123-payment-form.spec.ts`    |
| Module   | `module-{name}.spec.ts`      | `module-auth.spec.ts`            |
| Scenario | `scenario-{slug}.spec.ts`    | `scenario-checkout-flow.spec.ts` |

Slug: lowercase, hyphens, max 50 chars.

---

## Troubleshooting

| Error               | Solution                              |
| ------------------- | ------------------------------------- |
| Backend DOWN        | Run `sh cypress/start_hyperswitch.sh` |
| gh not auth         | Run `gh auth login`                   |
| Test timeout        | Add `{ timeout: 10000 }`              |
| Selector not found  | Use `browser_snapshot` to discover    |
| Feature not visible | Add `page.route()` intercept          |

---

## Reference Files

| File              | Purpose                                      |
| ----------------- | -------------------------------------------- |
| `orchestrator.md` | Main coordinator - delegates to sub-agents   |
| `_planner.md`     | Creates test plans using browser exploration |
| `_generator.md`   | Generates tests with verified selectors      |
| `_healer.md`      | Fixes failures using browser debugging       |

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

## Next Step

**YOU (the main agent) must READ and EXECUTE orchestrator.md directly.**

Do NOT delegate orchestrator.md - it contains the instructions YOU should follow to coordinate the workflow. The orchestrator.md will guide you on when to delegate to sub-agents (playwright-planner, playwright-generator, playwright-healer).

**Your role:**

1. Read orchestrator.md
2. Follow its step-by-step instructions
3. Delegate planning/generation/healing to appropriate sub-agents via task() when instructed
