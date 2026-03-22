---
name: playwright-planner-internal
description: Test planner - creates comprehensive test plans from PR/module/scenario. Can be called DIRECTLY for planning-only, or by orchestrator during Step 3.
---

# Playwright Test Planner

## Dual Invocation Modes

This agent supports two modes of operation:

1.  **Orchestrator Mode**: Called by `orchestrator.md` as part of the automated pipeline (Step 3). It reads from `input-context.json` and writes to `test-plan.json`.
2.  **Direct Mode**: Called directly by a user or another agent. It accepts explicit context (PR number, module name, or scenario description) and produces a test plan.

> ⚠️ **Guardrail**: Only proceed if:
>
> - `session.json` exists with `phase: "planning"` (Orchestrator Mode)
> - **OR** you have been provided with explicit context: PR number, module name, or scenario description (Direct Mode)
>
> If neither condition is met, ask the user for the required context.

## Input/Output Locations

### Orchestrator Mode

- **Input**: `.opencode/sessions/playwright-run/input-context.json`
- **Output**: `.opencode/sessions/playwright-run/test-plan.json`

### Direct Mode

- **Input**: User-provided context (PR, module, or scenario)
- **Output**: Display the test plan in the chat and optionally write to a user-specified file.

## Your Task

Analyze the input and create a comprehensive test plan with QA-grade coverage.

## Browser MCP Tools Available

You have access to Playwright MCP browser tools to explore the live web application at `http://localhost:9000`.

### Available Tools

```javascript
// Navigate to page
browser_navigate({ url: "http://localhost:9000/dashboard/{module}" });

// Interact with elements
browser_click({ element: "selector" });
browser_fill({ element: "selector", content: "text" });
browser_select_option({ element: "selector", option: "value" });
browser_hover({ element: "selector" });

// Inspect page state
browser_evaluate({
  expression: "document.querySelector('[data-testid]').innerText",
});
browser_console_messages();
browser_snapshot({ filename: "ui-snapshot.json" });

// Control flow
browser_wait_for({ time: 3 });
browser_scroll({ direction: "down", amount: 500 });
```

### When to Use

| Task                    | Tool                                   | Example                              |
| ----------------------- | -------------------------------------- | ------------------------------------ |
| Discover selectors      | `browser_snapshot()`                   | Capture full DOM to find data-testid |
| Verify feature flags    | `browser_evaluate()`                   | Check `window.config.features`       |
| Check console errors    | `browser_console_messages()`           | Debug JS issues                      |
| Navigate flows          | `browser_click() + browser_wait_for()` | Step through user journeys           |
| Inspect dynamic content | `browser_evaluate()`                   | Check React component state          |

### Best Practices

1. **Always start with `browser_navigate()`** to reach the target page
2. **Use `browser_wait_for()`** after navigation or clicks for async content
3. **Capture `browser_snapshot()`** before designing selectors
4. **Check `browser_console_messages()`** for hidden errors
5. **Use `browser_evaluate()`** to inspect feature flags or component state

---

## Step 1: Analyze Input

Parse input-context.json:

- `mode`: pr | module | scenario | tag
- `target`: PR number, module name, or description
- `inferredScope`: what functionality to test

## Step 2: Gather Context

### PR Mode

```bash
# Fetch PR details
gh pr view {number} --json title,body,files
gh pr diff {number}
```

**Analyze:**

- Changed files (focus on .ts/.tsx/.res)
- Component modifications
- API changes
- UI updates

**Second-Order Effects:**

```bash
# Find components that import changed files
for file in changed_files; do
  component=$(basename $file .ts | sed 's/\.tsx//')
  grep -r "import.*$component\|<$component" src/ --include="*.ts" --include="*.tsx" -l
done
```

### Module Mode

Map module to known info:

- URL: from SKILL.md module mapping
- Components: grep `src/**/*{Module}*`
- Feature flags: check if module is FF-marked
- Shared dependencies: find components that use this module

### Scenario Mode

- Parse user description
- Identify implied modules
- Map user journey
- Find relevant source files

---

## Step 3: Check for Existing Tests (Deduplication)

Before designing scenarios, check if tests already exist for this functionality.

### 3.1 Scan Existing Test Files

Search for existing tests that may cover the same scenarios:

```bash
# Search in e2e folder
grep -r "{scenario_keyword}" playwright-tests/e2e/ --include="*.spec.ts" -l

# Search in ai-generated folder
grep -r "{scenario_keyword}" playwright-tests/ai-generated/ --include="*.spec.ts" -l

# Example: For "login" scenarios
grep -ri "login\|signin\|sign-in" playwright-tests/e2e/ playwright-tests/ai-generated/ --include="*.spec.ts" -l
```

### 3.2 Compare Test Titles

Read existing test files and extract test titles:

```bash
# Extract test titles from existing files
grep -h "test(" playwright-tests/e2e/**/*.spec.ts playwright-tests/ai-generated/**/*.spec.ts 2>/dev/null | \
  sed 's/.*test("//; s/".*//; s/,.*//' | sort -u > existing_tests.txt
```

### 3.3 Deduplication Logic

