---
name: playwright-orchestrator
description: FULL PIPELINE orchestrator for Playwright tests. Manages complete lifecycle: plan→generate→run→heal→summary. Called by SKILL.md for end-to-end flows.
---

# Playwright Test Orchestrator

## Pipeline Flow

```
User Input → SKILL.md → orchestrator.md → _planner → _generator → Run Tests → _healer (if fail) → Validate → Summary → Cleanup
```

## Orchestrator vs Direct Agent Calls

| Approach          | Scope                         | Best For                                                |
| ----------------- | ----------------------------- | ------------------------------------------------------- |
| **Orchestrator**  | Full Lifecycle (9 steps)      | End-to-end test generation from PR/Module/Scenario      |
| **Direct Agents** | Single Step (e.g., \_planner) | Debugging, manual overrides, or specific task execution |

Use the **Orchestrator** when you need a guaranteed "hands-off" experience from input to PR comment.

## Your Role

**Who calls this:** SKILL.md (entry point) - NEVER user input directly  
**What you do:** Central coordinator that delegates to specialized agents  
**What you do NOT do:** Implement test logic directly

You manage state via JSON files and orchestrate the pipeline.

## Pipeline (Mandatory Order)

| Step | Action                               | Delegate To        |
| ---- | ------------------------------------ | ------------------ |
| 1    | Parse input → `input-context.json`   | self               |
| 2    | Check/start servers → `session.json` | self               |
| 3    | Plan tests → `test-plan.json`        | **\_planner.md**   |
| 4    | Generate tests → `*.spec.ts`         | **\_generator.md** |
| 5    | Run tests → `run-results.json`       | self               |
| 6    | Fix failures (if any)                | **\_healer.md**    |
| 7    | Summary → `summary.json`             | self               |
| 8    | Present to user                      | self               |
| 9    | Cleanup                              | self               |

> Steps 3, 4, 6 MUST be delegated. Never skip or inline them.

## Browser MCP Tools (Available to ALL Agents)

All specialized agents (planner, generator, healer) have access to Playwright MCP browser tools to explore the live web application for improved accuracy.

### Available Tools

| Tool                                         | Purpose           | Use When                                |
| -------------------------------------------- | ----------------- | --------------------------------------- |
| `browser_navigate({ url })`                  | Navigate to URL   | Starting exploration, switching pages   |
| `browser_click({ element })`                 | Click element     | Interacting with UI, triggering actions |
| `browser_fill({ element, content })`         | Fill input        | Entering test data                      |
| `browser_select_option({ element, option })` | Select dropdown   | Choosing from select elements           |
| `browser_hover({ element })`                 | Hover element     | Triggering hover states, tooltips       |
| `browser_evaluate({ expression })`           | Execute JS        | Checking component state, feature flags |
| `browser_console_messages()`                 | Get console logs  | Debugging JS errors                     |
| `browser_snapshot({ filename })`             | Capture DOM state | Analyzing page structure                |
| `browser_wait_for({ time })`                 | Wait seconds      | Allowing page load, animations          |
| `browser_scroll({ direction, amount })`      | Scroll page       | Revealing off-screen content            |

### Server Requirements

Before using browser tools, ensure:

- Backend is running on `http://localhost:8080`
- Frontend is running on `http://localhost:9000`

### Delegate with Browser Context

When delegating to agents, they should:

1. Navigate to the target page
2. Explore the live DOM structure
3. Identify selectors dynamically
4. Verify test scenarios against actual UI

## State Management

**Session Directory:** `.opencode/sessions/playwright-run/{sessionId}/`

The session ID enables concurrent runs without data corruption.

| File                 | Purpose                                      | Updated By       |
| -------------------- | -------------------------------------------- | ---------------- |
| `session.json`       | Pipeline state, phase, metrics, server flags | You              |
| `input-context.json` | Parsed user request                          | Step 1           |
| `test-plan.json`     | Structured test scenarios                    | Step 3 (planner) |
| `run-results.json`   | Test execution results                       | Step 5           |
| `summary.json`       | Final report                                 | Step 7           |

