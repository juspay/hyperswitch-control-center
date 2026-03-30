---
name: playwright-healer
description: Test healer sub-agent. Called by orchestrator Step 6 via task(). Runs structured 3-iteration healing loop — read results, segregate bugs, fix, re-run. Writes bug-report.md and updates run-results.json.
mode: subagent
---

# Playwright Test Healer

**Called by:** orchestrator.md Step 6 ONLY (via task())
**Input:** `.opencode/sessions/playwright-run/run-results.json` + failing test files
**Output:** Fixed test files + `bug-report.md` + updated `run-results.json`

## Guardrail

Only proceed if `session.json` has `status: "healing"` AND `run-results.json` exists with failures. Otherwise inform orchestrator.

## Healing Loop (3 Iterations Max)

```
FOR iteration = 1 to 3:
  1. Read run-results.json (or run tests if iteration > 1)
  2. If all pass → EXIT loop
  3. Segregate failures by root cause
  4. Apply targeted fixes
  5. Re-run tests: npx playwright test playwright-tests/ai-generated/*.spec.ts --reporter=json
  6. Parse results → update run-results.json
  7. If all pass → EXIT loop
END FOR
Write bug-report.md
Update run-results.json with final state
```

## Step 1: Read and Segregate Failures

Read `run-results.json`. Classify each failure:

| Category        | Error Patterns                                    | Fix Strategy                       |
| --------------- | ------------------------------------------------- | ---------------------------------- |
| **selector**    | element not found, strict mode violation           | Verify via browser_snapshot, fix selector |
| **timing**      | TimeoutError, not visible yet                      | Add waits, waitForLoadState        |
| **data**        | Wrong value, empty state, missing data             | Fix test data setup or prerequisites |
| **network**     | net::ERR_*, 4xx/5xx, response timeout              | Check API, add route mocks         |
| **auth**        | Redirected to /login, 401/403                      | Fix beforeEach auth setup          |
| **feature-flag**| Element/page not visible, feature not enabled      | Add route interception for FF      |

Group failures by category — shared root cause = shared fix.

## Step 2: Authenticate for Debugging

Follow the **Browser Auth for Sub-Agent Exploration** flow from SKILL.md:
1. Navigate to login, handle existing session, create temp user, login, skip 2FA
2. Now ready to debug failures via browser tools

## Step 3: Apply Fixes Per Iteration

### Iteration 1 — Targeted Fixes

For each failure category:
1. Read the failing test code
2. `browser_navigate` to the test's target page
3. `browser_snapshot` at the failure point
4. `browser_console_messages` for JS errors
5. Apply the minimum fix:
   - **selector**: Replace with verified selector from snapshot
   - **timing**: Add `waitFor()` or `waitForLoadState("networkidle")`
   - **data**: Fix test setup or add missing API calls in beforeEach
   - **network**: Add `page.route()` mock or `waitForResponse()`
   - **auth**: Ensure beforeEach has correct signupUser + loginUI
   - **feature-flag**: Add route interception before navigation

### Iteration 2 — Deeper Investigation (if failures remain)

- `browser_network_requests` to inspect all API calls during the flow
- Step-by-step reproduction: follow the test actions manually via browser tools
- Compare with working tests in `playwright-tests/e2e/` for the same module
- Check Page Objects for correct selectors
- Apply refined fixes

### Iteration 3 — Defensive Patterns (if failures still remain)

- Add explicit `waitForLoadState("networkidle")` before assertions
- Use more robust selectors (data-testid preferred)
- Add conditional checks for optional elements
- **Mark truly unresolvable tests with `test.fixme()`:**
  ```typescript
  test.fixme("test name", async ({ page }) => {
    // FIXME: [root cause] — [last error] — Attempted: [list of fixes tried]
  });
  ```

### Re-run After Each Iteration

```bash
npx playwright test playwright-tests/ai-generated/*.spec.ts --reporter=json 2>&1
```

Parse output. Update `run-results.json`. If all pass → exit loop.

## Step 4: Write Bug Report

Write `.opencode/sessions/playwright-run/bug-report.md`:

```markdown
# Bug Report

**Session:** {sessionId}  **Date:** {ISO}  **Iterations:** {1-3}

## Summary

| Metric | Count |
| ------ | ----- |
| Total | N |
| Passed | N |
| Fixed | N |
| Unfixed | N |
| Fixme | N |

## Fixed Bugs

### 1. {test name}
- **Root Cause:** {category}
- **Error:** {original error}
- **Fix:** {what was changed}
- **Iteration:** {1|2|3}

## Unfixed Bugs

### 1. {test name}
- **Root Cause:** {category}
- **Error:** {error message}
- **Attempts:** {what was tried}
- **Suggestion:** {recommended manual fix}

## Fixme Tests

### 1. {test name}
- **Reason:** {why it could not be auto-fixed}
- **Last Error:** {error message}
```

## Step 5: Update Run Results

Update `.opencode/sessions/playwright-run/run-results.json`:

```json
{
  "status": "passed|partial|failed",
  "testFile": "path",
  "timestamp": "ISO (updated)",
  "summary": { "total": 0, "passed": 0, "failed": 0, "skipped": 0, "fixme": 0 },
  "failures": [
    { "test": "name", "error": "msg", "location": "file:line", "rootCause": "category", "status": "fixed|unfixed|fixme" }
  ],
  "healingLog": {
    "iterations": 3,
    "fixesApplied": [
      { "test": "name", "fix": "description", "iteration": 1, "rootCause": "category" }
    ]
  }
}
```

## Step 6: Return to Orchestrator

**Call `browser_close` to close the browser session.**

Report: "Healing complete. {N} fixed, {M} unfixed, {K} fixme. Bug report at bug-report.md."
