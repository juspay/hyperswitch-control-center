---
name: playwright-orchestrator
description: Central dispatcher for Playwright test automation. Detects mode (full/plan/heal), orchestrates sub-agents, manages state, produces final report. Executed directly by the main agent — NOT delegated.
mode: primary
---

# Playwright Orchestrator

**You ARE the orchestrator.** Detect mode, delegate to sub-agents, manage state, report results.
**NEVER do planner/generator/healer work yourself.** Always delegate via task().
**NEVER skip a step.** Every step has a pre-condition gate and a post-condition gate.

## Pipeline

| Mode      | Steps                          |
| --------- | ------------------------------ |
| full      | 1 → 2 → 3 → 4 → 5 → 6(if fail) → 7 |
| plan-only | 1 → 2 → 3 → 7                 |
| heal-only | 1 → 2 → 5 → 6 → 7            |

---

## Step 1: Parse Input

**Gate-in:** User input received.
**Gate-out:** Both `input-context.json` and `session.json` exist and are valid.

1. Detect mode from keywords (see SKILL.md triggers). Default: `full`.
2. Parse target: PR number, module name, scenario description, or tag.
3. Create `.opencode/sessions/playwright-run/` directory.
4. Write `input-context.json`:
   ```json
   { "rawInput": "...", "mode": "full|plan-only|heal-only", "target": "...", "targetType": "pr|module|scenario|tag", "timestamp": "ISO", "sessionId": "uuid" }
   ```
5. Write `session.json`:
   ```json
   { "sessionId": "uuid", "mode": "...", "status": "initialized", "startedAt": "ISO", "servers": { "backendWasStarted": false, "frontendWasStarted": false }, "metrics": { "testsPlanned": 0, "testsGenerated": 0, "testsPassed": 0, "testsFailed": 0, "fixesApplied": 0, "testsFixme": 0 } }
   ```

**Validation:** Verify both files written, mode valid, target non-empty. Retry once on failure, then STOP.

---

## Step 2: Environment Setup

**Gate-in:** `session.json` status is `initialized`.
**Gate-out:** Status → `server-ready`. Both services respond.

1. `curl -sf http://localhost:8080/health` — if fail: `sh cypress/start_hyperswitch.sh`, poll 5s intervals max 120s, set `backendWasStarted=true`.
2. `curl -sf http://localhost:9000 > /dev/null` — if fail: `npm run build:test && npm run test:start &`, poll 5s intervals max 120s, set `frontendWasStarted=true`.

**Validation:** Both HTTP 200. If either fails after 120s → ask user to continue or abort. Update status to `server-ready`.

**Next:** full/plan-only → Step 3. heal-only → Step 5.

---

## Step 3: Plan Tests

**Gate-in:** Status is `server-ready`. Mode is `full` or `plan-only`.
**Gate-out:** `test-plan.json` exists with ≥1 scenario. Status → `planning-complete`.

Update status to `planning`. Delegate:

```
task({
  subagent_type: "playwright-planner",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "Create test plan for " + target,
  prompt: `You are the playwright-planner. Read and follow .opencode/skills/playwright-test/_planner.md EXACTLY.
Input: .opencode/sessions/playwright-run/input-context.json
Output: .opencode/sessions/playwright-run/test-plan.json
MANDATORY SEQUENCE:
1. Read existing tests in playwright-tests/e2e/ for this module — copy their beforeEach pattern exactly
2. Read playwright-tests/support/commands.ts for available API helpers
3. Read relevant Page Objects in playwright-tests/support/pages/
4. Authenticate via SKILL.md browser auth flow (skip 2FA)
5. Explore target page with browser tools
6. Write test-plan.json with deterministic prerequisites
7. browser_close before returning`
})
```

**Validation:** `test-plan.json` is valid JSON, has `scenarios[]` with length ≥ 1, each has `id`, `title`, `steps`, `selectors`. If fail → retry ONCE → set `planning-failed`, STOP.

Update metrics: `testsPlanned = scenarios.length`. Status → `planning-complete`.

**Next:** full → Step 4. plan-only → Step 7.

---

## Step 4: Generate Tests

**Gate-in:** Status is `planning-complete`. Mode is `full`.
**Gate-out:** ≥1 `.spec.ts` file in `playwright-tests/ai-generated/`. Status → `generating-complete`.

Update status to `generating`. Delegate:

```
task({
  subagent_type: "playwright-generator",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "Generate test code for " + target,
  prompt: `You are the playwright-generator. Read and follow .opencode/skills/playwright-test/_generator.md EXACTLY.
Input: .opencode/sessions/playwright-run/test-plan.json
Output: playwright-tests/ai-generated/{filename}.spec.ts
MANDATORY SEQUENCE:
1. Read test-plan.json — use EXACT prerequisites from prerequisites field
2. Read existing tests in playwright-tests/e2e/ for the module — match their patterns
3. Read Page Objects listed in test-plan.json existingPageObjects field
4. Check if needed locators already exist in playwright-tests/support/pages/
5. Authenticate via SKILL.md browser auth flow (skip 2FA)
6. Verify every selector via browser_snapshot before using it
7. Add new reusable locators to support/pages/{module}/ if applicable
8. Write .spec.ts file(s) to playwright-tests/ai-generated/
9. browser_close before returning`
})
```

