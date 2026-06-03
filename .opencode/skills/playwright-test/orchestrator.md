---
name: playwright-orchestrator
description: Central dispatcher for Playwright test automation. Receives ALL user requests from SKILL.md, detects execution mode (full and heal), and orchestrates the appropriate workflow by DELEGATING to sub-agents (playwright-planner, playwright-generator, playwright-healer). THIS FILE IS EXECUTED BY THE MAIN AGENT (YOU), NOT DELEGATED.
mode: primary
---

# Playwright Test Orchestrator

**YOU are the orchestrator. DELEGATE all work to sub-agents via task(). DO NOT implement pipeline logic yourself.**

> **CENTRAL DISPATCHER - All user requests flow through here**

**Who calls this:** SKILL.md (ALWAYS - sole entry point)
**What you do:** Detect execution mode, orchestrate workflow by DELEGATING to sub-agents via task() calls, manage state, produce summary
**What you do NOT do:** Implement test logic directly (delegate to specialized agents via task())

**CRITICAL RULE:** You MUST use task() to delegate to sub-agents. Do NOT do the work yourself.

---

## Pipeline Flows

| Mode          | Steps                                            |
| ------------- | ------------------------------------------------ |
| **Full**      | Parse → Setup → Plan → Generate → Heal → Summary |
| **Heal-Only** | Parse → Setup → Plan → Heal → Summary            |

## Sub-Agent Delegation

| Sub-Agent              | Instructions file | Called In          | Purpose                          |
| ---------------------- | ----------------- | ------------------ | -------------------------------- |
| `playwright-planner`   | `_planner.md`     | Step 3 (all modes) | Creates comprehensive test plans |
| `playwright-generator` | `_generator.md`   | Step 4 (Full only) | Generates test code from plans   |
| `playwright-healer`    | `_healer.md`      | Step 5 (all modes) | Fixes failing tests              |

**How to invoke:** `task({ category: "unspecified-high", load_skills: ["playwright-test"], subagent_type: "playwright-planner|playwright-generator|playwright-healer", prompt: "You are playwright-{role}..." })`

---

## CRITICAL: Delegation Pattern

**YOU MUST delegate via task() calls. DO NOT implement logic yourself.**

### Correct Delegation Pattern:

````typescript
const plannerResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "playwright-planner",
  run_in_background: false,
  description: "Create test plan via playwright-planner",
  prompt: `
    <YOUR PROMPT>
  `
});

// Check planner result and proceed only if successful
if (!plannerResult.success) {
  report error and stop;
}

---

**Follow File Editing Guidelines from playwright-test skill (CRITICAL)**

When editing any files in this workflow, you **MUST** use surgical edits (`edit`) instead of full file writes (`write`). This preserves existing content and reduces error risk.

---

## Step 1: Parse Input & Detect Mode

### Preconditions

- User input from SKILL.md via conversation context

### Execute

1. Extract detailed raw user message, PR numbers, PR code diff, PR comments, PR description, module names, or scenario descriptions.
2. Detect mode by keywords:
   - `full`: "generate tests", "create test", "test PR #N", "run playwright tests"
   - `heal-only`: "fix failing tests", "fix tests", "heal tests", "repair tests"
