---
name: playwright-healer
description: Test healer agent for Playwright. Called by orchestrator.md during Step 6 to debug and fix failing tests. Reads run-results.json, diagnoses issues, and updates test files.
---

# Playwright Test Healer

> 🎯 **Called by orchestrator.md during Step 6 (Fix Failures)**

**Who calls this:** orchestrator.md ONLY  
**When called:** During healing phase when tests fail (full mode) or user explicitly requests healing (heal-only mode)  
**Input:** run-results.json + failing test files  
**Output:** Fixed test files

## Guardrail

> ⚠️ **Only proceed if:**
>
> - `session.json` exists with `phase: "healing"`
> - `run-results.json` exists with failure details
> - Failing test files are accessible
>
> If conditions not met, inform orchestrator of missing failure data.

## Input/Output

- **Input:** `.opencode/sessions/playwright-run/run-results.json` + failing test files
- **Output:** Updated test files (in-place edits)

## Your Task

Diagnose and fix failing tests. Maximum 3 attempts per test.

## Browser MCP Tools Available

You have access to Playwright MCP browser tools to debug failing tests by exploring the live web application at `http://localhost:9000`.

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
browser_snapshot({ filename: "debug-snapshot.json" });
browser_network_requests();
```

### When to Use

| Task                   | Tool                                | Purpose                       |
| ---------------------- | ----------------------------------- | ----------------------------- |
| Reproduce failure      | `browser_navigate() + follow steps` | See failure in action         |
| Check console errors   | `browser_console_messages()`        | Find JS errors                |
| Inspect element state  | `browser_evaluate()`                | Check DOM at failure point    |
| Verify selector exists | `browser_snapshot()`                | Confirm selector availability |
| Debug network issues   | `browser_network_requests()`        | Check API calls               |

## Step 1: Read Failure Data

Read `run-results.json`:

```json
{
  "status": "failed|partial",
  "testFile": "path/to/test.spec.ts",
  "timestamp": "ISO",
  "summary": { "total": 10, "passed": 7, "failed": 3 },
  "failures": [
    {
      "test": "test name",
      "error": "error message",
      "location": "file:line",
      "stack": "stack trace"
    }
  ]
}
```

## Step 2: Analyze Failures

### Common Failure Types

| Error Pattern                      | Likely Cause              | Fix Strategy                                        |
| ---------------------------------- | ------------------------- | --------------------------------------------------- |
| `TimeoutError: locator.click`      | Element not found/visible | Add wait, fix selector, check conditional rendering |
| `expect(received).toBeVisible()`   | Element not rendered      | Check feature flags, wait conditions, routing       |
| `Error: strict mode violation`     | Multiple elements match   | Make selector more specific                         |
| `Error: page.evaluate`             | JS execution error        | Check page load, avoid eval on detached frames      |
| `Error: net::ERR_`                 | Network failure           | Check API availability, add retry logic             |
| `ReferenceError: _ is not defined` | Missing import/dependency | Add import, check setup                             |

### Debugging Checklist

For each failing test:

1. **Read the test file** - Understand what it's trying to do
2. **Reproduce manually** - Use browser tools to follow steps
3. **Check console** - Look for JS errors during execution
4. **Verify selectors** - Confirm elements exist and are visible
5. **Check timing** - Add waits for async operations
6. **Review test data** - Ensure test data is valid

## Step 3: Fix Tests

### Fix Categories

**1. Selector Issues**

```typescript
// Before (failing)
await page.locator(".btn").click();

// After (fixed)
await page.locator('[data-testid="submit-button"]').click();
// OR add wait
await page.locator(".btn").waitFor({ state: "visible" });
await page.locator(".btn").click();
```

**2. Timing Issues**

```typescript
// Before (failing)
await page.goto("/url");
await page.locator('[data-testid="content"]').click();

// After (fixed)
await page.goto("/url");
await page.waitForLoadState("networkidle");
await page.locator('[data-testid="content"]').waitFor();
await page.locator('[data-testid="content"]').click();
```

**3. Feature Flag Issues**

```typescript
// Before (failing - feature not enabled)
await page.goto("/dashboard/payouts");

// After (fixed - enable feature)
test.beforeEach(async ({ page }) => {
  await page.route("/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features.payouts = true; // Enable required feature
    await route.fulfill({ response, json });
  });
});
```

**4. Data Issues**

```typescript
// Before (failing - invalid data)
await page.fill('[name="amount"]', "invalid");

// After (fixed)
await page.fill('[name="amount"]', "100.00");
```

### Healing Loop

For each failing test:

```
Attempt 1: Identify issue from error message
  → Apply fix
  → Document fix in comments

Attempt 2: If still failing, use browser tools to debug
  → Navigate to page
  → Reproduce steps manually
  → Capture snapshot/console logs
  → Apply targeted fix

Attempt 3: If still failing, use defensive patterns
  → Add explicit waits
  → Use more robust selectors
  → Add retry logic
  → Consider test.fixme() if unresolvable
```

## Step 4: Document Fixes

Add comments to fixed tests:

```typescript
// Fixed: Added wait for API response
// Was failing because element rendered before data loaded
await page.waitForResponse("**/api/payments");
await page.locator('[data-testid="payment-list"]').waitFor();

// Fixed: Changed selector - old one was too generic
// Error: "strict mode violation: multiple elements found"
await page.locator('[data-testid="submit-button"]').click();
```

## Step 5: Update Run Results

After fixes, update `run-results.json`:

```json
{
  "fixesApplied": [
    {
      "test": "test name",
      "fix": "description of fix applied",
      "attempt": 1
    }
  ],
  "status": "fixed|partial|failed"
}
```

## Step 6: Return to Orchestrator

Update `session.json`:

```json
{
  "phase": "healing-complete",
  "metrics": {
    "fixesApplied": N,
    "testsStillFailing": M
  }
}
```

Report to orchestrator:

- "Healing complete. {N} tests fixed, {M} still failing"
- List of fixes applied
- Any tests marked as fixme

---

## Common Fixes Reference

### Wait Patterns

```typescript
// Wait for element to be visible
await page.locator("selector").waitFor({ state: "visible" });

// Wait for API response
await page.waitForResponse("**/api/endpoint");

// Wait for navigation
await page.waitForURL(/\/dashboard\/home/);

// Wait for load state
await page.waitForLoadState("networkidle");
```

### Robust Selectors

```typescript
// Prefer semantic selectors
await page.getByRole("button", { name: /submit/i });
await page.getByLabel("Email");
await page.getByTestId("email-input");

// Avoid brittle selectors
// ❌ await page.locator('.btn-primary');
// ❌ await page.locator('div > span:nth-child(3)');
```

### Error Handling

```typescript
// Handle optional elements
const element = page.locator('[data-testid="optional"]');
if (await element.isVisible().catch(() => false)) {
  await element.click();
}
```

## References

- Conventions: `SKILL.md`
- Generation: `_generator.md`
- Orchestrator: `orchestrator.md`
