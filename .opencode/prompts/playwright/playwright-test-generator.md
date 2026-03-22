---
name: playwright-generator
description: Generate Playwright test code from test plan.
---

# Playwright Test Generator

## Input

Read: `.opencode/sessions/playwright-run/test-plan.json`

## Output

Write:

- `playwright-tests/ai-generated/{name}.spec.ts`
- `.opencode/sessions/playwright-run/locators/{module}.ts` (if multiple scenarios share selectors)

## Your Task

Transform test plan into executable Playwright test code.

## Browser MCP Tools Available

You have access to Playwright MCP browser tools to explore the live web application at `http://localhost:9000` for accurate selector discovery.

### Available Tools

```javascript
// Navigate and interact
browser_navigate({ url: "http://localhost:9000/dashboard/{module}" });
browser_click({ element: "selector" });
browser_fill({ element: "selector", content: "text" });
browser_wait_for({ time: 3 });

// Inspect page state
browser_evaluate({
  expression: "document.querySelector('[data-testid]').innerText",
});
browser_console_messages();
browser_snapshot({ filename: "ui-snapshot.json" });
browser_scroll({ direction: "down", amount: 500 });
```

### When to Use During Generation

| Task                       | Tool                                      | Purpose                        |
| -------------------------- | ----------------------------------------- | ------------------------------ |
| Verify selectors from plan | `browser_navigate() + browser_snapshot()` | Confirm selectors exist        |
| Discover missing selectors | `browser_click() + browser_evaluate()`    | Find dynamic elements          |
| Check console errors       | `browser_console_messages()`              | Avoid generating broken tests  |
| Verify feature flags       | `browser_evaluate()`                      | Check `window.config.features` |
| Test interaction flow      | `browser_click() + browser_wait_for()`    | Validate step sequences        |

### Best Practices

1. **Verify selectors before using** - Navigate to page and snapshot to confirm selectors exist
2. **Test click sequences** - Use browser tools to verify interaction flows work
3. **Check for dynamic content** - Use `browser_evaluate()` to find elements that appear after actions
4. **Validate form submissions** - Test fill + click sequences
5. **Capture console errors** - Ensure no JS errors during test flow

## CRITICAL GUARDRAIL

You may ONLY create or modify files within the `playwright-tests/` directory tree.

**ALLOWED paths:**

- `playwright-tests/ai-generated/*.spec.ts` — Generated test files
- `playwright-tests/support/pages/*` — Page Object Models
- `playwright-tests/support/commands.ts` — API helpers
- `playwright-tests/support/helper.ts` — Utilities
- `playwright-tests/fixtures/*` — Test data

**FORBIDDEN paths:**

- `src/**/*` — Source code
- `cypress/**/*` — Legacy test files
- `.opencode/**/*` — Configuration (except session locators)
- `config/**/*` — Config files
- Root directory files

If you need to reference existing patterns, READ them from source but WRITE only to playwright-tests/.

---

## Step 1: Read Test Plan

Parse `test-plan.json`:

- `scenarios[]` - test cases to implement
- `selectors{}` - discovered selectors
- `url` - target page
- `featureFlags[]` - flags to enable

## Step 2: Generate Locators (if needed)

If multiple scenarios share selectors, create locators file:

```typescript
// .opencode/sessions/playwright-run/locators/{module}.ts
export const {Module}Locators = {
  emailInput: '[data-testid="email"]',
  passwordInput: '[data-testid="password"]',
  signInButton: '[data-testid="signin-button"]',
} as const;
```

## Step 3: Generate Test Code

### File Structure

```typescript
/**
 * Auto-generated Playwright test
 * Source: {from test-plan.json}
 * Generated: {ISO timestamp}
 */

import { test, expect } from "@playwright/test";
import {
  signupUser,
  loginUser,
  generateUniqueEmail,
} from "../support/commands";
// import { ModuleLocators } from "../locators/module"; // if using locators file

test.describe("{Feature} - {Source}", () => {
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
        // Enable flags as needed from test-plan.json
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

  // Scenarios generated from test-plan.json
  {
    scenarios;
  }
});
```

### Generate Each Scenario

From test-plan.json scenario:

```typescript
test("{title}", async ({ page }) => {
  // Arrange (preconditions)
  {precondition setup}

  // Act (steps)
  {step implementations}

  // Assert (expected results)
  {assertions}
});
```

### Step-to-Code Mapping

| Step Type      | Playwright Code                                                 |
| -------------- | --------------------------------------------------------------- |
| Navigate       | `await page.goto("/url")`                                       |
| Click          | `await page.locator("selector").click()`                        |
| Type           | `await page.locator("selector").fill("text")`                   |
| Verify visible | `await expect(page.locator("selector")).toBeVisible()`          |
| Verify text    | `await expect(page.locator("selector")).toHaveText("expected")` |
| Verify URL     | `await expect(page).toHaveURL(/pattern/)`                       |
| Wait           | `await page.waitForSelector("selector")`                        |

### Assertion Patterns

```typescript
// Element visible
await expect(page.locator("[data-testid='email']")).toBeVisible();

// Element has text
await expect(page.locator("h1")).toHaveText("Expected Title");

// Element contains text
await expect(page.locator(".message")).toContainText("success");

// URL matches
await expect(page).toHaveURL(/\/dashboard\/home/);

// Toast/notification appears
await expect(page.getByText("Operation successful")).toBeVisible();

// Table row count
await expect(page.locator("table tbody tr")).toHaveCount(3);

// Form field value
await expect(page.locator("input[name='email']")).toHaveValue(
  "test@example.com",
);

// Disabled state
await expect(page.locator("button")).toBeDisabled();

// Enabled state
await expect(page.locator("button")).toBeEnabled();
```

### Error Handling in Tests

```typescript
test("handles API error gracefully", async ({ page }) => {
  // Mock API failure
  await page.route("**/api/endpoint", async (route) => {
    await route.fulfill({ status: 500, body: "Server Error" });
  });

  // Perform action
  await page.locator("[data-testid='submit']").click();

  // Verify error handling
  await expect(page.getByText("Something went wrong")).toBeVisible();
});
```

## Step 4: File Naming

| Mode     | Pattern                      | Example                          |
| -------- | ---------------------------- | -------------------------------- |
| pr       | `PR-{number}-{slug}.spec.ts` | `PR-123-payment-form.spec.ts`    |
| module   | `module-{name}.spec.ts`      | `module-auth.spec.ts`            |
| scenario | `scenario-{slug}.spec.ts`    | `scenario-user-checkout.spec.ts` |

Slug: lowercase, hyphens, max 50 chars.

## Step 5: Write File

Use `Write` tool:

```javascript
Write({
  filePath: `playwright-tests/ai-generated/${filename}`,
  content: testCode,
});
```

## Conventions

- Use API helpers for setup (don't use UI for setup)
- Prefer `data-testid` selectors
- Add `{ timeout: 10000 }` for API-dependent renders
- One describe block per feature
- One test per scenario from plan
- Use `test.beforeEach` for common setup

## References

- SKILL.md: Conventions, helper functions
- orchestrator.md: Pipeline context
- playwright.config.ts: Timeouts, baseURL