3. Parse target (Based on mode extract): PR number, module name, or scenario description
4. Generate `sessionId = crypto.randomUUID()`
5. Write input-context.json `.opencode/sessions/playwright-run/input-context.json`:
   ```json
   {
     "rawInput": "user message",
     "mode": "full|heal-only",
     "target": "#123|auth|description",
     "targetType": "pr|module|scenario",
     "timestamp": "ISO",
     "sessionId": "uuid"
   }
````

6. Initialize session.json `.opencode/sessions/playwright-run/session.json`:

```json
{
  "sessionId": "uuid",
  "mode": "detected-mode",
  "status": "in_progress",
  "phase": "parse",
  "startedAt": "ISO",
  "servers": {
    "backendWasStarted": false,
    "frontendWasStarted": false,
    "frontendPid": null
  },
  "metrics": {
    "testsPlanned": 0,
    "testsGenerated": 0,
    "testsPassed": 0,
    "testsFailed": 0,
    "testsFixed": 0,
    "healingAttempts": 0
  }
}
```

### Verify

- [ ] `mode` is valid: ["full", "heal-only"]
- [ ] `sessionId` is valid UUID
- [ ] Both JSON files written successfully
- [ ] `target` is not empty
- [ ] `targetType` is valid: ["pr", "module", "scenario"]

**If any check fails: STOP, report error to user.**

### Handover

→ Step 2 for ALL modes

---

## Step 2: Environment Setup

### Preconditions

- `session.json` exists with `phase="parse"`
- `mode` is one of ["full", "heal-only"]

### Execute

1. Check backend health: `curl -s http://localhost:8080/health`
   - **If DOWN/non-200:**
     - Run: `sh playwright-tests/start_hyperswitch.sh`
     - Poll every 5s, max 120s
     - Update `session.json.servers.backendWasStarted = true`
     - If still DOWN: ask user to continue or abort
2. Check frontend: `curl -s http://localhost:9000 > /dev/null && echo "UP" || echo "DOWN"`
   - **If UP:**
     - Stop process: `kill -TERM $(lsof -ti:9000) 2>/dev/null; sleep 3; kill -9 $(lsof -ti:9000) 2>/dev/null`
   - **Start frontend:**
     - Run build: `npm run re:start`
     - Start server in background: `npm run start`
     - Capture PID: `FRONTEND_PID=$!`
     - Poll every 5s, max 240s for `curl -s http://localhost:9000 > /dev/null` to return 0
     - Set `frontendWasStarted = true` and store `frontendPid: $FRONTEND_PID`
     - If still DOWN after 120s: `kill $FRONTEND_PID 2>/dev/null` and ask user to continue or abort

### Session Update

Update `session.json`:

```json
{
  "phase": "setup",
  "servers": { "backendWasStarted": true|false, "frontendWasStarted": true|false }
}
```

### Verify

- [ ] Backend responds HTTP 200 on `:8080/health`
- [ ] Frontend responds HTTP 200 on `:9000`

**If either DOWN after 3 attempts:**

1. Update `session.json`: `{ "status": "failed", "phase": "setup", "error": "Environment setup failed" }`
2. STOP, report failure

### Handover

→ Step 3 for ALL modes

---

## Step 3: Plan Tests (All Modes)

### Preconditions

- `session.json` exists with `phase="setup"`
- Both services running
- `input-context.json` exists

### Execute

**CRITICAL:** Delegate to planner agent via task(). DO NOT plan tests yourself.

1. Delegate to playwright-planner:

```typescript
const plannerResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "playwright-planner", // This loads _planner.md instructions
  mcp: ["playwright"],
  run_in_background: false,
  description: "Create test plan via playwright-planner agent",
  prompt: `
    You are the playwright-planner agent. Your job is to create a comprehensive test plan.

    **MANDATORY ACTIONS:**
    1. Read .opencode/skills/playwright-tests/SKILL.md for conventions and API helpers.
    2. Read .opencode/skills/playwright-tests/_planner.md for your specific instructions.
    3. Read .opencode/sessions/playwright-run/input-context.json for the test target.
    4. Use browser tools to explore the application: Refer for navigation NAVIGATION_REFERENCE.md
       - browser_navigate to http://localhost:9000/dashboard/login (or appropriate URL)
       - create new user with signup_with_merchantid API and login and skip 2FA (Use test+{randomstring}@example.com for email and "Password123!" for password)
       - browser_snapshot to analyze page structure
       - Identify all interactive elements, forms, buttons, navigation
    5. Create .opencode/sessions/playwright-run/test-plan.json with detailed scenarios
    
    **Execute the planning workflow:**
    1. Read relevant source code, existing tests in playwright-tests/e2e/ for patterns
    2. Use browser tools to explore the application. Refer for navigation NAVIGATION_REFERENCE.md
    3. Determine preconditions using module mapping from SKILL.md
    4. Create test-plan.json with scenarios

    **Prepare TODO list from _planner.md and follow it strictly**
    **Refer Test Plan Structure in _planner.md**
    
    **Coverage Requirements:**
    - Happy path scenarios
    - Validation scenarios  
    - Error handling scenarios
    - Navigation scenarios
    
    Output: .opencode/sessions/playwright-run/test-plan.json
    Update session.json: { "phase": "planning-complete", "metrics": { "testsPlanned": N } }
    Report: "Planning complete. N scenarios created."
  `,
});
```

