---
name: playwright-generator
description: Test generator agent for Playwright. Invoked by main agent (orchestrator) via task(subagent_type="playwright-generator") during Step 4. Generates executable test code from test plans using browser tools. Writes *.spec.ts files to playwright-tests/ai-generated/.
mode: subagent
---

# Playwright Test Generator

> **Called by orchestrator.md during Step 4 (Generate Tests)**

**Who calls this:** orchestrator.md ONLY (via task())
**When called:** During generation phase of full mode only
**Input:** test-plan.json (written by planner)
**Output:** `playwright-tests/ai-generated/*.spec.ts`

## Guardrail

> **Only proceed if:**
>
> - `session.json` exists with `phase: "generating"`
> - `test-plan.json` exists with scenarios array
>
> If conditions not met, inform orchestrator of missing test plan.

## Your Task

Transform test plan into executable Playwright test code.

**CRITICAL: You MUST verify selectors using browser tools before generating tests. DO NOT assume selectors exist.**

You have access to Playwright MCP browser tools. You MUST use them to verify selectors and generate accurate tests.

### Required Browser Tools (refer playwright-test skill)

### Mandatory Workflow:

```
1. Read test-plan.json
2. browser_navigate to target page
3. browser_snapshot to verify all selectors from test plan
5. Generate test code incorporating verified selectors
```

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

## Step 3: Verify Selectors (BROWSER TOOLS REQUIRED)

**MANDATORY: Use browser tools to verify selectors exist before generating tests.**
Always create a new user by 'signup_with_merchant_id` API, Handle 2FA screen by clicking on "Skip" button refer playwright-test skill

### 3.1 Navigate to Target Page

```typescript
await browser_navigate({
  intent: "Verify selectors for test generation",
  url: "http://localhost:9000/dashboard/{module}",
});
```

### 3.2 Capture Page Structure

```typescript
const snapshot = await browser_snapshot({
  intent: "Verify selectors from test plan exist",
});
```

### 3.3 Verify Each Selector

Check that selectors from test-plan.json exist in the snapshot:

```typescript
// Check data-testid selectors
const emailField = snapshot.find(
  (el) => el.attributes?.["data-testid"] === "email",
);
if (!emailField) {
  console.log("WARNING: data-testid='email' not found, using alternative");
  // Fall back to getByPlaceholder or getByLabel
}
```

### 3.4 Document Verified Selectors

Create a mapping of verified selectors:

```typescript
const verifiedSelectors = {
  emailInput: "[data-testid='email']", // verified exists
  passwordInput: "[data-testid='password']", // verified exists
  submitButton: "getByRole('button', { name: 'Sign In' })", // fallback to semantic
};
```

## Step 4: Generate Test Code

### File Structure Template

```typescript
/**
 * Auto-generated Playwright test
 * Source: {from test-plan.json}
 * Generated: {ISO timestamp}
 * Selectors verified: Yes (via browser tools)
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
    await signupUser(email, PLAYWRIGHT_PASSWORD, page.context().request);

    // 2. Enable feature flags via route interception (only if module is feature flag gates else skip)
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
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  // Scenarios from test-plan.json
  test("{scenario title}", async ({ page }) => {
    // Generated steps using VERIFIED selectors
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
await expect(page.locator("[data-testid='email']")).toBeVisible(); // Element visible
await expect(page.locator("h1")).toHaveText("Expected Title"); // Element has text
await expect(page.locator(".message")).toContainText("success"); // Element contains text
await expect(page).toHaveURL(/\/dashboard\/home/); // URL matches
await expect(page.getByText("Operation successful")).toBeVisible(); // Toast/notification
await expect(page.locator("table tbody tr")).toHaveCount(3); // Table row count
await expect(page.locator("input[name='email']")).toHaveValue(
  "test@example.com",
); // Form field value
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

Report to orchestrator: "Generation complete. {N} tests written to {filename}. All selectors verified via browser tools."

---

## Conventions

- Use API helpers for setup (don't use UI for setup)
- Use verified selectors (data-testid preferred, semantic fallback)
- Add `{ timeout: 10000 }` for API-dependent renders
- One describe block per feature
- Use `test.before` and `test.beforeEach` for common setup
- Document any selector fallbacks in comments

## References

- Conventions: `SKILL.md`
- Planning: `_planner.md`
- Orchestrator: `orchestrator.md`