**Session JSON Schema:**

```json
{
  "sessionId": "uuid",
  "status": "initialized|running|complete|failed",
  "phase": "parse|planning|generating|running|healing|summary|cleanup",
  "startedAt": "ISO",
  "servers": {
    "backendWasStarted": false,
    "frontendWasStarted": false
  },
  "metrics": {
    "testsGenerated": 0,
    "testsPassed": 0,
    "testsFailed": 0,
    "fixesApplied": 0
  },
  "files": {
    "testFile": "playwright-tests/e2e/{folder}/{name}.spec.ts",
    "testPlan": "test-plan.json",
    "results": "run-results.json"
  }
}
```

## Agent Delegation

| Step | Agent       | Prompt File     | Input              | Output           |
| ---- | ----------- | --------------- | ------------------ | ---------------- |
| 3    | \_planner   | `_planner.md`   | input-context.json | test-plan.json   |
| 4    | \_generator | `_generator.md` | test-plan.json     | \*.spec.ts       |
| 6    | \_healer    | `_healer.md`    | run-results.json   | fixed \*.spec.ts |

## Pipeline Flow

```
Step 1: Parse Input → Write input-context.json + session.json
Step 2: Check/Start Servers → Update session.json
Step 3: Task Planner → Read input-context.json → Write test-plan.json
Step 4: Task Generator → Read test-plan.json → Write *.spec.ts
Step 5: Run Tests → Write run-results.json
Step 6: Task Healer (if fail) → Fix → Update run-results.json
Step 7: Generate Summary → Write summary.json
Step 8: Present to User
Step 9: Cleanup → Stop servers (if started) → Finalize session.json
```

---

## Step 1: Parse and Initialize

### 1.1 Detect Mode

| Pattern             | Mode     | Target       |
| ------------------- | -------- | ------------ |
| `#123` or `PR #123` | pr       | PR number    |
| `#42 #55`           | pr-batch | Multiple PRs |
| `tag:v1.2.0`        | tag      | Tag name     |
| `module:auth`       | module   | Module name  |
| Free text           | scenario | Description  |

### 1.2 Generate Session ID

Generate UUID: `sessionId = crypto.randomUUID()`

Use this ID for the session directory: `.opencode/sessions/playwright-run/{sessionId}/`

### 1.3 Write input-context.json

```json
{
  "rawInput": "user's message",
  "mode": "pr|pr-batch|tag|module|scenario",
  "target": "#123|v1.2.0|auth|description",
  "timestamp": "ISO",
  "inferredScope": "what to test",
  "sessionId": "uuid"
}
```

### 1.4 Initialize session.json

```json
{
  "sessionId": "uuid",
  "status": "initialized",
  "phase": "parse",
  "startedAt": "ISO",
  "servers": { "backendWasStarted": false, "frontendWasStarted": false },
  "metrics": {
    "testsGenerated": 0,
    "testsPassed": 0,
    "testsFailed": 0,
    "fixesApplied": 0
  }
}
```

---

## Step 2: Server Management

### 2.1 Check Backend

```bash
curl -s http://localhost:8080/health > /dev/null && echo "UP" || echo "DOWN"
```

**If DOWN:**

1. Run: `sh cypress/start_hyperswitch.sh`
2. Poll every 5s, max 120s
3. If success: Update `session.json.servers.backendWasStarted = true`
4. If fail: Ask user to continue or abort

**If UP:** Continue

### 2.2 Check Frontend

Frontend auto-starts via Playwright webServer. Just verify:

```bash
curl -s http://localhost:9000 > /dev/null && echo "UP" || echo "DOWN"
```

If DOWN, webServer will handle it.

---

## Step 3: Task Planner

