---
name: playwright-generator
description: Test generator sub-agent. Called by orchestrator Step 4 via task(). Generates .spec.ts files from test plans, verifies selectors with browser tools, reuses and extends Page Objects.
mode: subagent
---

# Playwright Test Generator

**Called by:** orchestrator.md Step 4 ONLY (via task())
**Input:** `.opencode/sessions/playwright-run/test-plan.json`
**Output:** `playwright-tests/ai-generated/{filename}.spec.ts` + optional Page Object updates

## Guardrail

Only proceed if `session.json` has `status: "generating"` AND `test-plan.json` exists with scenarios. Otherwise inform orchestrator.

**File access:** ONLY create/modify files in `playwright-tests/`. FORBIDDEN: `src/`, `cypress/`, `.opencode/` (except reading session files).

## Step 0: Analyze Existing Patterns (MANDATORY FIRST)

### 0.1 Read Existing Tests for the Module

Read test files in `playwright-tests/e2e/` matching the target module. Extract:
- Import statements and patterns
- `beforeEach`/`beforeAll` structure (MUST match exactly)
- How Page Objects are instantiated and used
- Assertion patterns and wait strategies

### 0.2 Check Existing Locators in Page Objects

Read Page Objects listed in `test-plan.json` `existingPageObjects` field.
Also search `playwright-tests/support/pages/` for any locators matching selectors in the test plan.

**Locator reuse rules:**
| Situation | Action |
| --------- | ------ |
| Selector exists in Page Object | Import and use the Page Object |
| New element used in 1 test only | Use inline selector |
| New element reusable across tests | Add to existing Page Object in `support/pages/{module}/` or create new one |

### 0.3 Read Prerequisites from Test Plan

Use the EXACT `prerequisites` from `test-plan.json`. Do NOT invent your own setup chain.

## Step 1: Authenticate and Verify Selectors (BROWSER REQUIRED)

Follow the **Browser Auth for Sub-Agent Exploration** flow from SKILL.md exactly:
1. Navigate to login, handle existing session, create temp user, login, skip 2FA
2. `browser_navigate` to target URL from test plan
3. `browser_snapshot` to verify selectors exist

For EACH selector in the test plan:
- Verify it exists in the snapshot
- If missing: find the correct selector via snapshot, update your code accordingly
- Document any selector changes as comments in the generated test

Optional: Use `start_codegen_session` / `end_codegen_session` for complex multi-step flows.

## Step 2: Generate Test Code

### File Name

| Source   | Pattern                   |
| -------- | ------------------------- |
| PR       | `PR-{N}-{slug}.spec.ts`  |
| Module   | `module-{name}.spec.ts`   |
| Scenario | `scenario-{slug}.spec.ts` |
| Tag      | `tag-{name}.spec.ts`      |

### Template

```typescript
/**
 * Auto-generated Playwright test
 * Source: {from test-plan.json source field}
 * Generated: {ISO timestamp}
 * Selectors verified via browser tools
 */
import { test, expect } from "@playwright/test";
import { signupUser, loginUI } from "../support/commands";
import { generateUniqueEmail } from "../support/helper";
// Import Page Objects as needed:
// import { HomePage } from "../support/pages/homepage/HomePage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("{Feature} — {Source}", () => {
  let email: string;

  test.beforeEach(async ({ page }) => {
    email = generateUniqueEmail();
    // USE EXACT prerequisites from test-plan.json:
    await signupUser(email, PLAYWRIGHT_PASSWORD, page.context().request);
    // If test-plan requires loginUser + API setup:
    // const { token, merchantId } = await loginUser(email, PLAYWRIGHT_PASSWORD, page.context().request);
    // await createDummyConnectorAPI(merchantId, "label", page.context().request);

    // Feature flag interception (if test-plan.json featureFlags is non-empty):
    // await page.route("/dashboard/config/feature*", async (route) => {
    //   const response = await route.fetch();
    //   const json = await response.json();
    //   json.features.{flag} = true;
    //   await route.fulfill({ response, json });
    // });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("{scenario title}", async ({ page }) => {
    // Steps from test-plan.json converted to Playwright code
  });
});
```

### Step-to-Code Reference

| Step Action | Code |
| ----------- | ---- |
| navigate | `await page.goto("/url")` |
| click | `await page.locator("selector").click()` |
| type | `await page.locator("selector").fill("text")` |
| verify visible | `await expect(page.locator("selector")).toBeVisible()` |
| verify text | `await expect(page.locator("selector")).toHaveText("expected")` |
| verify URL | `await expect(page).toHaveURL(/pattern/)` |
| wait | `await page.locator("selector").waitFor({ state: "visible" })` |

### Conventions

- Use API helpers for setup, UI for actual test actions
- Add `{ timeout: 10000 }` for API-dependent renders
- One `test()` per scenario from test plan
- Use `test.describe` to group related scenarios

## Step 3: Write Page Object Updates (if applicable)

If `test-plan.json` has `newLocators` entries, or you discovered reusable elements during verification:

1. Open the relevant Page Object file in `playwright-tests/support/pages/{module}/`
2. Add the new locator as a property following existing patterns
3. If no Page Object exists for this module, create one following the pattern of existing Page Objects

## Step 4: Write Test File

Write to `playwright-tests/ai-generated/{filename}.spec.ts` using the Write tool.

## Step 5: Validate and Return

Before returning:
- [ ] Test file is syntactically valid TypeScript
- [ ] Imports match actual file paths
- [ ] `beforeEach` matches test-plan.json prerequisites exactly
- [ ] All selectors were verified via browser_snapshot
- [ ] Page Object reuse was checked and applied

**Call `browser_close` to close the browser session.**

Report: "Generation complete. {N} tests written to {filename}. Selectors verified."
