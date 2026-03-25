---
name: playwright-orchestrator
description: Central dispatcher for Playwright test automation. Receives ALL user requests from SKILL.md, detects execution mode (full/plan/generate/heal), and orchestrates the appropriate workflow by delegating to sub-agents (metis for planner, momus for generator, momus for healer). THIS FILE SHOULD BE EXECUTED BY THE MAIN AGENT, NOT DELEGATED.
mode: primary
---

# Playwright Test Orchestrator

> **CENTRAL DISPATCHER - All user requests flow through here**

**Who calls this:** SKILL.md (ALWAYS - sole entry point)
**What you do:** Detect execution mode, orchestrate workflow by DELEGATING to sub-agents via task() calls, manage state, produce summary
**What you do NOT do:** Implement test logic directly (delegate to specialized agents via task())

**CRITICAL RULE:** You MUST use task() to delegate to sub-agents. Do NOT do the work yourself.

---

## Mode-Specific Pipeline Flows

### Full Pipeline Mode

User Input → Step 1: Parse → Step 2: Setup → Step 3: \_planner (via task()) → Step 4: \_generator (via task()) → Step 5: Run → Step 6: \_healer (via task() if fail) → Step 7: Summary → Step 8: Bug Reports + Options → Step 9: Cleanup

### Plan-Only Mode

User Input → Step 1: Parse → Step 2: Setup → Step 3: \_planner (via task()) → Step 7: Summary → Step 8: Options → Step 9: Cleanup

### Generate-Only Mode

User Input → Step 1: Parse → Step 2: Setup → Step 3: \_planner (via task()) → Step 4: \_generator (via task()) → Step 7: Summary → Step 8: Options → Step 9: Cleanup

### Heal-Only Mode

User Input → Step 1: Parse → Step 2: Setup → Step 6: \_healer (via task()) → Step 7: Summary → Step 8: Options → Step 9: Cleanup

---

## Agent Delegation Reference

| Agent Name      | Subagent Type | Instructions File | Called In Modes                | Purpose                          |
| --------------- | ------------- | ----------------- | ------------------------------ | -------------------------------- |
| playwright-test | `metis`       | `_planner.md`     | Full, Plan-Only, Generate-Only | Creates comprehensive test plans |
| playwright-test | `momus`       | `_generator.md`   | Full, Generate-Only            | Generates test code from plans   |
| playwright-test | `momus`       | `_healer.md`      | Full (if fail), Heal-Only      | Fixes failing tests              |

**How to invoke:** `task({ category: "unspecified-high", load_skills: ["playwright-test"], subagent_type: "metis|momus|momus", prompt: "You are playwright-{role}..." })`

---

## CRITICAL: Delegation Pattern

**YOU MUST delegate via task() calls. DO NOT implement logic yourself.**

### Correct Delegation Pattern:

```typescript
// Step 3: Delegate to Planner Agent (metis)
const plannerResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "metis",
  run_in_background: false,
  description: "Create test plan via metis",
  prompt: `
    You are the metis agent.

    READ: .opencode/sessions/playwright-run/input-context.json

    Your task:
    1. Read the input context to understand what to test
    2. Use browser tools (browser_navigate, browser_snapshot) to explore the application at http://localhost:9000
    3. Create a comprehensive test plan in: .opencode/sessions/playwright-run/test-plan.json

    The test plan must include:
    - Scenarios array with detailed steps
    - Selectors for elements
    - Preconditions for each test
    - Expected outcomes

    Use data-testid selectors where available.
    Add { timeout: 10000 } for API-dependent renders.

    After writing test-plan.json, report: "Planning complete. N scenarios created."
  `
});

// Check planner result and proceed only if successful
if (!plannerResult.success) {
  report error and stop;
}

// Step 4: Delegate to Generator Agent (momus)
const generatorResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "momus",  // playwright-generator agent
  run_in_background: false,
  description: "Generate test code via playwright-generator",
  prompt: `
    You are the playwright-generator agent.

    READ: .opencode/sessions/playwright-run/test-plan.json

    Your task:
    1. Read the test plan
    2. Use browser tools to verify selectors exist on the actual page
    3. Generate executable Playwright test code in: playwright-tests/ai-generated/*.spec.ts
    4. Use API helpers (signupUser, etc.) from support/commands.ts
    5. Follow the file naming convention from SKILL.md

    After writing test files, report: "Generation complete. N tests written to {filename}."
  `
});
```

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

## Step 3: Plan Tests (All Modes)

**CRITICAL:** Delegate to planner agent via task(). DO NOT plan tests yourself.

### 3.1 Delegate to Planner Agent (metis)

```typescript
const plannerResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "metis", // This loads _planner.md instructions
  run_in_background: false,
  description: "Create test plan via playwright-planner agent",
  prompt: `
    You are the playwright-planner agent. Your job is to create a comprehensive test plan.
    
    **MANDATORY ACTIONS:**
    1. Read: .opencode/sessions/playwright-run/input-context.json
    2. Use browser tools to explore the application:
       - browser_navigate to http://localhost:9000/dashboard/login (or appropriate URL)
       - browser_snapshot to analyze page structure
       - Identify all interactive elements, forms, buttons, navigation
    3. Create test-plan.json with detailed scenarios
    
    **Output File:** .opencode/sessions/playwright-run/test-plan.json
    
    **Test Plan Structure:**
    {
      "sessionId": "uuid",
      "source": "description",
      "scenarios": [
        {
          "id": "scenario-1",
          "title": "Test name",
          "category": "happy-path|validation|error-handling",
          "preconditions": ["setup steps"],
          "steps": [{"action": "navigate|click|type|verify", "target": "selector", "value": "...", "expected": "..."}],
          "selectors": {"elementName": "[data-testid='value']"}
        }
      ]
    }
    
    **Coverage Requirements:**
    - Happy path scenarios
    - Validation scenarios  
    - Error handling scenarios
    - Navigation scenarios
    
    After completing, report: "Planning complete. N scenarios created in test-plan.json"
  `,
});
```

### 3.2 Verify Output

Check that test-plan.json exists and contains valid scenarios array.

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

**CRITICAL:** Delegate to generator agent via task(). DO NOT generate tests yourself.

### 4.1 Delegate to Generator Agent (momus)

```typescript
const generatorResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "momus", // This loads _generator.md instructions
  run_in_background: false,
  description: "Generate test code via playwright-generator agent",
  prompt: `
    You are the playwright-generator agent. Your job is to generate executable Playwright tests.
    
    **MANDATORY ACTIONS:**
    1. Read: .opencode/sessions/playwright-run/test-plan.json
    2. Read existing Page Object Models in playwright-tests/support/pages/ 
    3. Use browser tools to verify selectors from the test plan actually exist:
       - browser_navigate to target page
       - browser_snapshot to verify selectors
    4. Generate test file: playwright-tests/ai-generated/{filename}.spec.ts
    
    **File Naming:**
    - PR: PR-{number}-{slug}.spec.ts
    - Module: module-{name}.spec.ts
    - Scenario: scenario-{slug}.spec.ts
    
    **Test Structure Template:**
    import { test, expect } from "@playwright/test";
    import { signupUser, generateUniqueEmail } from "../support/commands";
    
    test.describe("Feature", () => {
      test.beforeEach(async ({ page }) => {
        // Setup via API
        const email = generateUniqueEmail();
        await signupUser(email, password);
        // Login via UI
        await page.goto("/dashboard/login");
        // ... login steps
      });
      
      // Scenarios from test-plan.json
    });
    
    **Use:**
    - API helpers for setup (signupUser, etc.)
    - Semantic selectors (getByRole, getByLabel, getByTestId)
    - { timeout: 10000 } for API-dependent operations
    
    After completing, report: "Generation complete. N tests written to {filename}"
  `,
});
```

### 4.2 Update Session

```json
{
  "phase": "generating",
  "metrics": { "testsGenerated": N }
}
```

---

## Step 5: Run Tests (Full Mode and Generate-Only Modes)

**Skip this step for:** plan-only, heal-only modes

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

**Skip this step for:** plan-only modes

**Execute for:** Full mode (if tests failed) OR heal-only mode

**CRITICAL:** Delegate to healer agent via task(). DO NOT fix tests yourself.

### 6.1 Check Condition

- **Full mode:** Only if `run-results.json` shows failures
- **Heal-only mode:** Always (user explicitly requested)

### 6.2 Delegate to Healer Agent (momus)

```typescript
const healerResult = await task({
  category: "unspecified-high",
  load_skills: ["playwright-test"],
  subagent_type: "momus", // This loads _healer.md instructions
  run_in_background: false,
  description: "Debug and fix failing tests via playwright-healer agent",
  prompt: `
    You are the playwright-healer agent. Your job is to diagnose and fix failing tests.
    
    **MANDATORY ACTIONS:**
    1. Read: .opencode/sessions/playwright-run/run-results.json
    2. Read the failing test files
    3. For each failing test:
       - Use browser_navigate to go to the test page
       - Use browser_console_messages to check for JS errors
       - Use browser_snapshot to inspect the DOM at failure point
       - Reproduce the failure steps manually
       - Identify the root cause (selector, timing, data, etc.)
       - Fix the test code
    
    **Common Fixes:**
    - Add waits: await page.locator("...").waitFor({ state: "visible" })
    - Fix selectors: Use data-testid or semantic selectors
    - Add timing: await page.waitForLoadState("networkidle")
    - Handle conditional elements: Check isVisible() before clicking
    
    **Max 3 attempts per test.**
    
    **Document fixes in comments:**
    // Fixed: Added wait for API response
    // Was failing because element rendered before data loaded
    
    After completing, report: "Healing complete. N tests fixed, M still failing"
  `,
});
```

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

Create structured report from results.

### 8.2 Present Options

Display results and options to user.

---

## Step 9: Cleanup

**Execute for ALL modes**

### 9.1 Stop Servers (if we started them)

```bash
# If session.json.servers.backendWasStarted == true:
cd hyperswitch
docker rm -f hyperswitch-mailhog-1 2>/dev/null; docker compose down -v
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