**Delegate to:** `planner` agent

**Action:**

```
Read: input-context.json
Task: planner agent with context
Write: test-plan.json
```

**Verify:** test-plan.json exists with scenarios array

**On fail:** Update session.json status="planning-failed", report error, STOP

---

## Step 4: Task Generator (with Chunking)

**Delegate to:** `generator` agent

### 4.1 Check Scenario Count

Read test-plan.json and count scenarios:

- If ≤ 20: Generate all in one batch
- If > 20: Split into chunks of 10

### 4.2 Chunking Logic

```javascript
const scenarios = testPlan.scenarios;
const CHUNK_SIZE = 10;
const chunks = [];

for (let i = 0; i < scenarios.length; i += CHUNK_SIZE) {
  chunks.push(scenarios.slice(i, i + CHUNK_SIZE));
}
```

### 4.3 Process Chunks

For each chunk:

1. Write chunk-specific test-plan: `test-plan-chunk-{n}.json`
2. Delegate to generator agent
3. Write: `playwright-tests/ai-generated/{name}-chunk-{n}.spec.ts`

### 4.4 Merge Results

After all chunks complete:

- Update session.json.metrics.testsGenerated with total
- Verify all chunk files exist

**On fail:** Update session.json status="generation-failed", report error, STOP

---

## Step 5: Run Tests

**Delegate to:** `oh-my-opencode` agent (built-in)

**Action:**

```
Command: npx playwright test {test-file} --reporter=json --output=test-results/
Capture: JSON output
Write: run-results.json
```

**run-results.json schema:**

```json
{
  "status": "passed|failed|partial",
  "testFile": "path",
  "timestamp": "ISO",
  "summary": { "total": 0, "passed": 0, "failed": 0, "skipped": 0 },
  "failures": [{ "test": "name", "error": "message", "location": "file:line" }]
}
```

**Decision:**

- If passed → Skip to Step 7
- If failed → Step 6

---

## Step 6: Task Healer

**Delegate to:** `healer` agent

**Action:**

```
Read: run-results.json, test file
Task: healer agent (fixes only failing tests)
Re-run: (healer handles internally)
Update: run-results.json with final status
```

**Loop:** Max 3 healing attempts

**On persistent failure:** Mark as `test.fixme()`, continue

---

## Step 7: Generate Summary

Read all JSON files, write summary.json:

```json
{
  "sessionId": "uuid",
  "request": "raw input",
  "mode": "pr|module|scenario",
  "target": "#123|auth|description",
  "status": "complete|partial|failed",
  "duration": "ms",
  "files": {
    "test": "path/to/test.spec.ts",
    "plan": "test-plan.json",
    "results": "run-results.json"
  },
  "results": {
    "total": 0,
    "passed": 0,
    "failed": 0,
    "fixed": 0,
    "fixme": 0,
    "skipped": 0
  },
  "bugReport": {
    "generated": true,
    "title": "Test Results: {mode} {target}",
    "summary": "Brief summary of what was tested and results",
    "findings": [
      {
        "severity": "critical|high|medium|low",
        "category": "functional|ui|performance|security",
        "test": "Test case name",
        "issue": "Description of the issue",
        "reproduction": "Steps to reproduce",
        "expected": "Expected behavior",
        "actual": "Actual behavior",
        "evidence": "Screenshot path or log excerpt"
      }
    ],
    "recommendations": ["Suggested fixes or improvements"],
    "usage": {
      "prMode": "Post as PR comment",
      "otherModes": "Create new GitHub issue"
    }
  },
  "servers": {
    "backendStarted": false,
    "stopped": false
  }
}
```

### Bug Report Generation

Generate structured bug report from test failures:

1. **Analyze Failures**: Read run-results.json failures array
2. **Categorize Issues**:
   - `critical`: Complete failure, blocking functionality
   - `high`: Major functionality broken
   - `medium`: Partial failure, workarounds exist
   - `low`: Minor UI issues, cosmetic

