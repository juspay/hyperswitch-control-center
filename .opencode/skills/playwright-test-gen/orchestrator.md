---
name: playwright-orchestrator
description: Central dispatcher for Playwright test automation. Receives ALL user requests from SKILL.md, detects execution mode (full/plan/generate/heal), and orchestrates the appropriate workflow with consistent setup, summary, bug reports, and cleanup across all modes.
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

# Playwright Test Orchestrator

> 🎯 **CENTRAL DISPATCHER - All user requests flow through here**

**Who calls this:** SKILL.md (ALWAYS - sole entry point)  
**What you do:** Detect execution mode, orchestrate workflow, manage state, produce summary  
**What you do NOT do:** Implement test logic directly (delegate to specialized agents)

---

## Execution Modes

Detect mode from user input and execute appropriate workflow:

| Mode              | Trigger Phrases                                                                         | Steps Executed    | Output                               |
| ----------------- | --------------------------------------------------------------------------------------- | ----------------- | ------------------------------------ |
| **Full Pipeline** | "generate tests", "create test flow", "run playwright tests", "test PR/module/scenario" | 1→2→3→4→5→6→7→8→9 | Complete test suite with bug reports |
| **Plan-Only**     | "plan tests", "create test plan", "analyze for testing"                                 | 1→2→3→7→8→9       | test-plan.json + summary             |
| **Generate-Only** | "generate test cases", "write test code", "create test file"                            | 1→2→4→7→8→9       | \*.spec.ts files + summary           |
| **Heal-Only**     | "heal tests", "fix failing tests", "debug playwright", "repair tests"                   | 1→2→6→7→8→9       | Fixed tests + summary                |

All modes include:

- ✅ Step 1: Parse input
- ✅ Step 2: Environment setup (server checks)
- ✅ Step 7: Summary generation
- ✅ Step 8: Bug reports (if issues) + commit options
- ✅ Step 9: Cleanup

---

## Mode-Specific Pipeline Flows

### Full Pipeline Mode

```
User Input → Step 1: Parse → Step 2: Setup → Step 3: _planner → Step 4: _generator → Step 5: Run → Step 6: _healer (if fail) → Step 7: Summary → Step 8: Bug Reports + Options → Step 9: Cleanup
```

### Plan-Only Mode

```
User Input → Step 1: Parse → Step 2: Setup → Step 3: _planner → Step 7: Summary → Step 8: Options → Step 9: Cleanup
```

### Generate-Only Mode

```
User Input → Step 1: Parse → Step 2: Setup → Step 3: _planner → Step 4: _generator → Step 7: Summary → Step 8: Options → Step 9: Cleanup
```

### Heal-Only Mode

```
User Input → Step 1: Parse → Step 2: Setup → Step 6: _healer → Step 7: Summary → Step 8: Options → Step 9: Cleanup
```

---

## Agent Delegation Reference

| Agent          | File            | Called In Modes           | Purpose                          |
| -------------- | --------------- | ------------------------- | -------------------------------- |
| Test Planner   | `_planner.md`   | Full, Plan-Only           | Creates comprehensive test plans |
| Test Generator | `_generator.md` | Full, Generate-Only       | Generates test code from plans   |
| Test Healer    | `_healer.md`    | Full (if fail), Heal-Only | Fixes failing tests              |

---

## State Management

**Session Directory:** `.opencode/sessions/playwright-run/{sessionId}/`

| File                 | Purpose                              | Updated By         |
| -------------------- | ------------------------------------ | ------------------ |
| `session.json`       | Pipeline state, mode, phase, metrics | You (every step)   |
| `input-context.json` | Parsed user request                  | Step 1             |
| `test-plan.json`     | Structured test scenarios            | Step 3 (\_planner) |
| `run-results.json`   | Test execution results               | Step 5             |
| `summary.json`       | Final report                         | Step 7             |
| `bug-report.md`      | Bug findings (if failures)           | Step 8             |

**Session JSON Schema:**

