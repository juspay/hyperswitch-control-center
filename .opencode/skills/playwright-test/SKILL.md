---
name: playwright-test
description: Entry point for Playwright test automation. ALWAYS delegates to orchestrator.md. The orchestrator (YOU) detects execution mode (full pipeline, plan-only, generate-only, or heal-only) and manages the complete workflow including setup, execution, summary, bug reports, and cleanup. Triggers on phrases like "generate playwright tests", "create playwright tests", "run playwright tests", "playwright test flow", "end-to-end test", "e2e test", "test PR", "test module", "test scenario", "plan tests", "create test plan", "analyze for testing", "generate test cases", "write test code", "create test file", "heal tests", "fix failing tests", "debug playwright", "repair tests".
---

# Playwright Test Generation Skill

**READ `orchestrator.md` and EXECUTE its instructions directly. DO NOT delegate orchestrator.md.**

The orchestrator.md contains the full pipeline logic that YOU (the main agent) should execute. YOU are the orchestrator - you coordinate the workflow and delegate to sub-agents via task() calls.

**Execution Flow:**

1. **You (main agent)** read and execute orchestrator.md instructions
2. **You** delegate planning to metis agent via task()
3. **You** delegate generation to hep agent via task()
4. **You** delegate healing to momus agent via task() when needed
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
    - Step 3: Delegate to _planner.md via task(subagent_type="metis", ...)
    - Step 4: Delegate to _generator.md via task(subagent_type="momus", ...)
    - Step 5: Run tests via CLI
    - Step 6: Delegate to _healer.md via task(subagent_type="momus", ...) if needed
    - Step 7: Generate summary
    ↓
Summary & Options
```

### Sub-Agent Delegation Pattern (Executed by Main Agent)

The main agent (you) delegates to sub-agents using the following pattern:

```typescript
// Step 3: Delegate to playwright-planner (metis)
await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "metis", // Loads _planner.md instructions
  run_in_background: false,
  description: "Create test plan via playwright-planner",
  prompt: `
    You are the playwright-planner agent.
    
    Read: .opencode/sessions/playwright-run/input-context.json
    Use browser tools to explore the app, then create test-plan.json.
    
    OUTPUT: .opencode/sessions/playwright-run/test-plan.json
  `,
});

// Step 4: Delegate to playwright-generator (momus)
await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "momus", // Loads _generator.md instructions
  run_in_background: false,
  description: "Generate test code via playwright-generator",
  prompt: `
    You are the playwright-generator agent.
    
    Read: .opencode/sessions/playwright-run/test-plan.json
    Use browser tools to verify selectors, then generate test files.
    
    OUTPUT: playwright-tests/ai-generated/*.spec.ts
  `,
});

// Step 6: Delegate to playwright-healer (momus) - if tests fail
await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "momus", // Loads _healer.md instructions
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

### Sub-Agent Responsibilities

| Agent        | File              | Input              | Output             | Must Use Browser Tools           |
| ------------ | ----------------- | ------------------ | ------------------ | -------------------------------- |
| Orchestrator | `orchestrator.md` | User request       | Session management | No (coordinates)                 |
| Planner      | `_planner.md`     | input-context.json | test-plan.json     | **YES** - Explore page structure |
| Generator    | `_generator.md`   | test-plan.json     | \*.spec.ts         | **YES** - Verify selectors       |
| Healer       | `_healer.md`      | run-results.json   | Fixed tests        | **YES** - Debug failures         |

## Execution Modes

The orchestrator automatically detects mode based on your input:

| Mode              | Trigger Phrases                                                              | What Happens                                                 |
| ----------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **Full Pipeline** | "generate tests", "create test flow", "run playwright tests", "test PR #123" | Plan → Generate → Run → Heal (if needed) → Summary → Cleanup |
| **Plan-Only**     | "plan tests", "create test plan", "analyze for testing"                      | Plan → Summary → Cleanup                                     |
| **Generate-Only** | "generate test cases", "write test code", "create test file"                 | Setup → Plan → Generate → Summary → Cleanup                  |
| **Heal-Only**     | "heal tests", "fix failing tests", "debug playwright", "repair tests"        | Setup → Plan → Heal → Summary → Cleanup                      |

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

## API Helpers

Location: `playwright-tests/support/commands.ts`

```typescript
// User Management
signupUser(email: string, password: string): Promise<void>
loginUser(email: string, password: string): Promise<{ token: string; merchantId: string }>

// Merchant Setup
createAPIKey(merchantId: string, token: string): Promise<string>
createDummyConnector(merchantId: string, token: string, name: string): Promise<void>
createPayment(merchantId: string, apiKey: string): Promise<void>

// Utilities
generateUniqueEmail(): string
generateDateTimeString(): string
```

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

## Playwright MCP Browser Tools

All sub-agents (planner, generator, healer) **MUST** use browser tools to explore and verify the application.

### Codegen Tools

| Tool                    | Purpose                              | Used By   |
| ----------------------- | ------------------------------------ | --------- |
| `start_codegen_session` | Start recording interactions         | Generator |
| `end_codegen_session`   | Finalize and get generated test code | Generator |
| `get_codegen_session`   | Check current session state          | Generator |
| `clear_codegen_session` | Reset session if needed              | Generator |

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

## Next Step

**YOU (the main agent) must READ and EXECUTE orchestrator.md directly.**

Do NOT delegate orchestrator.md - it contains the instructions YOU should follow to coordinate the workflow. The orchestrator.md will guide you on when to delegate to sub-agents (playwright-planner, playwright-generator, playwright-healer).

**Your role:**

1. Read orchestrator.md
2. Follow its step-by-step instructions
3. Delegate planning/generation/healing to appropriate sub-agents via task() when instructed