3. **Extract Evidence**:
   - Screenshot paths from test-results/
   - Console logs
   - Error stack traces
   - Network failure details

4. **Generate Markdown Report** (for PR/issue posting):

```markdown
## 🧪 Test Results Summary

**Mode:** {mode} | **Target:** {target}
**Status:** {status} | **Duration:** {duration}

### Results

- ✅ Passed: {passed}
- ❌ Failed: {failed}
- 🔧 Fixed: {fixed}
- ⏸️ Fixme: {fixme}

### Findings

#### 🔴 Critical

1. **{testName}**
   - **Issue:** {description}
   - **Repro:** {steps}
   - **Expected:** {expected}
   - **Actual:** {actual}

#### 🟠 High

...

### Recommendations

1. {recommendation}

---

_Generated by Playwright Test Automation_
```

### Usage Instructions

| Mode                | Action                                                                                                                    |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **PR**              | Post `bugReport.markdown` as PR comment using `gh pr comment {number} --body-file bug-report.md`                          |
| **Module/Scenario** | Create GitHub issue: `gh issue create --title "{bugReport.title}" --body-file bug-report.md --label "bug,automated-test"` |

---

## Step 8: Present to User and Post Bug Report

Display:

1. Summary (from summary.json)
2. Test results
3. File locations
4. Bug report preview (if failures exist)

### 8.1 Post Bug Report

If there are failed tests (`results.failed > 0` or `results.fixme > 0`):

**For PR Mode:**

```bash
gh pr comment {target} --body-file .opencode/sessions/playwright-run/{sessionId}/bug-report.md
```

**For Module/Scenario Mode:**

```bash
gh issue create \
  --title "$(cat summary.json | jq -r '.bugReport.title')" \
  --body-file .opencode/sessions/playwright-run/{sessionId}/bug-report.md \
  --label "bug,automated-test,needs-review"
```

### 8.2 Ask User (Mode-Specific Options)

Display results and present mode-appropriate options:

```
Test execution complete!

Results: {passed} passed, {failed} failed, {fixme} fixme
Bug report: {posted as PR comment / created as GitHub issue #{number} / not generated}

Mode: {pr|module|scenario}
```

**For PR Mode:**

```
What next?
1. Commit tests to current branch (updates PR #{target})
2. Create new branch + separate PR with tests
3. View bug report in PR comments
4. Regenerate failed tests
5. Clean up and exit (keep servers running)
6. Stop servers, clean up and exit
```

**For Module/Scenario Mode:**

```
What next?
1. Create new branch + PR with tests
2. View bug report GitHub issue
3. Regenerate failed tests
4. Clean up and exit (keep servers running)
5. Stop servers, clean up and exit

Note: "Commit to current branch" is not available for module/scenario tests.
      A new PR is required to submit generated tests.
```

### 8.3 Handle User Selection

| Mode                | Selection                   | Action                                                                                 |
| ------------------- | --------------------------- | -------------------------------------------------------------------------------------- |
| **PR**              | 1. Commit to current branch | `git add . && git commit -m "test: add Playwright tests for PR #{target}" && git push` |
| **PR**              | 2. Create new branch + PR   | Create branch `playwright-tests-{target}`, commit, push, create PR                     |
| **PR**              | 3. View bug report          | Open PR #{target} in browser (bug report already posted as comment)                    |
| **PR**              | 4. Regenerate failed tests  | Go back to Step 6 (Healer) with failed tests only                                      |
| **Module/Scenario** | 1. Create new branch + PR   | Create branch `playwright-tests-{module}-{timestamp}`, commit, push, create PR         |
| **Module/Scenario** | 2. View bug report          | Open GitHub issue #{issueNumber} in browser                                            |
| **Module/Scenario** | 3. Regenerate failed tests  | Go back to Step 6 (Healer) with failed tests only                                      |
| **All**             | Exit options                | Proceed to Step 9 (Cleanup)                                                            |

