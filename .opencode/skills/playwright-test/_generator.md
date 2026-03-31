---
name: playwright-generator
description: Test generator agent for Playwright. Invoked by orchestrator via task(subagent_type="playwright-generator") during Step 4. Generates executable test code from test plans using browser tools. Writes *.spec.ts files to playwright-tests/ai-generated/.
mode: subagent
---

# Playwright Test Generator

**Called by orchestrator.md during Step 4 (Full Mode Only).**

## File Editing Guidelines (CRITICAL)

When editing session files, test files, or page objects:

**ALWAYS use surgical edits (`edit` tool):**

- Modify only the specific test cases or page object methods that need changes
- Use precise `oldString` matching to target exact content
- Preserve all existing imports, types, and helper functions

**NEVER use full file writes (`write` tool) for existing files:**

- Exception: Only when creating NEW test files or page objects
- Never overwrite entire files to add one test case or fix one selector

**Example - Correct surgical edit for test files:**

```typescript
// Add a new test to existing describe block
edit({
  filePath: "playwright-tests/ai-generated/test.spec.ts",
  oldString:
    '  test("last existing test", async ({ page }) => {\n    // ...\n  });\n});',
  newString:
    '  test("last existing test", async ({ page }) => {\n    // ...\n  });\n\n  test("new test case", async ({ page }) => {\n    // New test logic\n  });\n});',
});
```

**Example - Correct surgical edit for page objects:**

```typescript
// Add new locator to existing Page class
edit({
  filePath: "playwright-tests/support/pages/SomePage.ts",
  oldString:
    "  get existingElement(): Locator {\n    return this.page.locator(\"[data-testid='existing']\");\n  }\n}",
  newString:
    "  get existingElement(): Locator {\n    return this.page.locator(\"[data-testid='existing']\");\n  }\n\n  get newElement(): Locator {\n    return this.page.locator(\"[data-testid='new']\");\n  }\n}",
});
```

## Guardrail

Proceed ONLY if:

- `session.json` exists with `phase: "planning-complete"`
- `test-plan.json` exists with scenarios array

If not met, inform orchestrator and STOP.

## Input/Output

- **Input:** `test-plan.json`
- **Output:** `playwright-tests/ai-generated/*.spec.ts`

## References (Read SKILL.md)

| Section             | Use For                   |
| ------------------- | ------------------------- |
| Selector Strategy   | How to choose selectors   |
| API Helpers         | Setup patterns            |
| Page Object Models  | Reusable locators pattern |
| File Naming         | Naming convention         |
| Authentication Flow | Test setup                |

## Allowed Paths

- `playwright-tests/ai-generated/*.spec.ts` — Generated tests
- `playwright-tests/support/pages/*` — Page Object Models

**FORBIDDEN:** `src/**/*`, `cypress/**/*`, `.opencode/**/*`

---

## Generation Workflow (Sub-steps of Orchestrator Step 4)

### 4.1: Read Test Plan

Parse `test-plan.json` for scenarios, selectors, preconditions, and URL.

### 4.2: Determine Filename

Use pattern from SKILL.md:

- PR: `PR-{number}-{slug}.spec.ts`
- Module: `module-{name}.spec.ts`
- Scenario: `scenario-{slug}.spec.ts`

Slug: lowercase, hyphens, max 50 chars.

### 4.3: Check & Verify Page Objects

**Read** ALL files in `playwright-tests/support/pages/` to understand available locators.

**Page Object Pattern:**

```typescript
export class PageName {
  constructor(readonly page: Page) {}
  get elementName(): Locator {
    return this.page.locator("[data-testid='...']");
  }
}
```

**Decision Matrix:**
| Scenario | Action |
|----------|--------|
| Element used in 3+ tests | Add to Page Object |
| Element used in 1-2 tests | Define inline |
| Module-specific complex flow | Create new Page class |

**Verify Selectors with Browser Tools:**

```typescript
await browser_navigate({ url: "http://localhost:9000/dashboard/{module}" });
const snapshot = await browser_snapshot({});
// Verify each selector from test-plan.json exists in snapshot
```

### 4.4: Generate Test Code

**File Structure:**

```typescript
/**
 * Auto-generated Playwright test
 * Source: {from test-plan.json}
 * Generated: {ISO timestamp}
 */

import { test, expect } from "@playwright/test";
import { signupUser, loginUI, generateUniqueEmail } from "../support/commands";
import { RelevantPage } from "../support/pages/..."; // If using Page Objects

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("{Feature} - {Source}", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    // Enable feature flags if needed (from test-plan.json)
    await page.route("/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.required_flag = true;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  // Scenarios from test-plan.json
  test("{scenario title}", async ({ page }) => {
    // Arrange: preconditions
    // Act: steps using verified selectors
    // Assert: expected results
  });
});
```

**Step-to-Code Mapping:**
| Step Type | Code |
|-----------|------|
| Navigate | `await page.goto("/url")` |
| Click | `await page.locator("selector").click()` |
| Type | `await page.locator("selector").fill("text")` |
| Verify visible | `await expect(page.locator("selector")).toBeVisible()` |
| Verify text | `await expect(page.locator("selector")).toHaveText("expected")` |
| Verify URL | `await expect(page).toHaveURL(/pattern/)` |

**Assertion Patterns:**

```typescript
await expect(page.locator("[data-testid='email']")).toBeVisible();
await expect(page.locator("h1")).toHaveText("Expected");
await expect(page.getByText("Success")).toBeVisible();
await expect(page.locator("table tbody tr")).toHaveCount(3);
```

**Timing Helpers:**

```typescript
await page.waitForLoadState("networkidle");
await page.locator("selector").waitFor({ state: "visible" });
await page.waitForResponse("**/api/endpoint");
```

### 4.5: Write File

```javascript
Write({
  filePath: `playwright-tests/ai-generated/${filename}`,
  content: testCode,
});
```

### 4.6: Update Page Objects (if needed)

When adding new reusable elements:

```typescript
// In appropriate Page class
get newReusableElement(): Locator {
  return this.page.locator('[data-testid="new-element"]');
}

async helperMethod(param: string): Promise<void> {
  await this.element.fill(param);
  await this.element.click();
}
```

---

## Conventions

- Use API helpers for setup (don't use UI)
- Prefer semantic selectors: `getByRole`, `getByLabel`, then `getByTestId`
- Add `{ timeout: 10000 }` for API-dependent renders
- One describe block per feature
- Document selector fallbacks in comments
- **CRITICAL:** Verify selectors with browser tools before generating

---

## Return to Orchestrator

**Before returning, close browser sessions:**

```typescript
await skill_mcp({
  mcp_name: "playwright",
  tool_name: "browser_close",
});
```

Update `session.json`:

```json
{
  "phase": "generating-complete",
  "metrics": { "testsGenerated": N }
}
```

Report: "Generation complete. {N} tests written to {filename}. Selectors verified. Page Objects updated: [list]."