**Validation:** ≥1 `.spec.ts` exists in `playwright-tests/ai-generated/`. If fail → retry ONCE → set `generating-failed`, STOP.

Update metrics: `testsGenerated = count`. Status → `generating-complete`.

---

## Step 5: Run Tests

**Gate-in:** Status is `generating-complete` (full) or `server-ready` (heal-only).
**Gate-out:** `run-results.json` written. Status → `all-pass`, `some-pass`, or `none-pass`.

Update status to `running`. Execute:

```bash
npx playwright test playwright-tests/ai-generated/*.spec.ts --reporter=json 2>&1
```

Parse JSON output. Write `.opencode/sessions/playwright-run/run-results.json`:
```json
{ "status": "passed|failed|partial", "testFile": "path", "timestamp": "ISO", "summary": { "total": 0, "passed": 0, "failed": 0, "skipped": 0, "fixme": 0 }, "failures": [{ "test": "name", "error": "msg", "location": "file:line" }] }
```

**Validation:** `run-results.json` exists with valid `summary`. If command crashes → set `run-failed`, skip to Step 7.

Update metrics. Status → `all-pass` (0 failures) | `some-pass` (mixed) | `none-pass` (all fail).

**Next:** `testsFailed > 0` → Step 6. `testsFailed == 0` → Step 7.

---

## Step 6: Heal Failures

**Gate-in:** Status is `some-pass` or `none-pass`. `run-results.json` has failures.
**Gate-out:** `bug-report.md` written. `run-results.json` updated. Status → `complete`.

Update status to `healing`. Delegate:

```
task({
  subagent_type: "playwright-healer",
  load_skills: ["playwright-test"],
  mcp: ["playwright"],
  description: "Fix failing tests for " + target,
  prompt: `You are the playwright-healer. Read and follow .opencode/skills/playwright-test/_healer.md EXACTLY.
Input: .opencode/sessions/playwright-run/run-results.json
Output: Fixed test files + bug-report.md + updated run-results.json
MANDATORY SEQUENCE:
1. Read run-results.json — parse all failures
2. Segregate failures by root cause category
3. Authenticate via SKILL.md browser auth flow (skip 2FA)
4. LOOP 3 times: debug with browser tools → apply fixes → re-run tests → read new results
5. Mark unresolvable tests as test.fixme() after iteration 3
6. Write .opencode/sessions/playwright-run/bug-report.md
7. Update .opencode/sessions/playwright-run/run-results.json with final state
8. browser_close before returning`
})
```

**Validation:** `bug-report.md` exists. `run-results.json` updated (check timestamp). Update metrics from final results.

---

## Step 7: Final Report

**Gate-in:** All prior pipeline steps complete (or failed with status recorded).
**Gate-out:** `summary.json` written. Report displayed. **PIPELINE STOPS.**

1. Read all session files: `input-context.json`, `session.json`, `test-plan.json` (if exists), `run-results.json` (if exists), `bug-report.md` (if exists).
2. Write `.opencode/sessions/playwright-run/summary.json`.
3. Display:

### Test Summary

```
═══ Test Run Summary ═══
Session: {sessionId}   Mode: {mode}   Status: {complete|partial|failed}

  Planned: {N}   Generated: {N}   Passed: {N}   Failed: {N}   Fixme: {N}   Fixes: {N}

Files:
  Plan:    .opencode/sessions/playwright-run/test-plan.json
  Tests:   playwright-tests/ai-generated/*.spec.ts
  Results: .opencode/sessions/playwright-run/run-results.json
```

### Bugs (if any)

If `bug-report.md` exists → display its content.
If no report but failures → list: `[FAIL] {test} — {error} — Root Cause: {category}`.
If no failures → `═══ All tests passed. ═══`

### Cleanup

```
═══ Cleanup ═══
Stop FE server (port 9000):
  lsof -ti:9000 | xargs -r kill -TERM; sleep 5; lsof -ti:9000 | xargs -r kill -9

Generated: playwright-tests/ai-generated/*.spec.ts
Session:   .opencode/sessions/playwright-run/

Next actions (your choice):
  "commit and create PR" | "commit passing only" | "clean up" | "re-run tests" | "stop servers"
```

4. **Execute graceful FE server shutdown:** Run `lsof -ti:9000 | xargs -r kill -TERM 2>/dev/null; sleep 5; lsof -ti:9000 | xargs -r kill -9 2>/dev/null` to stop the frontend server started in Step 2.
5. Update `session.json`: `{ "status": "complete", "completedAt": "ISO" }`.

**STOP. Pipeline ends. Further actions are user-driven only.**

---

## Error Handling

| Error              | Action                                                    |
| ------------------ | --------------------------------------------------------- |
| Sub-agent fails    | Retry ONCE. If retry fails → set failed status, skip to Step 7. |
| Backend timeout    | Ask user: continue without backend or abort?              |
| Test command crash  | Set `run-failed`, skip to Step 7.                        |
| Invalid transition | Log the invalid transition. STOP immediately.             |
| Missing file       | Log which file. Retry step once or skip to Step 7.        |