### 8.4 Bug Report Summary

Always display bug report delivery info:

**PR Mode:**

```
📋 Bug Report: Posted as PR comment
   URL: https://github.com/{owner}/{repo}/pull/{target}
```

**Module/Scenario Mode:**

```
📋 Bug Report: Created as GitHub issue
   Issue: #{issueNumber}
   URL: https://github.com/{owner}/{repo}/issues/{issueNumber}
```

---

## Step 9: Cleanup

### 9.1 Stop Servers (if we started them)

Check `session.json.servers.backendWasStarted`:

```bash
# If true:
curl -X POST http://localhost:8080/shutdown 2>/dev/null || \
  pkill -f "hyperswitch" || \
  echo "Backend stop attempted"
```

Update `session.json.servers.stopped = true`

### 9.2 File Cleanup (per user choice)

| Choice       | Action                                              |
| ------------ | --------------------------------------------------- |
| Keep all     | No action                                           |
| Keep passing | Delete tests with fixme                             |
| Clean slate  | Delete ai-generated/\*.spec.ts, clear session files |

### 9.3 Finalize

Update `session.json.status = "complete"`

---

## Server Utilization for Agent Exploration

Agents can leverage running servers to explore the dashboard for better test planning, generation, and healing:

### Dashboard Access

When servers are running, agents can:

- Navigate via browser to `http://localhost:9000` using Playwright's browser automation
- Inspect element hierarchy with `playwright codegen` or `npx playwright open`
- Verify selector accuracy by testing on live UI
- Observe dynamic content loading patterns

### Exploration Workflow

**For Planner Agent:**

1. Navigate to target module after test setup
2. Document page structure, form fields, and interaction flows
3. Identify dynamic elements (tables, modals, loaders)
4. Map user journeys for test scenario generation

**For Generator Agent:**

1. Verify selector availability on live dashboard
2. Test page.goto() paths match actual routing
3. Confirm element visibility patterns
4. Validate API helper integration

**For Healer Agent:**

1. Reproduce failures in browser context
2. Inspect DOM for selector changes
3. Verify timing and wait conditions
4. Test fixes before applying

### Browser Tools Available

| Tool      | Use Case                          | Command                                        |
| --------- | --------------------------------- | ---------------------------------------------- |
| Codegen   | Generate selectors by clicking UI | `npx playwright codegen http://localhost:9000` |
| UI Mode   | Debug failing tests interactively | `npx playwright test --ui`                     |
| Trace     | Record and replay test execution  | `npx playwright test --trace on`               |
| Inspector | Step through test execution       | `PWDEBUG=1 npx playwright test`                |

### Feature Flag Handling

When using page.route() to intercept feature flags:

```typescript
// Intercept feature config
await page.route("**/config/feature*", async (route) => {
  const response = await route.fetch();
  const json = await response.json();
  json.features.payout = true;
  await route.fulfill({ response, json });
});

// Page refresh REQUIRED after intercept
await page.goto("/dashboard/payouts");
await expect(page.getByRole("heading", { name: /payouts/i })).toBeVisible();
```

**Note:** Intercept modifies network response only. A page refresh is required to render UI with feature flags enabled.

## Error Handling

| Error                  | Action                                   |
| ---------------------- | ---------------------------------------- |
| gh not auth            | Prompt: "Run `gh auth login`"            |
| PR not found           | List recent PRs, ask to verify           |
| Backend timeout        | Report, ask to continue or abort         |
| Agent fails            | Update status, report error, offer retry |
| All heal attempts fail | Mark fixme, continue to summary          |

## References

- Conventions: `SKILL.md`
- Planning: `_planner.md`
- Generation: `_generator.md`
- Healing: `_healer.md`
- Config: `playwright.config.ts`
- Helpers: `playwright-tests/support/commands.ts`
