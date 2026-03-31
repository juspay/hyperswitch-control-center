---
name: playwright-orchestrator
description: Central dispatcher for Playwright test automation. Receives ALL user requests from SKILL.md, detects execution mode (full and heal), and orchestrates the appropriate workflow by delegating to sub-agents (playwright-planner, playwright-generator, playwright-healer). THIS FILE SHOULD BE EXECUTED BY THE MAIN AGENT (YOU), NOT DELEGATED.
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
Step 1: Parse → Step 2: Setup → Step 3: Plan → Step 4: Generate → Step 5: Run → Step 6: Fix (if fail) → Step 7: Summary
```

### Heal-Only Mode

```
Step 1: Parse → Step 2: Setup → Step 3: Plan → Step 5: Run → Step 6: Fix → Step 7: Summary
```

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
   | "generate tests", "create test flow", "run playwright tests", "test PR #123" (without above modifiers) | **full** |
   | "fix failing tests", "fix tests", "heal tests", "repair tests" | **heal-only** |
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
     "mode": "full|heal-only",
     "target": "#123|auth|description",
     "targetType": "pr|module|scenario|tag",
     "timestamp": "ISO",
     "sessionId": "uuid"
   }
   ```

### VERIFY

- [ ] `mode` is one of: ["full", "heal-only"]
- [ ] `sessionId` is a valid UUID format
- [ ] `input-context.json` was written successfully
- [ ] `target` is not empty

ONLY PROCEED TO STEP 2 IF ALL VERIFY CHECKS PASS

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
- `mode` is one of ["full", "heal-only"]

### EXECUTE

1. Check backend health:

   ```bash
   curl -s http://localhost:8080/health
   ```

   **If DOWN or non-200 response:**
   - Run: `sh cypress/start_hyperswitch.sh`
   - Poll every 5s, max 120s
   - Set `backendWasStarted = true` in session.json
   - If still DOWN after 120s: ask user to continue or abort

2. Check frontend:

   ```bash
   curl -s http://localhost:9000 > /dev/null && echo "UP" || echo "DOWN"
   ```

   **If DOWN:**
   - Run: `npm run build:test && npm run test:start`
   - Poll every 5s, max 120s
   - Set `frontendWasStarted = true` in session.json
   - If still DOWN after 120s: ask user to continue or abort

### VERIFY

- [ ] Backend responds with HTTP 200 on `:8080/health`
- [ ] Frontend responds with HTTP 200 on `:9000`
- [ ] Both services are accessible

ONLY PROCEED TO STEP 3 IF BOTH SERVICES ARE UP

If either service is DOWN:

1. Log error: "Step 2 failed: [specific failure reason]"
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
- **Heal-Only mode** → Step 5

---

## Step 4: Generate Tests (Full Mode Only)

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="planning"`
- `mode === "full"`
- `test-plan.json` exists with valid scenarios
- **SKIP this step for heal-only mode**

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

## Step 5: Run Tests (All modes)

### PRECONDITION

Before executing this step, verify:

- `session.json` exists with `phase="generating"` OR `phase="planning"`
- `mode === "full"` OR `mode === heal-only"`
- Test files exist in `playwright-tests/ai-generated/`
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

## Step 6: Fix Failures (All Modes)

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

### ONLY PROCEED TO STEP 7 IF FIXES APPLIED OR MAX ATTEMPTS REACHED

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

## Step 7: Summary, Bug Report & Cleanup Options (FINAL STEP - All Modes)

> **CRITICAL: This is the FINAL step. The pipeline STOPS here after presenting summary, bugs, and cleanup options.**

### PRECONDITION

Before executing this step, verify:

- **Full mode:** `phase` is "running" or "healing"
- **Heal-Only mode:** `phase="healing"`
- Test execution has completed (successfully or with failures)

**Stop Servers** (if we started them):

```bash
# If session.json.servers.backendWasStarted == true:
cd hyperswitch
docker rm -f hyperswitch-mailhog-1 2>/dev/null
docker compose down -v
```

