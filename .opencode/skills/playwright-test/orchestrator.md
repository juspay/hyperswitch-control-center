---
name: playwright-orchestrator
description: Central dispatcher for Playwright test automation. Receives ALL user requests from SKILL.md, detects execution mode (full/plan/heal), and orchestrates the appropriate workflow by delegating to sub-agents (playwright-planner, playwright-generator, playwright-healer). THIS FILE SHOULD BE EXECUTED BY THE MAIN AGENT (YOU), NOT DELEGATED.
mode: primary
---

# Playwright Test Orchestrator

> **CENTRAL DISPATCHER - All user requests flow through here**

**Who calls this:** SKILL.md (ALWAYS - sole entry point)
**What you do:** Detect execution mode, orchestrate workflow by DELEGATING to sub-agents via task() calls, manage state, produce summary
**What you do NOT do:** Implement test pipeline logic directly (delegate to specialized agents via task())

**CRITICAL RULE:** You MUST use task() to delegate to sub-agents. Do NOT do the work yourself.

---

## Mode-Specific Pipeline Flows

### Full Pipeline Mode

```
Step 1: Parse → Step 2: Setup → Step 3: Plan → Step 4: Generate → Step 5: Run
    → Step 6: Fix (if fail) → Step 7: Summary → Step 8: Finalization (User Choice + Cleanup)
```

### Plan-Only Mode

```
Step 1: Parse → Step 2: Setup → Step 3: Plan → Step 7: Summary → Step 8: Finalization
```

### Heal-Only Mode

```
Step 1: Parse → Step 2: Setup → Step 5: Run → Step 6: Fix → Step 7: Summary → Step 8: Finalization
```

> **Note:** Step 8 has two parts - Part A presents options and waits for user input, Part B executes cleanup after user responds.

---

## Agent Delegation Reference

| Agent Name      | Subagent Type          | Instructions File | Called In Modes           | Purpose                          |
| --------------- | ---------------------- | ----------------- | ------------------------- | -------------------------------- |
| playwright-test | `playwright-planner`   | `_planner.md`     | Full, Plan-Only           | Creates comprehensive test plans |
| playwright-test | `playwright-generator` | `_generator.md`   | Full                      | Generates test code from plans   |
| playwright-test | `playwright-healer`    | `_healer.md`      | Full (if fail), Heal-Only | Fixes failing tests              |

**How to invoke:**

```typescript
await task({
  mode: "subagent",
  category: "unspecified-high",
  load_skills: ["playwright-test", "playwright-planner"],
  mcp: ["playwright"],
  subagent_type:
    "playwright-planner" | "playwright-generator" | "playwright-healer",
  prompt: "You are playwright-{role}...",
});
```

---

## Step 1: Parse Input & Detect Mode

### PRECONDITION

Before executing this step, verify:

- User input received from SKILL.md via conversation context

### EXECUTE

1. Extract from conversation context:
   - Raw user message
   - Any PR numbers, module names, or scenario descriptions

2. Detect execution mode by analyzing keywords:
   | Keywords Detected | Mode |
   | ------------------------------------------------------------------- | ------------- |
   | "plan tests", "create test plan" | **plan-only** |
   | "fix failing tests", "fix tests", "heal tests", "repair tests" | **heal-only** |
   | "generate tests", "create test flow", "run playwright tests", "test PR #123" (without above modifiers) | **full** |
   | Default (no specific keywords) | **full** |

