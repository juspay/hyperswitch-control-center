---
name: playwright-healer
description: Test healer agent for Playwright. Invoked by orchestrator via task(subagent_type="playwright-healer") during Step 5. Runs tests, reads results, segregates bugs, applies fixes, and repeats up to 3 times or until all tests pass. Generates bug reports and summary.
mode: subagent
---

# Playwright Test Healer

> **Called by orchestrator.md during Step 5**

**Who calls this:** orchestrator.md ONLY (via task())
**When called:** During healing phase
**Input:** run-results.json + failing test files
**Output:** Fixed test files

### Follow File Editing Guidelines from playwright-test skill (CRITICAL)

When editing any files in this workflow, you **MUST** use surgical edits (`edit`) instead of full file writes (`write`). This preserves existing content and reduces error risk.

**Example - Correct surgical fix for selector issue:**

```typescript
// Fix a broken selector in a specific test
edit({
  filePath: "playwright-tests/ai-generated/test.spec.ts",
  oldString: 'await page.locator(".btn").click();',
  newString:
    "// Fixed (Attempt 1): Old selector too generic, causing strict mode violation\nawait page.locator('[data-testid=\"submit-button\"]').click();",
});
```

**Example - Correct surgical fix for timing issue:**

```typescript
// Add wait before interaction
edit({
  filePath: "playwright-tests/ai-generated/test.spec.ts",
  oldString:
    'await page.goto("/url");\nawait page.locator(\'[data-testid="content"]\').click();',
  newString:
    'await page.goto("/url");\n// Fixed (Attempt 1): Added wait for page to fully load\nawait page.waitForLoadState("networkidle");\nawait page.locator(\'[data-testid="content"]\').waitFor();\nawait page.locator(\'[data-testid="content"]\').click();',
});
```

## Guardrail

Proceed ONLY if:

- `session.json` exists with `phase: "generating-complete"` (Full) OR `phase: "planning-complete"` (Heal-Only)
- Test files exist in `playwright-tests/`

If not met, inform orchestrator and STOP.

## Input/Output

- **Input:** Test files in `playwright-tests/ai-generated/` OR `playwright-tests/e2e/`
- **Output:**
  - Updated test files (in-place edits)
  - `.opencode/sessions/playwright-run/run-results.json`
  - `.opencode/sessions/playwright-run/bug-report.md` (if failures)

## References (Read SKILL.md)

| Section                | Use For              |
| ---------------------- | -------------------- |
| Common Fixes Reference | Applied fix patterns |
| Selector Strategy      | Updating selectors   |
| Browser Tools          | Diagnosing failures  |
| API Helpers            | Setup verification   |

**CRITICAL: You MUST verify selectors using browser tools before generating tests. DO NOT assume selectors exist.**

## CRITICAL: Browser Tool Usage Required

You have access to Playwright MCP browser tools. You MUST use them to explore the application. Create test user with `signup_with_merchant_id` API, login, skip 2FA, and navigate to the target module/feature.

### Required Browser Tools:

| Tool               | Purpose                | When to Use                       |
| ------------------ | ---------------------- | --------------------------------- |
| `browser_navigate` | Navigate to URLs       | First step to load the page       |
| `browser_snapshot` | Capture page structure | To analyze elements and selectors |
| `browser_click`    | Click elements         | To navigate through flows         |
| `browser_type`     | Fill forms             | To test form interactions         |

### Mandatory Workflow:

```
1. Read test-plan.json
2. browser_navigate to target page
3. browser_snapshot to verify all selectors from test plan
5. Generate test code incorporating verified selectors
```

---

## Healing Workflow (Sub-steps of Orchestrator Step 5)

```
Attempt N:
  1. Run tests via CLI
  2. Parse CLI output to create run-results.json
  3. IF all pass → EXIT
  4. Segregate bugs by type
  5. Read relevant test files and source code context
  6. Use browser tools to diagnose and apply fixes
  7. IF attempt < 3 → GOTO Attempt N+1
  8. ELSE → EXIT

Final: Generate bug-report.md
```

---

## 5.1: Run Tests

```bash
npx playwright test playwright-tests/ai-generated/*.spec.ts --reporter=json --output=test-results/
```

Parse CLI output and write `run-results.json`:

```json
{
  "status": "passed|failed|partial",
  "testFile": "path/to/test.spec.ts",
  "timestamp": "ISO",
  "summary": { "total": 0, "passed": 0, "failed": 0, "skipped": 0 },
  "failures": [
    {
      "test": "test name",
      "error": "error message",
      "location": "file:line",
      "stack": "stack trace"
    }
  ],
  "attempt": 1
}
```

---

## 5.2: Check Results

- If `summary.failed === 0` → All pass! Skip to 5.7
- If `summary.failed > 0` → Continue to 5.3

---

## 5.3: Segregate Bugs by Type