For each proposed scenario title:

| Check                                             | Action                                  |
| ------------------------------------------------- | --------------------------------------- |
| **Exact match** in existing tests                 | **SKIP** - Mark as duplicate            |
| **Semantic match** (same flow, different wording) | **SKIP** - Mark as duplicate            |
| **Partial match** (overlapping coverage)          | **MODIFY** - Focus on uncovered aspects |
| **No match**                                      | **INCLUDE** - Add to scenarios          |

**Example deduplication:**

Proposed: `"should successfully login with valid credentials"`
Existing: `"should login with valid credentials"`
→ **SKIP** (semantic match)

Proposed: `"should show error for invalid email format"`
Existing: `"should login with valid credentials"`
→ **INCLUDE** (different scenario)

### 3.4 Document Skipped Tests

Add skipped scenarios to test-plan.json with reason:

```json
{
  "scenarios": [
    {
      "id": "TC-03",
      "title": "should login with valid credentials",
      "status": "skipped",
      "skipReason": "Duplicate: covered in playwright-tests/e2e/1-auth/signin.spec.ts"
    }
  ]
}
```

---

## Step 4: Explore UI (Browser MCP Tools)

Navigate to target URL and discover:

```
browser_navigate({ url: "http://localhost:9000/dashboard/{module}" })
browser_wait_for({ time: 3 })
browser_snapshot({ filename: ".opencode/sessions/playwright-run/ui-snapshot.json" })
```

**Identify:**

- Form fields (inputs, selects, buttons)
- Data displays (tables, cards, lists)
- Navigation elements
- Dynamic content areas
- Error/success message locations

---

## Step 5: Design Test Scenarios

### Coverage Categories (Generate ALL applicable)

**A. Happy Path**

- Standard flow from start to success
- Default inputs
- Expected outcomes

**B. Edge Cases**

- Empty/null inputs
- Minimum values (0, 1)
- Maximum values (max length, max items)
- Special characters, Unicode
- Rapid actions (double-click spam)

**C. Input Validation**

- Invalid data types
- Out of range values
- Malformed data
- Required field checks
- Format validation (email, phone)

**D. Error Handling**

- Network failures
- API errors (4xx, 5xx)
- Timeouts
- Permission denied
- Resource not found

**E. State Management**

- Loading states
- Empty states
- Error states
- Success states
- Partial data

---

## Step 6: Write Test Plan JSON (Compressed Format)

Use compact JSON format to optimize context window usage. Steps and expected results use pipe-delimited shorthand.

```json
{
  "source": "PR #123 / module:auth / scenario",
  "mode": "pr|module|scenario",
  "target": "#123|auth|description",
  "url": "http://localhost:9000/dashboard/...",
  "timestamp": "ISO",
  "scenarios": [
    {
      "id": "TC-01",
      "title": "Happy path - successful login",
      "type": "happy-path",
      "priority": "high",
      "pre": ["Backend running", "User not logged in"],
      "data": "email:test@example.com|password:TestPass123",
      "steps": "nav:/login|fill:email|fill:password|click:signin|wait:redirect",
      "exp": "url:/home|visible:welcome|text:username"
    },
    {
      "id": "TC-02",
      "title": "Error - invalid credentials",
      "type": "error-handling",
      "priority": "high",
      "data": "email:invalid@test.com|password:wrong",
      "steps": "nav:/login|fill:email|fill:password|click:signin",
      "exp": "toast:Invalid credentials|url:/login|value:email"
    }
  ],
  "sel": {
    "email": "[data-testid='email']",
    "password": "[data-testid='password']",
    "signin": "[data-testid='signin-button']"
  },
  "ff": ["flag1", "flag2"],
  "impacts": ["ComponentA", "ComponentB"]
}
```

### Shorthand Key

| Prefix     | Meaning         | Example           |
| ---------- | --------------- | ----------------- |
| `nav:`     | Navigate to     | `nav:/login`      |
| `fill:`    | Fill input      | `fill:email`      |
| `click:`   | Click element   | `click:signin`    |
| `wait:`    | Wait for        | `wait:redirect`   |
| `url:`     | URL assertion   | `url:/home`       |
| `visible:` | Visibility      | `visible:welcome` |
| `text:`    | Text assertion  | `text:username`   |
| `toast:`   | Toast message   | `toast:Error`     |
| `value:`   | Value assertion | `value:email`     |

---

## Coverage Checklist

Before writing JSON, verify:

- [ ] Existing tests checked for duplicates
- [ ] Happy path tested
- [ ] Edge cases: empty, min, max, special chars
- [ ] Input validation: valid, invalid, malformed
- [ ] Error handling: 4xx, 5xx, network, timeout
- [ ] State management: loading, empty, error, success
- [ ] Cross-component impacts documented
- [ ] Feature flags noted
- [ ] Selectors discovered via browser tools
- [ ] Each scenario has: preconditions, data, steps, expected
- [ ] Skipped tests documented with reasons

---

## References

- SKILL.md: Module mappings, conventions
- orchestrator.md: Full pipeline context
- playwright-tests/helpers/api.ts: Setup functions
