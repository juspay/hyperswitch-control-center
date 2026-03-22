---
name: playwright-test-gen
description: Router entry point for Playwright test automation. Routes to orchestrator for full pipeline ("generate tests", "create test flow") or direct to individual agents ("plan tests", "generate test cases", "heal tests"). Analyzes user intent and delegates appropriately.
triggers:
  # Full pipeline triggers (routes to orchestrator)
  - create playwright tests
  - run playwright tests
  - playwright test flow
  - end-to-end test
  - e2e test
  - test PR
  - test module
  - test scenario
  # Individual agent triggers (routes directly)
  - plan tests
  - create test plan
  - analyze for testing
  - generate test cases
  - write test code
  - create test file
  - heal tests
  - fix failing tests
  - debug playwright
  - repair tests
---

# Playwright Test Generation Skill

> 🎯 **SMART ROUTER - Analyzes user intent and delegates appropriately**

## Routing Logic

Based on user input, route to the correct component:

### Full Pipeline Flow

**Trigger phrases:** "generate playwright tests", "create test flow", "end-to-end testing", "test PR #123", "test module:auth", "run playwright tests"

```
User Input → SKILL.md → orchestrator.md → _planner → _generator → Run → _healer (if needed) → Validate → Summary → Cleanup
```

Use orchestrator when user wants complete end-to-end test automation including planning, generation, execution, and healing.

### Individual Agent Flow

**Trigger phrases:** "plan tests", "generate test cases", "heal/fix tests"

| User Intent                  | Route To        | Flow                                         | When to Use                              |
| ---------------------------- | --------------- | -------------------------------------------- | ---------------------------------------- |
| "plan tests for..."          | `_planner.md`   | SKILL.md → \_planner → Output test-plan.json | User just wants a test plan document     |
| "generate test cases..."     | `_generator.md` | SKILL.md → \_generator → Output \*.spec.ts   | User has test plan, wants code generated |
| "heal tests" / "fix failing" | `_healer.md`    | SKILL.md → \_healer → Output fixed tests     | User has failing tests to debug and fix  |

Use individual agents when user wants only ONE specific step, not the complete pipeline.

---

## Quick Reference

### Decision Matrix

| User Says                     | Route        | Agents Involved                              |
| ----------------------------- | ------------ | -------------------------------------------- |
| "Generate tests for PR #123"  | orchestrator | Full pipeline (planner → generator → healer) |
| "Create test flow for module" | orchestrator | Full pipeline                                |
| "Plan tests for auth"         | \_planner    | Planner only                                 |
| "Generate test cases"         | \_generator  | Generator only                               |
| "Fix failing tests"           | \_healer     | Healer only                                  |

---

## Agent Descriptions

| Agent             | Role                        | When to Use                                        |
| ----------------- | --------------------------- | -------------------------------------------------- |
| `orchestrator.md` | Full pipeline orchestration | User wants complete end-to-end flow with all steps |
| `_planner.md`     | Test planning only          | User just wants a test plan document               |
| `_generator.md`   | Test generation only        | User has test plan, wants code generated           |
| `_healer.md`      | Test fixing only            | User has failing tests to fix                      |

---

## Project Context

### Repository Structure

```
playwright-tests/
├── support/
│   ├── commands.ts         # API helpers
│   ├── helper.ts           # Utilities
│   └── pages/              # Page Object Models
│       ├── auth/
│       ├── homepage/
│       ├── operations/
│       ├── workflow/
│       └── connector/
├── fixtures/               # Test data
├── e2e/                    # Test files
│   ├── 1-auth/
│   ├── 2-homepage/
│   ├── 3-operations/
│   ├── 4-connectors/
│   ├── 5-analytics/
│   ├── 6-workflow/
│   ├── 7-developers/
│   ├── 8-settings/
│   └── 9-profile/
└── ai-generated/           # Generated tests
```

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

### Standard beforeEach Pattern

```typescript
test.describe("Feature Name", () => {
  let testEmail: string;
  const testPassword = process.env.TEST_PASSWORD || "Test@123";

  test.beforeEach(async ({ page }) => {
    testEmail = generateUniqueEmail();

    // 1. Sign up via API (fast)
    await signupUser(testEmail, testPassword);

    // 2. Enable feature flags via route interception
    await page.route("/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.global_search = true;
      }
      await route.fulfill({ response, json });
    });

    // 3. Login via UI
    await page.goto("/dashboard/login");
    await page.getByTestId("email").fill(testEmail);
    await page.getByTestId("password").fill(testPassword);
    await page.getByTestId("signin-button").click();

    // 4. Skip 2FA if prompted
    const skip2FAButton = page.getByTestId("skip-now");
    if (await skip2FAButton.isVisible().catch(() => false)) {
      await skip2FAButton.click();
    }
  });

  test("should do something", async ({ page }) => {
    // Test is already logged in and on dashboard
    await expect(page).toHaveURL(/\/dashboard\/home/);
  });
});
```

---

## Module-to-URL Mapping

| Module     | URL                   | Feature Flag | Description                      |
| ---------- | --------------------- | ------------ | -------------------------------- |
| auth       | /dashboard/login      | -            | Sign in, sign up, password reset |
| payments   | /dashboard/payments   | -            | Payment operations list          |
| refunds    | /dashboard/refunds    | -            | Refund management                |
| disputes   | /dashboard/disputes   | -            | Chargeback handling              |
| connectors | /dashboard/connectors | -            | Payment processor setup          |
| routing    | /dashboard/routing    | -            | Payment routing rules            |
| payouts    | /dashboard/payouts    | payouts      | Payout processing (FF)           |
| analytics  | /dashboard/analytics  | -            | Reporting & insights             |
| users      | /dashboard/users      | -            | User management                  |
| api-keys   | /dashboard/api-keys   | -            | API key management               |
| webhooks   | /dashboard/webhooks   | webhooks     | Webhook config (FF)              |
| settings   | /dashboard/settings   | -            | General settings                 |

