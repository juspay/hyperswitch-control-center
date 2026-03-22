---
name: playwright-test
description: Entry point for Playwright test automation. ALWAYS delegates to orchestrator.md. The orchestrator detects execution mode (full pipeline, plan-only, generate-only, or heal-only) and manages the complete workflow including setup, execution, summary, bug reports, and cleanup.
triggers:
  - generate playwright tests
  - create playwright tests
  - run playwright tests
  - playwright test flow
  - end-to-end test
  - e2e test
  - test PR
  - test module
  - test scenario
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

> 🎯 **ENTRY POINT - Always delegates to orchestrator.md**

## Your Only Action

**Read `orchestrator.md` and execute.**

The orchestrator will:

1. Detect execution mode from your input
2. Run appropriate setup
3. Execute the requested workflow
4. Generate summary and bug reports
5. Present commit/cleanup options

## Execution Modes

The orchestrator automatically detects mode based on your input:

| Mode              | Trigger Phrases                                                              | What Happens                                                 |
| ----------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **Full Pipeline** | "generate tests", "create test flow", "run playwright tests", "test PR #123" | Plan → Generate → Run → Heal (if needed) → Summary → Cleanup |
| **Plan-Only**     | "plan tests", "create test plan", "analyze for testing"                      | Plan → Summary → Cleanup                                     |
| **Generate-Only** | "generate test cases", "write test code", "create test file"                 | Setup → Plan → Generate → Summary → Cleanup                         |
| **Heal-Only**     | "heal tests", "fix failing tests", "debug playwright", "repair tests"        | Setup → Heal → Summary → Cleanup                             |

All modes include:

- ✅ Environment setup (server checks)
- ✅ Task execution
- ✅ Summary with results
- ✅ Bug report generation (if issues found)
- ✅ Commit/push options
- ✅ Cleanup

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

### Examples

**Auth Module:**

```typescript
await page.getByRole("textbox", { name: /email/i }).fill("test@example.com");
await page.getByRole("button", { name: /sign in/i }).click();
```

**Payments Module:**

```typescript
await page.getByRole("grid").waitFor();
await page.getByPlaceholder("Search by ID or amount").fill("pay_123");
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

## Troubleshooting

| Error               | Solution                              |
| ------------------- | ------------------------------------- |
| Backend DOWN        | Run `sh cypress/start_hyperswitch.sh` |
| gh not auth         | Run `gh auth login`                   |
| Test timeout        | Add `{ timeout: 10000 }`              |
| Selector not found  | Use `browser_snapshot` to discover    |
| Feature not visible | Add `page.route()` intercept          |

---

## Next Step

**Read `orchestrator.md` to begin execution.**