### Verify

- [ ] Agent reported success
- [ ] `test-plan.json` exists
- [ ] Contains valid JSON with `scenarios` array length > 0
- [ ] Each scenario has: id, title, category, steps
- [ ] `preconditions` object exists with `description`, `apiHelpers`, and `setupSteps`
- [ ] `session.json` has `phase: "planning-complete"`

**If verification fails:**

1. Update `session.json`: `{ "status": "failed", "phase": "planning", "error": "Test plan creation failed" }`
2. STOP, report error

### Handover

- **Full mode** → Step 4 (when `phase="planning-complete"` and `mode="full"`)
- **Heal-Only mode** → Step 5 (when `phase="planning-complete"` and `mode="heal-only"`)

---

## Step 4: Generate Tests (Full Mode Only)

**Skip this step for:** heal-only mode

**CRITICAL:** Delegate to generator agent via task(). DO NOT generate tests yourself.

### Preconditions

- `session.json` exists with `phase="planning-complete"`
- `mode === "full"`
- `test-plan.json` exists with valid scenarios
- **SKIP for heal-only mode**

### Execute

1. Delegate to playwright-generator:

```typescript
const generatorResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "playwright-generator", // This loads _generator.md instructions
  mcp: ["playwright"],
  run_in_background: false,
  description: "Generate test code via playwright-generator agent",
  prompt: `
    You are the playwright-generator agent. Your job is to generate executable Playwright tests.

    **MANDATORY ACTIONS:**
    1. Read .opencode/skills/playwright-tests/SKILL.md for conventions, selector strategy, and API helpers.
    2. Read .opencode/skills/playwright-tests/_generator.md for your specific instructions.
    3. Read: .opencode/sessions/playwright-run/test-plan.json
    4. Read existing Page Object Models in playwright-tests/support/pages/ 
    5. Use browser tools to verify selectors from the test plan actually exist: (Refer for navigation NAVIGATION_REFERENCE.md)
       - browser_navigate to target page
       - browser_snapshot to verify selectors
    6. Generate test file: playwright-tests/ai-generated/{filename}.spec.ts
    7. Create new user with signup_with_merchantid API and login and skip 2FA (Use test+{randomstring}@example.com for email and "Password123!" for password)

    **File Naming:**
    - PR: PR-{number}-{slug}.spec.ts
    - Module: module-{name}.spec.ts
    - Scenario: scenario-{slug}.spec.ts

    **Prepare TODO list from _generator.md and follow it strictly**
    **Refer Test File Structure in _generator.md**

    Execute the generation workflow:
    1. Check existing relevant tests in playwright-tests/e2e/ and related Page Objects in playwright-tests/support/pages/
    2. Use browser tools to verify selectors
    3. Generate test files in playwright-tests/ai-generated/
    4. Reuse/update Page Objects as needed
    
    Output: playwright-tests/ai-generated/*.spec.ts
    Update session.json: { "phase": "generating-complete", "metrics": { "testsGenerated": N } }
    Report: "Generation complete. N tests written."
  `,
});
```

### Verify

- [ ] Agent reported success with file count
- [ ] At least one `.spec.ts` file in `playwright-tests/ai-generated/`
- [ ] Valid TypeScript/Playwright syntax (run `npx tsc --noEmit` on generated files)
- [ ] No TypeScript compilation errors
- [ ] Follows naming convention from SKILL.md
- [ ] `session.json` has `phase: "generating-complete"`

**TypeScript validation command:**

```bash
npx tsc --noEmit playwright-tests/ai-generated/*.spec.ts 2>&1
```

**If generation fails or TypeScript validation fails:**

1. Update `session.json`: `{ "status": "failed", "phase": "generating", "error": "Test generation failed" }`
2. STOP, report error

### Handover

→ Step 5 (when `phase="generating-complete"`)

---

## Step 5: Healing Phase (All Modes)

**CRITICAL:** Delegate to healer agent via task(). DO NOT fix tests yourself.

### Preconditions

- **Full mode:** `session.json` exists with `phase="generating-complete"`
- **Heal-only mode:** `session.json` exists with `phase="planning-complete"`
- Test files exist in `playwright-tests/ai-generated/`

### Execute

1. Delegate to playwright-healer:

```typescript
const healerResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "playwright-healer", // This loads _healer.md instructions
  mcp: ["playwright"],
  run_in_background: false,
  description: "Debug and fix failing tests via playwright-healer agent",
  prompt: `
    You are the playwright-healer agent. Your job is to diagnose and fix failing tests.

    **MANDATORY ACTIONS:**
    1. Read .opencode/skills/playwright-tests/SKILL.md for conventions, selector strategy, and API helpers.
    2. Read .opencode/skills/playwright-tests/_generator.md for your specific instructions.

    **Prepare TODO list from _planner.md and follow it strictly**

    Execute the healing workflow:
    1. Run: npx playwright test playwright-tests/ai-generated/*.spec.ts --reporter=json
    2. Read run-results.json
    3. Segregate bugs by type (selector, timing, data, network, feature flag)
    4. Use browser tools to diagnose and fix failing tests (Refer for navigation NAVIGATION_REFERENCE.md)
       - Use browser_navigate to go to the test page
       - Use browser_console_messages to check for JS errors
       - Use browser_snapshot to inspect the DOM at failure point
       - Reproduce the failure steps manually
       - Identify the root cause (selector, timing, data, etc.)
    5. Create new user with signup_with_merchantid API and login and skip 2FA (Use test+{randomstring}@example.com for email and "Password123!" for password)
    6. Repeat up to 3 times or until all tests pass
    7. Generate bug-report.md if failures remain

    **Common Fixes:**
    - Add waits: await page.locator("...").waitFor({ state: "visible" })
    - Fix selectors: Use data-testid or semantic selectors
    - Add timing: await page.waitForLoadState("networkidle")
    - Handle conditional elements: Check isVisible() before clicking

    Max attempts: 3
    Output: Fixed test files, run-results.json, bug-report.md
    Update session.json: { "phase": "healing-complete", "metrics": { "testsPassed": N, "testsFailed": N, "testsFixed": N, "healingAttempts": N } }
    Report: "Healing complete. N passed, M failed, F fixes applied."
  `,
});
```

### Verify

- [ ] Agent reported completion
- [ ] `run-results.json` exists
- [ ] `bug-report.md` exists (if failures)
- [ ] Test files modified (if fixes applied)
- [ ] `session.json` has `phase: "healing-complete"`

**If healing fails:**

1. Update `session.json`: `{ "status": "failed", "phase": "healing", "error": "Test healing failed" }`
2. STOP, report error

### Handover

→ Step 6 (when `phase="healing-complete"`)

---

## Step 6: Summary & Cleanup (Final Step)

### Preconditions

- `phase="healing-complete"` (all modes)
- Test execution completed

### Execute

#### Part A: Cleanup Resources

**1. Close Browser Sessions**

```typescript
// Close all Playwright browser contexts and pages
await skill_mcp({
  mcp_name: "playwright",
  tool_name: "browser_close",
});
```

**2. Stop Servers (if started)**

```bash
# Stop backend server
cd hyperswitch && docker rm -f hyperswitch-mailhog-1 2>/dev/null && docker compose down -v

# Stop frontend server
# First try the stored PID if available
if [ -n "$FRONTEND_PID" ]; then
  kill -TERM "$FRONTEND_PID" 2>/dev/null
  sleep 3
  # Force kill if still running
  if kill -0 "$FRONTEND_PID" 2>/dev/null; then
    kill -9 "$FRONTEND_PID" 2>/dev/null
  fi
fi

# Fallback: kill any process on port 9000
PID=$(lsof -ti:9000)
if [ -n "$PID" ]; then
  kill -TERM "$PID" 2>/dev/null
  sleep 3
  # Force kill if still running
  if kill -0 "$PID" 2>/dev/null; then
    kill -9 "$PID" 2>/dev/null
  fi
fi
```

#### Part B: Generate Summary

1. Read: `input-context.json`, `test-plan.json`, `run-results.json`, `session.json`
2. Calculate duration: `Date.now() - new Date(startedAt).getTime()`
3. Write `summary.json`:
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

#### Part C: Present Summary to User

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

[IF testsFailed > 0:]
🐛 BUG SUMMARY:
   Test: {test-name}
   Error: {error-message}
   Location: {file:line}

════════════════════════════════════════════════════════════════

🧹 CLEANUP OPTIONS:
   [1] commit       → Commit + push to current branch
   [2] new-branch   → Create pw/{target}-{timestamp}, commit + push
   [3] clean        → Delete all generated files

════════════════════════════════════════════════════════════════

Reply with your choice (1, 2, or 3) or type the action name.
```

**STOP HERE. WAIT FOR USER INPUT.**

### Execute Cleanup (After User Response)

#### Input Validation

Validate user input before processing:

```typescript
const validChoices = ["1", "2", "3", "commit", "new-branch", "clean"];
const normalizedInput = userInput.toLowerCase().trim();

if (!validChoices.includes(normalizedInput)) {
  // Re-prompt user with error message
  console.error(
    "Invalid choice. Please enter: 1/commit, 2/new-branch, or 3/clean",
  );
  return; // Wait for next input
}

const choice =
  normalizedInput === "1" || normalizedInput === "commit"
    ? "commit"
    : normalizedInput === "2" || normalizedInput === "new-branch"
      ? "new-branch"
      : "clean";
```

#### Cleanup Actions

| Choice           | Action                                                                                                                |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| `commit` (1)     | Commit changes, push (Applicable only if target is PR, if target is module/scenario/tag/default fallback to option 2) |
| `new-branch` (2) | Create branch `pw/{target}-{timestamp}`, commit, push (Refer `raise-pr` skill)                                        |
| `clean` (3)      | Delete `ai-generated/*.spec.ts`, clear session files                                                                  |

**Invalid Input Handling:**

- If user enters anything other than valid choices (1, 2, 3, commit, new-branch, clean), re-display the summary with an error message
- Continue prompting until valid input received or timeout (5 minutes)

### Session Update

After presenting options:

```json
{ "phase": "awaiting-user-choice", "message": "Waiting for user input" }
```

After cleanup complete:

```json
{
  "status": "complete",
  "phase": "cleanup",
  "userChoice": "commit|new-branch|clean",
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

## References

| File                                   | Purpose                                                     |
| -------------------------------------- | ----------------------------------------------------------- |
| `SKILL.md`                             | Conventions, selector strategy, API helpers, module mapping |
| `_planner.md`                          | Planning logic                                              |
| `_generator.md`                        | Generation logic                                            |
| `_healer.md`                           | Healing logic                                               |
| `playwright.config.ts`                 | Playwright configuration                                    |
| `playwright-tests/support/commands.ts` | API helpers                                                 |