---

## Selector Strategy

Priority order (highest to lowest):

1. **`getByRole()`** - Buttons, links, headings, textboxes
2. **`getByLabel()`** - Form inputs with labels
3. **`getByPlaceholder()`** - Placeholder text
4. **`getByText()`** - Visible text content
5. **`getByTestId()`** - Fallback when semantic unavailable
6. **CSS/XPath** - Last resort only

### Examples by Module

**Auth Module:**

```typescript
// Preferred (semantic)
await page.getByRole("textbox", { name: /email/i }).fill("test@example.com");
await page.getByRole("button", { name: /sign in/i }).click();

// Fallback (testid)
await page.getByTestId("email-input").fill("test@example.com");
```

**Payments Module:**

```typescript
// Table interactions
await page.getByRole("grid").waitFor();
await page.getByPlaceholder("Search by ID or amount").fill("pay_123");

// Row actions
const row = page.getByTestId("payment-row-123");
await row.getByRole("button", { name: /view/i }).click();
```

**Connectors Module:**

```typescript
// Toggle switches
await page.getByLabel(/enable stripe/i).check();

// Dropdowns
await page.getByRole("combobox", { name: /processor/i }).selectOption("stripe");
```

### Guidelines

**DO:**

- Prefer semantic locators (getByRole, getByLabel)
- Use regex for case-insensitive: `{ name: /email/i }`
- Combine getByRole with name when multiple elements exist
- Wait for elements: `await ...waitFor()`
- Use CSS for static content as last resort

**DON'T:**

- Use getByTestId as primary locator
- Rely only on auto-waiting
- Chain multiple .locator() calls unnecessarily

---

## Test Templates

### Basic Structure

```typescript
import { test, expect } from "@playwright/test";
import {
  signupUser,
  loginUser,
  generateUniqueEmail,
} from "../support/commands";

test.describe("{Feature} - {Source}", () => {
  let testEmail: string;
  const testPassword = process.env.TEST_PASSWORD || "Test@123";

  test.beforeEach(async ({ page }) => {
    testEmail = generateUniqueEmail();

    // 1. Sign up via API
    await signupUser(testEmail, testPassword);

    // 2. Enable feature flags
    await page.route("/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.global_search = true;
      }
      await route.fulfill({ response, json });
    });

    // 3. Login via UI
    await page.goto("/dashboard/login");
    await page.getByTestId("email").fill(testEmail);
    await page.getByTestId("password").fill(testPassword);
    await page.getByTestId("signin-button").click();

    // 4. Skip 2FA if prompted
    const skip2FAButton = page.getByTestId("skip-now");
    if (await skip2FAButton.isVisible().catch(() => false)) {
      await skip2FAButton.click();
    }
  });

  // Test scenarios here
});
```

### Step-to-Code Mapping

| Step           | Playwright Code                                                 |
| -------------- | --------------------------------------------------------------- |
| Navigate       | `await page.goto("/url")`                                       |
| Click          | `await page.locator("selector").click()`                        |
| Type           | `await page.locator("selector").fill("text")`                   |
| Verify visible | `await expect(page.locator("selector")).toBeVisible()`          |
| Verify text    | `await expect(page.locator("selector")).toHaveText("expected")` |
| Verify URL     | `await expect(page).toHaveURL(/pattern/)`                       |

### Assertion Patterns

```typescript
// Element visible
await expect(page.locator("[data-testid='email']")).toBeVisible();

// Element has text
await expect(page.locator("h1")).toHaveText("Expected Title");

// URL matches
await expect(page).toHaveURL(/\/dashboard\/home/);

// Table row count
await expect(page.locator("table tbody tr")).toHaveCount(3);

// Disabled/enabled state
await expect(page.locator("button")).toBeDisabled();
await expect(page.locator("button")).toBeEnabled();
```

### Error Handling Template

```typescript
test("handles API error gracefully", async ({ page }) => {
  await page.route("**/api/endpoint", async (route) => {
    await route.fulfill({ status: 500, body: "Server Error" });
  });

  await page.locator("[data-testid='submit']").click();
  await expect(page.getByText("Something went wrong")).toBeVisible();
});
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

## Server Management

### Backend (Required)

```bash
# Check
curl -s http://localhost:8080/health

# Start
sh cypress/start_hyperswitch.sh

# Wait for: {"status":"ok"}
```

**Startup time:** 30-120 seconds

### Frontend (Auto)

Playwright `webServer` auto-starts the frontend on `http://localhost:9000`.

---

## Coverage Requirements

Every test plan must include:

- ✅ **Happy path** - Standard success flow
- ✅ **Edge cases** - Empty, min, max, special chars
- ✅ **Input validation** - Invalid, malformed data
- ✅ **Error handling** - API errors, network failures
- ✅ **Cross-component** - Impacts on related features
- ✅ **Second-order effects** - Components using changed code

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

## Entry Point Reference

### Full Pipeline Entry

**Start with:** Read `orchestrator.md` and execute Step 1

### Individual Agent Entry

**Planner:** Read `_planner.md` for planning-only mode  
**Generator:** Read `_generator.md` for generation-only mode  
**Healer:** Read `_healer.md` for healing-only mode
