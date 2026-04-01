---
name: playwright-orchestrator
description: Central dispatcher for Playwright test automation. Receives ALL user requests from SKILL.md, detects execution mode (full and heal), and orchestrates the workflow by DELEGATING to sub-agents (playwright-planner, playwright-generator, playwright-healer). THIS FILE IS EXECUTED BY THE MAIN AGENT (YOU), NOT DELEGATED.
mode: primary
---

# Playwright Test Orchestrator

**YOU are the orchestrator. DELEGATE all work to sub-agents via task(). DO NOT implement pipeline logic yourself.**

## Pipeline Flows

| Mode          | Steps                                            |
| ------------- | ------------------------------------------------ |
| **Full**      | Parse → Setup → Plan → Generate → Heal → Summary |
| **Heal-Only** | Parse → Setup → Plan → Heal → Summary            |

## Sub-Agent Delegation

| Agent     | Type                   | Instructions    | Called In          |
| --------- | ---------------------- | --------------- | ------------------ |
| planner   | `playwright-planner`   | `_planner.md`   | Step 3 (all modes) |
| generator | `playwright-generator` | `_generator.md` | Step 4 (Full only) |
| healer    | `playwright-healer`    | `_healer.md`    | Step 5 (all modes) |

**Standard task() call:**

```typescript
await task({
  subagent_type: "playwright-{role}",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "Brief description",
  prompt:
    "Read SKILL.md for conventions. Read _{role}.md for your instructions. Execute.",
});
```

### Follow File Editing Guidelines from playwright-test skill (CRITICAL)

When editing any files in this workflow, you **MUST** use surgical edits (`edit`) instead of full file writes (`write`). This preserves existing content and reduces error risk.

---

## Step 1: Parse Input & Detect Mode

### Preconditions

- User input from SKILL.md via conversation context

### Execute

1. Extract raw user message, PR numbers, module names, or scenario descriptions
2. Detect mode by keywords:
   - `full`: "generate tests", "create test", "test PR #N", "run playwright tests"
   - `heal-only`: "fix failing tests", "fix tests", "heal tests", "repair tests"
3. Parse target: PR number, module name, or scenario description
4. Generate `sessionId = crypto.randomUUID()`
5. Write `.opencode/sessions/playwright-run/input-context.json`:
   ```json
   {
     "rawInput": "user message",
     "mode": "full|heal-only",
     "target": "#123|auth|description",
     "targetType": "pr|module|scenario",
     "timestamp": "ISO",
     "sessionId": "uuid"
   }
   ```
6. Initialize `.opencode/sessions/playwright-run/session.json`:
   ```json
   {
     "sessionId": "uuid",
     "mode": "detected-mode",
     "status": "in_progress",
     "phase": "parse",
     "startedAt": "ISO",
     "servers": { "backendWasStarted": false, "frontendWasStarted": false },
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
     - Set `backendWasStarted = true`
     - If still DOWN: ask user to continue or abort
2. Check frontend: `curl -s http://localhost:9000 > /dev/null && echo "UP" || echo "DOWN"`
   - **If DOWN:**
     - Run: `npm run build:test && npm run test:start`
     - Poll every 5s, max 120s
     - Set `frontendWasStarted = true`
     - If still DOWN: ask user to continue or abort

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

1. Delegate to playwright-planner:

```typescript
await task({
  subagent_type: "playwright-planner",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "Create test plan",
  prompt: `
    Read SKILL.md for conventions and API helpers.
    Read _planner.md for your specific instructions.
    Read input-context.json for the target.
    
    Execute the planning workflow:
    1. Read existing tests in playwright-tests/e2e/ for patterns
    2. Use browser tools to explore the application
    3. Determine preconditions using module mapping from SKILL.md
    4. Create test-plan.json with scenarios
    
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

### Preconditions

- `session.json` exists with `phase="planning-complete"`
- `mode === "full"`
- `test-plan.json` exists with valid scenarios
- **SKIP for heal-only mode**

### Execute

1. Delegate to playwright-generator:

```typescript
await task({
  subagent_type: "playwright-generator",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "Generate test code",
  prompt: `
    Read SKILL.md for conventions, selector strategy, and API helpers.
    Read _generator.md for your specific instructions.
    Read test-plan.json for scenarios.
    
    Execute the generation workflow:
    1. Check existing Page Objects in playwright-tests/support/pages/
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

### Preconditions

- **Full mode:** `session.json` exists with `phase="generating-complete"`
- **Heal-only mode:** `session.json` exists with `phase="planning-complete"`
- Test files exist in `playwright-tests/ai-generated/`

### Execute

1. Delegate to playwright-healer:

```typescript
await task({
  subagent_type: "playwright-healer",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "Run tests and fix failures",
  prompt: `
    Read SKILL.md for conventions and common fixes.
    Read _healer.md for your specific instructions.
    
    Execute the healing workflow:
    1. Run: npx playwright test playwright-tests/ai-generated/*.spec.ts --reporter=json
    2. Read run-results.json
    3. Segregate bugs by type (selector, timing, data, network, feature flag)
    4. Use browser tools to diagnose and fix
    5. Repeat up to 3 times or until all tests pass
    6. Generate bug-report.md if failures remain
    
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
# If session.json.servers.backendWasStarted == true:
cd hyperswitch && docker rm -f hyperswitch-mailhog-1 2>/dev/null && docker compose down -v

# If session.json.servers.frontendWasStarted == true:
# Try graceful shutdown first, then force kill if needed
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

| Choice           | Action                                                                         |
| ---------------- | ------------------------------------------------------------------------------ |
| `commit` (1)     | Commit changes, push, create PR                                                |
| `new-branch` (2) | Create branch `pw/{target}-{timestamp}`, commit, push (Refer `raise-pr` skill) |
| `clean` (3)      | Delete `ai-generated/*.spec.ts`, clear session files                           |

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