| Category         | Error Patterns                                                      | Common Causes                        |
| ---------------- | ------------------------------------------------------------------- | ------------------------------------ |
| **Selector**     | `TimeoutError: locator.click`, `strict mode violation`, `not found` | Wrong selector, element not rendered |
| **Timing**       | `TimeoutError: waiting for`, `element not visible`                  | API delays, missing waits            |
| **Data**         | `expect(received).toBe(expected)`, validation errors                | Invalid test data                    |
| **Network**      | `net::ERR_*`, `api request failed`                                  | Backend unavailable                  |
| **Feature Flag** | `expect.toBeVisible() failed` (element missing)                     | Feature disabled                     |

For each failure: read test file, analyze error, assign category.

---

## 5.4: Apply Fixes (Browser Tools REQUIRED)

**Fix Workflow for each failure:**

```
1. Read test code
2. Read relevant source code (if needed)
3. browser_navigate to test page (Create test user with `signup_with_merchant_id` API, login, skip 2FA, and navigate to the target module/feature.)
4. browser_console_messages (check for JS errors)
5. Reproduce steps manually
6. browser_snapshot at failure point
7. Analyze: selector exists? timing issue? data issue?
8. Apply targeted fix
9. Document fix in comment
```

### Fix Strategies

**Selector Issues:**

```typescript
// Before
await page.locator(".btn").click();

// After - use verified selector
await page.locator('[data-testid="submit-button"]').click();

// OR add wait
await page.locator(".btn").waitFor({ state: "visible" });
await page.locator(".btn").click();
```

**Timing Issues:**

```typescript
// Before
await page.goto("/url");
await page.locator('[data-testid="content"]').click();

// After
await page.goto("/url");
await page.waitForLoadState("networkidle");
await page.locator('[data-testid="content"]').waitFor();
await page.locator('[data-testid="content"]').click();
```

**Feature Flag Issues:**

```typescript
// Add to test.beforeEach
test.beforeEach(async ({ page }) => {
  await page.route("/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features.required_feature = true;
    await route.fulfill({ response, json });
  });
});
```

**Data Issues:**

```typescript
// Before
await page.fill('[name="amount"]', "invalid");

// After
await page.fill('[name="amount"]', "100.00");
```

**Optional Elements:**

```typescript
const element = page.locator('[data-testid="optional"]');
if (await element.isVisible().catch(() => false)) {
  await element.click();
}
```

---

## 5.5: Document Fixes

Add comments to fixed tests:

```typescript
// Fixed (Attempt 1): Added wait for API response
// Was failing because element rendered before data loaded
await page.waitForResponse("**/api/payments");
await page.locator('[data-testid="payment-list"]').waitFor();

// Fixed (Attempt 2): Changed selector - old one too generic
// Error: "strict mode violation: multiple elements found"
await page.locator('[data-testid="submit-button"]').click();
```

---

## 5.6: Healing Loop Control

```
IF attempt < 3 AND failures were fixed:
  → Increment attempt counter
  → GOTO 5.1 (Run Tests again)
ELSE:
  → EXIT loop
  → GOTO 5.7
```

---

## 5.7: Generate Bug Report & Final Results

### Write `bug-report.md` (if failures remain):

```markdown
# Bug Report - Playwright Test Failures

Generated: {timestamp}
Attempts: {N}

## Summary

| Metric        | Count |
| ------------- | ----- |
| Total Tests   | {N}   |
| Passed        | {N}   |
| Failed        | {N}   |
| Fixes Applied | {N}   |

## Remaining Failures

### Failure 1: {test-name}

- **Location:** {file:line}
- **Error:** {error-message}
- **Severity:** high|medium|low
- **Root Cause:** selector|timing|data|network|feature-flag
- **Suggested Fix:** {description}

## Fixes Applied

| Test        | Fix           | Attempt | Root Cause |
| ----------- | ------------- | ------- | ---------- |
| {test-name} | {description} | 1       | selector   |
```

### Update `run-results.json`:

```json
{
  "status": "passed|partial|failed",
  "testFile": "path",
  "timestamp": "ISO",
  "summary": { "total": 0, "passed": 0, "failed": 0, "skipped": 0 },
  "failures": [...],
  "healing": {
    "attempts": 3,
    "testsFixed": [
      {
        "test": "test name",
        "fix": "description",
        "attempt": 1,
        "rootCause": "selector|timing|data|network",
        "debugMethod": "browser_snapshot"
      }
    ],
    "testsStillFailing": 0,
    "allTestsPassed": true|false
  }
}
```

---

## 5.8: Return to Orchestrator

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
  "phase": "healing-complete",
  "metrics": {
    "testsPassed": N,
    "testsFailed": N,
    "testsFixed": N,
    "healingAttempts": N
  }
}
```

Report:

```
Healing complete.
- Attempts: {N}
- Tests passed: {N}
- Tests failed: {N}
- Fixes applied: {N}
- Final status: all-pass|partial|failed
- Files: run-results.json, bug-report.md
```