3. Parse target based on mode:
   - **PR Mode:** PR number (e.g., #123)
   - **Module Mode:** module name (e.g., "auth", "payments")
   - **Scenario Mode:** description text
   - **Tag Mode:** tag name

4. Generate session ID:

   ```javascript
   sessionId = crypto.randomUUID();
   ```

5. Write `input-context.json`:
   ```json
   {
     "rawInput": "user's message",
     "mode": "full|plan-only|heal-only",
     "target": "#123|auth|description",
     "targetType": "pr|module|scenario|tag",
     "timestamp": "ISO",
     "sessionId": "uuid"
   }
   ```

### VERIFY

- [ ] `mode` is one of: ["full", "plan-only", "heal-only"]
- [ ] `sessionId` is a valid UUID format
- [ ] `input-context.json` was written successfully
- [ ] `target` is not empty

### ONLY PROCEED TO STEP 2 IF ALL VERIFY CHECKS PASS

If any check fails:

1. Repeat step for 2 times
2. If fail: Report failure to user, If not: Continue
3. Log error: "Step 1 failed: [specific failure reason]"

### SESSION UPDATE

Initialize `session.json`:

```json
{
  "sessionId": "uuid",
  "mode": "detected-mode",
  "status": "initialized",
  "phase": "parse",
  "startedAt": "ISO",
  "servers": { "backendWasStarted": false, "frontendWasStarted": false },
  "metrics": {
    "testsPlanned": 0,
    "testsGenerated": 0,
    "testsPassed": 0,
    "testsFailed": 0,
    "fixesApplied": 0
  }
}
```

### HANDOVER TO STEP 2

Proceed to Step 2 for ALL modes.

---

## Step 2: Environment Setup

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="parse"`
- `mode` is one of ["full", "plan-only", "heal-only"]

### EXECUTE

1. Check backend health:

   ```bash
   curl -s http://localhost:8080/health
   ```

   **If DOWN or non-200 response:**
   - Run: `sh cypress/start_hyperswitch.sh`
   - Poll every 5s, max 120s
   - Set `backendWasStarted = true`
   - If still DOWN after 120s: ask user to continue or abort

2. Check frontend:

   ```bash
   curl -s http://localhost:9000 > /dev/null && echo "UP" || echo "DOWN"
   ```

   **If DOWN:**
   - Run: `npm run build:test && npm run test:start`
   - Poll every 5s, max 120s
   - Set `frontendWasStarted = true`
   - If still DOWN after 120s: ask user to continue or abort

### VERIFY

- [ ] Backend responds with HTTP 200 on `:8080/health`
- [ ] Frontend responds with HTTP 200 on `:9000`
- [ ] Both services are accessible

### ONLY PROCEED TO STEP 3 IF BOTH SERVICES ARE UP

If either service is DOWN:

1. Log error: "Step 1 failed: [specific failure reason]"
2. Repeat step for 2 times
3. If fail: Report failure to user, If not: Continue
4. Update `session.json`:
   ```json
   { "status": "failed", "phase": "setup", "error": "Environment setup failed" }
   ```
5. STOP pipeline
6. Report failure to user

### SESSION UPDATE

Update `session.json`:

```json
{
  "phase": "setup",
  "servers": {
    "backendWasStarted": true|false,
    "frontendWasStarted": true|false
  }
}
```

### HANDOVER TO NEXT STEP

- **Full mode** → Step 3
- **Plan-Only mode** → Step 3
- **Heal-Only mode** → Step 5

---

## Step 3: Plan Tests (All Modes)

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="setup"`
- Backend and frontend services are running
- `input-context.json` exists with parsed input

### EXECUTE

Delegate to playwright-planner agent via task():

### VERIFY

- [ ] `test-plan.json` exists in session directory
- [ ] `test-plan.json` contains valid JSON
- [ ] `scenarios` array exists with length > 0
- [ ] Each scenario has required fields: id, title, category, steps
- [ ] Agent reported success in result

### ONLY PROCEED TO NEXT STEP IF ALL VERIFY CHECKS PASS

If verification fails:

1. Update `session.json`:
   ```json
   {
     "status": "failed",
     "phase": "planning",
     "error": "Test plan creation failed"
   }
   ```
2. STOP pipeline
3. Report error to user

### SESSION UPDATE

Update `session.json`:

```json
{
  "phase": "planning",
  "metrics": { "testsPlanned": N }
}
```

### HANDOVER TO NEXT STEP

- **Full mode** → Step 4
- **Plan-Only mode** → Step 7
- **Heal-Only mode** → Step 5

---

## Step 4: Generate Tests (Full Mode Only)

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="planning"`
- `mode === "full"`
- `test-plan.json` exists with valid scenarios
- **SKIP this step for plan-only and heal-only modes**

### EXECUTE

Delegate to playwright-generator agent via task():

### VERIFY

- [ ] At least one `.spec.ts` file created in `playwright-tests/ai-generated/`
- [ ] Generated files contain valid TypeScript/Playwright syntax
- [ ] Files follow naming convention from SKILL.md
- [ ] Agent reported success with file count

### ONLY PROCEED TO STEP 5 IF TEST FILES GENERATED

If generation fails:

1. Update `session.json`:
   ```json
   {
     "status": "failed",
     "phase": "generating",
     "error": "Test generation failed"
   }
   ```
2. STOP pipeline
3. Report error to user

### SESSION UPDATE

Update `session.json`:

```json
{
  "phase": "generating",
  "metrics": { "testsGenerated": N }
}
```

### HANDOVER TO STEP 5

Proceed to Step 5 for Full mode.

---

## Step 5: Run Tests (Full Mode Only)

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="generating"`
- `mode === "full"`
- Test files exist in `playwright-tests/ai-generated/`
- **SKIP this step for plan-only mode**
- **ALWAYS run for heal-only mode** (tests should already exist)

### EXECUTE

Run tests via CLI:

```bash
npx playwright test playwright-tests/ai-generated/*.spec.ts --reporter=json --output=test-results/
```

Capture exit code and output.

### VERIFY

- [ ] `run-results.json` created successfully
- [ ] JSON contains valid test results structure
- [ ] Required fields present: status, summary.total, summary.passed, summary.failed
- [ ] Can parse `testsPassed` and `testsFailed` counts

Write `run-results.json`:

```json
{
  "status": "passed|failed|partial",
  "testFile": "path",
  "timestamp": "ISO",
  "summary": { "total": 0, "passed": 0, "failed": 0, "skipped": 0 },
  "failures": [{ "test": "name", "error": "message", "location": "file:line" }]
}
```

### ONLY PROCEED TO NEXT STEP IF RESULTS CAPTURED

If test run fails to produce results:

1. Update `session.json`:
   ```json
   { "status": "failed", "phase": "running", "error": "Test execution failed" }
   ```
2. STOP pipeline
3. Report error to user

### SESSION UPDATE

Update `session.json`:

```json
{
  "phase": "running",
  "metrics": {
    "testsPassed": N,
    "testsFailed": N
  }
}
```

### HANDOVER TO NEXT STEP

- **If `testsFailed > 0`** → Step 6
- **If `testsFailed == 0`** → Step 7

---

## Step 6: Fix Failures (Full & Heal-Only Modes)

### PRECONDITION

Before executing this step, verify ONE of:

- **Full mode:** `phase="running"` AND `testsFailed > 0`
- **Heal-Only mode:** `run-results.json` exists with failures
- **SKIP this step for plan-only mode**

### EXECUTE

Delegate to playwright-healer agent via task():

### VERIFY

- [ ] Agent reported completion
- [ ] Test files were modified (check timestamps or git diff)
- [ ] **Full mode only:** Re-run tests to verify fixes applied

**For Full mode after healing:**
Re-run: `npx playwright test {files} --reporter=json`
Verify failures reduced or tests now pass.

### ONLY PROCEED TO STEP 7 IF FIXES APPLIED OR MAX ATTEMPTS REACHED

If healing fails completely:

1. Mark remaining failures with `.fixme()` in test files
2. Log: "Healing incomplete - marked failures as fixme"
3. Continue to Step 7 (do not stop pipeline)

### SESSION UPDATE

Update `session.json`:

```json
{
  "phase": "healing",
  "metrics": {
    "fixesApplied": N,
    "testsPassed": [updated count],
    "testsFailed": [updated count]
  }
}
```

### HANDOVER TO STEP 7

Proceed to Step 7 for all applicable modes.

---

## Step 7: Generate Summary (All Modes)

### PRECONDITION

Before executing this step, verify:

- **Full mode:** `phase` is "running" or "healing"
- **Plan-Only mode:** `phase="planning"`
- **Heal-Only mode:** `phase="healing"`

### EXECUTE

1. Read all relevant JSON files:
   - `input-context.json` (request details)
   - `test-plan.json` (planned count)
   - `run-results.json` (if exists - pass/fail counts)
   - `session.json` (metrics)

2. Calculate duration: `Date.now() - new Date(startedAt).getTime()`

3. Write `summary.json`:

```json
{
  "sessionId": "uuid",
  "mode": "full|plan-only|heal-only",
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

### VERIFY

- [ ] `summary.json` created successfully
- [ ] All required fields present
- [ ] Numbers match session.json metrics
- [ ] Status determined correctly:
  - "complete" = all tests passed
  - "partial" = some tests failed or fixme
  - "failed" = critical error stopped pipeline

### ONLY PROCEED TO STEP 8 IF SUMMARY GENERATED

If summary generation fails:

1. Log error details
2. Continue to Step 8 with partial data (do not stop pipeline)

### SESSION UPDATE

Update `session.json`:

```json
{
  "phase": "summary"
}
```

### HANDOVER TO STEP 8

Proceed to Step 8 for ALL modes.

---

## Step 8: Finalization - User Choice & Cleanup (All Modes)

> **CRITICAL: This is the FINAL step. User input MUST be collected before any cleanup actions.**

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="summary"`
- `summary.json` exists (even if partial)

### PART A: Present Summary & Collect User Choice

1. **Generate Bug Report** (if failures exist):
   - Read `run-results.json` failures array
   - Create `bug-report.md` with structured findings
   - Include: test name, error message, location, suggested fix

2. **Present Summary to User:**

   ```
   === Test Run Complete ===

   Mode: [full|plan-only|heal-only]
   Tests Planned: N
   Tests Generated: N
   Tests Passed: N
   Tests Failed: N
   Fixes Applied: N
   Duration: N ms

   What would you like to do?

   [1] commit       - Commit and push all changes (create PR)
   [2] keep-passing - Commit only passing tests (delete .fixme() tests)
   [3] keep         - Keep all files (no cleanup)
   [4] clean        - Delete all generated files

   Reply with your choice (1, 2, 3, or 4) or type the action name.
   ```

3. **WAIT FOR USER INPUT** ⏸️

   > **STOP HERE. DO NOT PROCEED WITHOUT USER CHOICE.**
   - The orchestrator MUST end its current response after presenting options
   - Wait for the user's explicit reply
   - Only after user responds, continue to Part B

4. **Parse User Response** (on next interaction):
   - Valid choices: `commit`, `keep-passing`, `keep`, `clean`
   - Aliases: `1`→`commit`, `2`→`keep-passing`, `3`→`keep`, `4`→`clean`
   - Store validated choice in `session.json`

### PART B: Execute Cleanup (After User Responds)

> **Only execute Part B after the user has provided their choice.**

#### PRECONDITION FOR PART B

- User has responded with a valid choice
- `session.json` updated with `userChoice`

#### EXECUTE CLEANUP ACTIONS

1. **Stop Servers** (if we started them):

   ```bash
   # If session.json.servers.backendWasStarted == true:
   cd hyperswitch
   docker rm -f hyperswitch-mailhog-1 2>/dev/null
   docker compose down -v
   ```

   ```bash
   # If session.json.servers.frontendWasStarted == true:
   # Kill process on port 9000
   lsof -ti:9000 | xargs kill -9
   ```

2. **Execute User Choice:**

   | Choice         | Action                                                        |
   | -------------- | ------------------------------------------------------------- |
   | `commit`       | Commit changes, push to branch, create PR                     |
   | `keep-passing` | Delete tests with `.fixme()` or in failing files, then commit |
   | `keep`         | No action - leave all files as-is                             |
   | `clean`        | Delete ai-generated/\*.spec.ts, clear session files           |

### SESSION UPDATE

After Part A (presenting options):

```json
{
  "phase": "awaiting-user-choice",
  "message": "Waiting for user input: commit|keep-passing|keep|clean"
}
```

After Part B (cleanup complete):

```json
{
  "status": "complete",
  "phase": "cleanup",
  "userChoice": "commit|keep-passing|keep|clean",
  "completedAt": "ISO"
}
```

### VERIFY

**After Part A:**

- [ ] Summary presented to user
- [ ] Options clearly listed with numbers and names
- [ ] Session shows `phase="awaiting-user-choice"`
- [ ] **Orchestrator response ENDS here - waits for user**

**After Part B:**

- [ ] Valid user choice received and parsed
- [ ] Servers stopped (if we started them)
- [ ] Files cleaned according to user choice
- [ ] No orphaned processes
- [ ] Session marked complete

### HANDLING INVALID USER INPUT

If user provides invalid input:

1. Respond: `"Invalid choice '{input}'. Please reply with: commit, keep-passing, keep, or clean (or 1, 2, 3, 4)"`
2. Remain in `awaiting-user-choice` phase
3. Wait for valid input

### COMPLETION REPORT

After successful cleanup, report to user:

```
=== Pipeline Complete ===

Session ID: {uuid}
Mode: {mode}
Action Taken: {userChoice}
Status: complete
Duration: {ms} ms

Files:
- Test Plan: {path}
- Test Files: {paths}
- Results: {path}
- Summary: {path}
- Bug Report: {path} (if failures exist)

Next Steps:
- Review generated tests: playwright-tests/ai-generated/
- Review test plan: .opencode/sessions/playwright-run/test-plan.json
```

=== Test Run Complete ===

Mode: [full|plan-only|heal-only]
Tests Planned: N
Tests Generated: N
Tests Passed: N
Tests Failed: N
Fixes Applied: N
Duration: N ms

Choose action:

1.  Commit and push all changes
2.  Commit passing only (delete fixme tests)
3.  Keep all (no cleanup)
4.  Clean slate (delete all generated files)

````

3. **Capture User Choice** and store for Step 9

### VERIFY

- [ ] User has made a selection
- [ ] Choice is one of: ["commit", "keep", "keep-passing", "clean"]
- [ ] Choice stored in session

### **ONLY PROCEED TO STEP 9 IF USER CHOICE CONFIRMED**

Wait for user input if needed.

### SESSION UPDATE

Update `session.json`:

```json
{
"phase": "options",
"userChoice": "commit|keep|keep-passing|clean"
}
````

### HANDOVER TO STEP 9

Proceed to Step 9 for ALL modes.

---

## Step 9: Cleanup (All Modes)

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="options"`
- `userChoice` is set

### **PROCEED ONLY IF STEP 8 IS COMPLETED WITH USER CHOICE**

### EXECUTE

1. **Stop Servers** (if we started them):

   ```bash
   # If session.json.servers.backendWasStarted == true:
   cd hyperswitch
   docker rm -f hyperswitch-mailhog-1 2>/dev/null
   docker compose down -v
   ```

   ```bash
   # If session.json.servers.frontendWasStarted == true:
   # Kill process on port 9000
   lsof -ti:9000 | xargs kill -9
   ```

2. **File Cleanup** (per `userChoice`):
   | Choice | Action |
   | ------------- | ---------------------------------------------------- |
   | `commit` | Commit changes, push to branch, create PR |
   | `keep` | No action - leave all files |
   | `keep-passing`| Delete tests with `.fixme()` or in failing files |
   | `clean` | Delete ai-generated/\*.spec.ts, clear session files |

### VERIFY

- [ ] Servers stopped (if we started them)
- [ ] Files cleaned according to user choice
- [ ] No orphaned processes
- [ ] Session marked complete

### ONLY PROCEED TO END IF CLEANUP COMPLETED

If cleanup fails:

1. Log warning: "Cleanup incomplete - manual intervention may be needed"
2. Continue to finalize session (do not block on cleanup errors)

### SESSION UPDATE

Finalize `session.json`:

```json
{
  "status": "complete",
  "phase": "cleanup",
  "completedAt": "ISO"
}
```

### HANDOVER TO END

Report completion to user:

```
=== Pipeline Complete ===

Session ID: {uuid}
Mode: {mode}
Status: complete
Duration: {ms} ms

Files:
- Test Plan: {path}
- Test Files: {paths}
- Results: {path}
- Summary: {path}

Next: Review generated tests in playwright-tests/ai-generated/
```

---

## Error Handling

| Error                  | Action                                              |
| ---------------------- | --------------------------------------------------- |
| gh not auth            | Prompt: "Run `gh auth login`"                       |
| PR not found           | List recent PRs, ask to verify                      |
| Backend timeout        | Report, ask to continue or abort                    |
| Agent fails            | Update status, report error, offer retry            |
| All heal attempts fail | Mark fixme, continue to summary                     |
| Test file not found    | Check path, regenerate if needed                    |
| Selector not found     | Log warning, use fallback selector, continue        |
| Session corruption     | Log error, attempt recovery from input-context.json |

---

## References

| File                                   | Purpose                   |
| -------------------------------------- | ------------------------- |
| `SKILL.md`                             | Conventions & entry point |
| `_planner.md`                          | Planning logic            |
| `_generator.md`                        | Generation logic          |
| `_healer.md`                           | Healing logic             |
| `playwright.config.ts`                 | Playwright configuration  |
| `playwright-tests/support/commands.ts` | API helpers               |
