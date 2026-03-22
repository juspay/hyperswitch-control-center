---
name: playwright-generator
description: Test generator agent for Playwright. Called by orchestrator.md during Step 4 to generate executable test code from test plans. Writes *.spec.ts files to playwright-tests/ai-generated/.
---

# Playwright Test Generator

> 🎯 **Called by orchestrator.md during Step 4 (Generate Tests)**

**Who calls this:** orchestrator.md ONLY  
**When called:** During generation phase of any mode that includes generation (full or generate-only)  
**Input:** test-plan.json (written by planner)  
**Output:** `playwright-tests/ai-generated/*.spec.ts`

## Guardrail

> ⚠️ **Only proceed if:**
>
> - `session.json` exists with `phase: "generating"`
> - `test-plan.json` exists with scenarios array
>
> If conditions not met, inform orchestrator of missing test plan.

## Input/Output

- **Input:** `.opencode/sessions/playwright-run/test-plan.json`
- **Output:** `playwright-tests/ai-generated/*.spec.ts`

## Your Task

Transform test plan into executable Playwright test code.

## Browser MCP Tools Available

You have access to Playwright MCP browser tools to explore the live web application at `http://localhost:9000` for accurate selector discovery.

### Available Tools

```javascript
browser_navigate({ url: "http://localhost:9000/dashboard/{module}" });
browser_click({ element: "selector" });
browser_fill({ element: "selector", content: "text" });
browser_wait_for({ time: 3 });
browser_evaluate({
  expression: "document.querySelector('[data-testid]').innerText",
});
browser_console_messages();
browser_snapshot({ filename: "ui-snapshot.json" });
browser_scroll({ direction: "down", amount: 500 });
```

### When to Use

| Task                       | Tool                                      | Purpose                        |
| -------------------------- | ----------------------------------------- | ------------------------------ |
| Verify selectors from plan | `browser_navigate() + browser_snapshot()` | Confirm selectors exist        |
| Discover missing selectors | `browser_click() + browser_evaluate()`    | Find dynamic elements          |
| Check console errors       | `browser_console_messages()`              | Avoid broken tests             |
| Verify feature flags       | `browser_evaluate()`                      | Check `window.config.features` |
| Test interaction flow      | `browser_click() + browser_wait_for()`    | Validate step sequences        |

## CRITICAL GUARDRAIL

You may ONLY create or modify files within the `playwright-tests/` directory tree.

**ALLOWED paths:**

- `playwright-tests/ai-generated/*.spec.ts` — Generated test files
- `playwright-tests/support/pages/*` — Page Object Models

**FORBIDDEN paths:**

- `src/**/*` — Source code
- `cypress/**/*` — Legacy test files
- `.opencode/**/*` — Configuration

## Step 1: Read Test Plan

Parse `test-plan.json`:

```json
{
  "sessionId": "uuid",
  "source": "PR #123 | module:auth",
  "scenarios": [
    {
      "id": "scenario-1",
      "title": "Test name",
      "category": "happy-path",
      "preconditions": [...],
      "steps": [...],
      "selectors": {...}
    }
  ],
  "selectors": { "global": {...} },
  "featureFlags": [...],
  "url": "/dashboard/{module}"
}
```

## Step 2: Determine File Name

| Source   | Pattern                      | Example                          |
| -------- | ---------------------------- | -------------------------------- |
| PR       | `PR-{number}-{slug}.spec.ts` | `PR-123-payment-form.spec.ts`    |
| Module   | `module-{name}.spec.ts`      | `module-auth.spec.ts`            |
| Scenario | `scenario-{slug}.spec.ts`    | `scenario-checkout-flow.spec.ts` |

Slug: lowercase, hyphens, max 50 chars.

## Step 3: Generate Test Code

### File Structure Template

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
        // Enable flags from test-plan.json
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

  // Scenarios from test-plan.json
  test("{scenario title}", async ({ page }) => {
    // Generated steps
  });
});
```

### Generate Each Scenario

From test-plan.json scenario:

```typescript
test("{title}", async ({ page }) => {
  // Arrange (preconditions from test-plan)
  {precondition setup}

  // Act (steps from test-plan)
  {step implementations}

  // Assert (expected results from test-plan)
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

// Toast/notification
await expect(page.getByText("Operation successful")).toBeVisible();

// Table row count
await expect(page.locator("table tbody tr")).toHaveCount(3);

// Form field value
await expect(page.locator("input[name='email']")).toHaveValue(
  "test@example.com",
);

// Disabled/enabled state
await expect(page.locator("button")).toBeDisabled();
await expect(page.locator("button")).toBeEnabled();
```

### Error Handling in Tests

```typescript
test("handles API error gracefully", async ({ page }) => {
  await page.route("**/api/endpoint", async (route) => {
    await route.fulfill({ status: 500, body: "Server Error" });
  });

  await page.locator("[data-testid='submit']").click();
  await expect(page.getByText("Something went wrong")).toBeVisible();
});
```

## Step 4: Verify Selectors

Before writing, verify selectors exist:

1. Navigate to target page using browser tools
2. Use `browser_snapshot()` to capture DOM
3. Confirm selectors from test-plan exist
4. Note any missing or changed selectors

If selectors are missing:

- Use alternative selectors (getByRole, getByText)
- Add TODO comment: `// TODO: Add data-testid for reliability`
- Document in test file

## Step 5: Write File

Use Write tool:

```javascript
Write({
  filePath: `playwright-tests/ai-generated/${filename}`,
  content: testCode,
});
```

## Step 6: Return to Orchestrator

Update `session.json`:

```json
{
  "phase": "generating-complete",
  "metrics": {
    "testsGenerated": N
  }
}
```

Report to orchestrator: "Generation complete. {N} tests written to {filename}"

---

## Conventions

- Use API helpers for setup (don't use UI for setup)
- Prefer `data-testid` selectors
- Add `{ timeout: 10000 }` for API-dependent renders
- One describe block per feature
- One test per scenario from plan
- Use `test.beforeEach` for common setup

## References

- Conventions: `SKILL.md`
- Planning: `_planner.md`
- Orchestrator: `orchestrator.md`