```json
{
  "sessionId": "uuid",
  "mode": "full|plan-only|generate-only|heal-only",
  "status": "initialized|running|complete|failed",
  "phase": "parse|setup|planning|generating|running|healing|summary|cleanup",
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
    "testPlan": "test-plan.json",
    "testFile": "playwright-tests/ai-generated/*.spec.ts",
    "results": "run-results.json",
    "summary": "summary.json"
  }
}
```

---

## Step 1: Parse Input & Detect Mode

### 1.1 Read User Input

Extract from the conversation context:

- Raw user message
- Any PR numbers, module names, or scenario descriptions

### 1.2 Detect Execution Mode

Analyze user input keywords:

| Keywords Detected                                                   | Mode              |
| ------------------------------------------------------------------- | ----------------- |
| "plan" OR "analyze" OR "create test plan"                           | **plan-only**     |
| "generate" AND ("cases" OR "code" OR "write")                       | **generate-only** |
| "heal" OR "fix" OR "debug" OR "repair"                              | **heal-only**     |
| "generate" OR "create" OR "run" OR "test" (without above modifiers) | **full**          |
| Default (no specific keywords)                                      | **full**          |

### 1.3 Parse Target

Based on mode, extract:

- **PR Mode:** PR number (e.g., #123)
- **Module Mode:** module name (e.g., "auth", "payments")
- **Scenario Mode:** description text
- **Tag Mode:** tag name

### 1.4 Generate Session ID

```javascript
sessionId = crypto.randomUUID();
```

### 1.5 Write input-context.json

```json
{
  "rawInput": "user's message",
  "mode": "full|plan-only|generate-only|heal-only",
  "target": "#123|auth|description",
  "targetType": "pr|module|scenario|tag",
  "timestamp": "ISO",
  "sessionId": "uuid"
}
```

### 1.6 Initialize session.json

```json
{
  "sessionId": "uuid",
  "mode": "detected-mode",
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

## Step 2: Environment Setup

### 2.1 Check Backend

```bash
curl -s http://localhost:8080/health
```

**If DOWN:**

1. Run: `sh cypress/start_hyperswitch.sh`
2. Poll every 5s, max 120s
3. Update `session.json.servers.backendWasStarted = true`
4. If fail: Ask user to continue or abort

### 2.2 Check Frontend

```bash
curl -s http://localhost:9000 > /dev/null && echo "UP" || echo "DOWN"
```

Frontend auto-starts via Playwright webServer if DOWN.

### 2.3 Update Session

```json
{
  "phase": "setup",
  "servers": {
    "backendWasStarted": true|false,
    "frontendWasStarted": true|false
  }
}
```

---

## Step 3: Plan Tests (Full & Plan-Only Modes)

**Skip this step for:** generate-only, heal-only modes

**Delegate to:** `_planner.md`

### 3.1 Task Planner

Read `input-context.json` and delegate to planner agent.

**Input:** input-context.json  
**Output:** test-plan.json

### 3.2 Verify Output

Check test-plan.json exists with scenarios array.

**On fail:**

- Update session.json status="planning-failed"
- Report error
- Stop

### 3.3 Update Session

```json
{
  "phase": "planning",
  "metrics": { "testsPlanned": N }
}
```

---

## Step 4: Generate Tests (Full & Generate-Only Modes)

**Skip this step for:** plan-only, heal-only modes

**Delegate to:** `_generator.md`

### 4.1 Check Scenario Count

Read test-plan.json (or use provided context for generate-only mode).

- If ≤ 20: Generate all in one batch
- If > 20: Split into chunks of 10

### 4.2 Task Generator

Delegate to generator agent with context.

**Input:** test-plan.json (or explicit requirements)  
**Output:** `playwright-tests/ai-generated/*.spec.ts`

### 4.3 Update Session

```json
{
  "phase": "generating",
  "metrics": { "testsGenerated": N }
}
```

---

## Step 5: Run Tests (Full Mode Only)

**Skip this step for:** plan-only, generate-only, heal-only modes

**Execute:** `npx playwright test {test-file} --reporter=json --output=test-results/`

### 5.1 Capture Results

Write run-results.json:

```json
{
  "status": "passed|failed|partial",
  "testFile": "path",
  "timestamp": "ISO",
  "summary": { "total": 0, "passed": 0, "failed": 0, "skipped": 0 },
  "failures": [{ "test": "name", "error": "message", "location": "file:line" }]
}
```

### 5.2 Update Session

```json
{
  "phase": "running",
  "metrics": {
    "testsPassed": N,
    "testsFailed": N
  }
}
```

---

## Step 6: Fix Failures (Full & Heal-Only Modes)

**Skip this step for:** plan-only, generate-only modes (unless explicitly requested)

**Execute for:** Full mode (if tests failed) OR heal-only mode

**Delegate to:** `_healer.md`

### 6.1 Check Condition

- **Full mode:** Only if `run-results.json` shows failures
- **Heal-only mode:** Always (user explicitly requested)

### 6.2 Task Healer

Read run-results.json and failing test files, delegate to healer.

**Input:** run-results.json + failing test files  
**Output:** Fixed test files

### 6.3 Re-run Tests (Full Mode Only)

After healing, re-run tests to verify fixes.

### 6.4 Update Session

```json
{
  "phase": "healing",
  "metrics": { "fixesApplied": N }
}
```

---

## Step 7: Generate Summary

**Execute for ALL modes**

Read all JSON files, write summary.json:

```json
{
  "sessionId": "uuid",
  "mode": "full|plan-only|generate-only|heal-only",
  "request": "raw input",
  "status": "complete|partial|failed",
  "duration": "ms",
  "files": {
    "testPlan": "path/to/test-plan.json",
    "testFiles": ["path/to/test1.spec.ts"],
    "results": "path/to/run-results.json",
    "summary": "path/to/summary.json"
  },
  "results": {
    "testsPlanned": 0,
    "testsGenerated": 0,
    "testsPassed": 0,
    "testsFailed": 0,
    "testsFixed": 0,
    "skipped": 0
  }
}
```

---

## Step 8: Bug Report & User Options

**Execute for ALL modes**

### 8.1 Generate Bug Report (if issues found)

Create structured report from results:

```markdown
## 🧪 Test Results Summary

**Mode:** {mode} | **Target:** {target}
**Status:** {status} | **Duration:** {duration}

### Results

- ✅ Passed: {passed}
- ❌ Failed: {failed}
- 🔧 Fixed: {fixed}

### Findings

[If failures exist, list them with severity]

### Recommendations

[Suggested fixes or improvements]
```

### 8.2 Post Bug Report

**For PR Mode:** Post as PR comment
**For Other Modes:** Create GitHub issue (optional)

### 8.3 Present Options

Display results and options:

```
Test execution complete!

Mode: {mode}
Results: {summary}

What next?
1. Commit tests to current branch
2. Create new branch + separate PR
3. View bug report
4. Regenerate/Re-run
5. Clean up and exit
```

---

## Step 9: Cleanup

**Execute for ALL modes**

### 9.1 Stop Servers (if we started them)

```bash
# If session.json.servers.backendWasStarted == true:
curl -X POST http://localhost:8080/shutdown 2>/dev/null || \
  pkill -f "hyperswitch" || \
  echo "Backend stop attempted"
```

### 9.2 File Cleanup (per user choice)

| Choice       | Action                                              |
| ------------ | --------------------------------------------------- |
| Keep all     | No action                                           |
| Keep passing | Delete tests with fixme                             |
| Clean slate  | Delete ai-generated/\*.spec.ts, clear session files |

### 9.3 Finalize Session

Update `session.json`:

```json
{
  "status": "complete",
  "phase": "cleanup",
  "completedAt": "ISO"
}
```

---

## Error Handling

| Error                  | Action                                   |
| ---------------------- | ---------------------------------------- |
| gh not auth            | Prompt: "Run `gh auth login`"            |
| PR not found           | List recent PRs, ask to verify           |
| Backend timeout        | Report, ask to continue or abort         |
| Agent fails            | Update status, report error, offer retry |
| All heal attempts fail | Mark fixme, continue to summary          |

---

## References

- Conventions: `SKILL.md`
- Planning: `_planner.md`
- Generation: `_generator.md`
- Healing: `_healer.md`
- Config: `playwright.config.ts`
- Helpers: `playwright-tests/support/commands.ts`