```bash
# If session.json.servers.frontendWasStarted == true:
lsof -ti:9000 | xargs kill -9
```

### EXECUTE

#### PART A: Generate Summary & Bug Report

1. **Read all relevant JSON files:**
   - `input-context.json` (request details)
   - `test-plan.json` (planned count)
   - `run-results.json` (if exists - pass/fail counts)
   - `session.json` (metrics)

2. **Calculate duration:** `Date.now() - new Date(startedAt).getTime()`

3. **Write `summary.json`:**

```json
{
  "sessionId": "uuid",
  "mode": "full|heal-only",
  "request": "raw input",
  "status": "complete|partial|failed",
  "duration": "ms",
  "files": {
    "testPlan": "path/to/test-plan.json",
    "testFiles": ["path/to/test1.spec.ts"],
    "results": "path/to/run-results.json",
    "summary": "path/to/summary.json",
    "bugReport": "path/to/bug-report.md"
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

4. **Generate Bug Report** (if failures exist in `run-results.json`):
   - Read `run-results.json` failures array
   - Create `bug-report.md` with structured findings
   - Include for each failure: test name, error message, location, suggested fix, severity

#### PART B: Present Summary to User (PIPELINE STOPS HERE)

**Display the following to the user:**

```
╔════════════════════════════════════════════════════════════════╗
║                    TEST RUN SUMMARY                            ║
╚════════════════════════════════════════════════════════════════╝

📊 Mode: [full|heal-only]
⏱️  Duration: {N}ms

📋 TEST RESULTS:
   ├─ Tests Planned:     {N}
   ├─ Tests Generated:   {N}
   ├─ Tests Passed:      {N} ✅
   ├─ Tests Failed:      {N} ❌
   ├─ Tests Fixed:       {N} 🔧
   └─ Tests Skipped:     {N} ⏭️

[IF testsFailed > 0, INCLUDE:]

🐛 BUG SUMMARY (from bug-report.md):
   ┌─────────────────────────────────────────────────────────────┐
   │ Test: {test-name}                                           │
   │ Error: {error-message}                                      │
   │ Location: {file:line}                                       │
   │ Severity: [high|medium|low]                                 │
   └─────────────────────────────────────────────────────────────┘
   ... (repeat for each bug)

════════════════════════════════════════════════════════════════

🧹 CLEANUP OPTIONS:

   [1] commit       → Commit + push to {current-branch}
   [2] new-branch   → Create pw/{target}-{timestamp}, commit + push
   [3] clean        → Delete all generated files

════════════════════════════════════════════════════════════════

Reply with your choice (1, 2, 3, or 4) or type the action name.
```

**STOP HERE. DO NOT PROCEED WITHOUT USER INPUT.**

## Cleanup steps (Only After User Responds)

**Parse User Response:**

- Valid choices: `commit`, `new-branch`, `clean`
- Aliases: `1`→`commit`, `2`→`new-branch`, `3`→`clean`
- Store validated choice in `session.json`

**Execute Cleanup Actions:**

| Choice       | Action                                              |
| ------------ | --------------------------------------------------- |
| `commit`     | Commit changes, push to branch, create PR           |
| `new-branch` | Create new branch and push                          |
| `clean`      | Delete ai-generated/\*.spec.ts, clear session files |

### HANDLING INVALID USER INPUT

If user provides invalid input:

1. Respond: `"Invalid choice '{input}'. Please reply with: commit, keep-passing, keep, or clean (or 1, 2, 3, 4)"`
2. Remain in `awaiting-user-choice` phase
3. Wait for valid input

### SESSION UPDATE

After PART A (presenting options):

```json
{
  "phase": "awaiting-user-choice",
  "message": "Waiting for user input: commit|keep-passing|keep|clean"
}
```

After (cleanup complete):

```json
{
  "status": "complete",
  "phase": "cleanup",
  "userChoice": "commit|keep-passing|keep|clean",
  "completedAt": "ISO"
}
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
