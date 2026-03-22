---
name: playwright-planner
description: Test planner agent for Playwright. Called by orchestrator.md during Step 3 to create comprehensive test plans from PR/module/scenario analysis. Writes test-plan.json for use by generator agent.
---

# Playwright Test Planner

> 🎯 **Called by orchestrator.md during Step 3 (Plan Tests)**

**Who calls this:** orchestrator.md ONLY  
**When called:** During planning phase of any mode that includes planning (full or plan-only)  
**Input:** input-context.json (written by orchestrator Step 1)  
**Output:** test-plan.json

## Guardrail

> ⚠️ **Only proceed if:**
>
> - `session.json` exists with `phase: "planning"`
> - `input-context.json` exists with parsed user request
>
> If conditions not met, inform orchestrator of missing context.

## Input/Output

- **Input:** `.opencode/sessions/playwright-run/input-context.json`
- **Output:** `.opencode/sessions/playwright-run/test-plan.json`

## Your Task

Analyze the input and create a comprehensive test plan with QA-grade coverage.

## Browser MCP Tools Available

You have access to Playwright MCP browser tools to explore the live web application at `http://localhost:9000` for accurate test scenario identification.

### Available Tools

```javascript
browser_navigate({ url: "http://localhost:9000/dashboard/{module}" });
browser_click({ element: "selector" });
browser_fill({ element: "selector", content: "text" });
browser_wait_for({ time: 3 });
browser_evaluate({
  expression: "document.querySelector('[data-testid]').innerText",
});
browser_console_messages();
browser_snapshot({ filename: "ui-snapshot.json" });
browser_scroll({ direction: "down", amount: 500 });
```

### When to Use

| Task                  | Tool                                      | Purpose                        |
| --------------------- | ----------------------------------------- | ------------------------------ |
| Verify selectors      | `browser_navigate() + browser_snapshot()` | Confirm selectors exist        |
| Discover selectors    | `browser_click() + browser_evaluate()`    | Find dynamic elements          |
| Check console errors  | `browser_console_messages()`              | Avoid broken tests             |
| Verify feature flags  | `browser_evaluate()`                      | Check `window.config.features` |
| Test interaction flow | `browser_click() + browser_wait_for()`    | Validate step sequences        |

## Step 1: Read Input Context

Read `input-context.json`:

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

## Step 2: Gather Context Based on Mode

### PR Mode

Fetch PR metadata and diff:

```bash
gh pr view {NUMBER} --json number,title,body,files
gh pr diff {NUMBER}
```

Read FULL source files touched by PR to find:

- `data-*` attributes
- Navigation flows
- Form fields
- API calls

### Module Mode

Map module name to source paths:

- **auth** → `src/**/Auth*`, `src/**/Login*`, `src/**/SignIn*`, `src/**/SignUp*`
- **payments** → `src/**/Payment*`, `src/**/Orders*`
- **refunds** → `src/**/Refund*`
- **disputes** → `src/**/Dispute*`
- **connectors** → `src/**/Connector*`, `src/**/PaymentProcessor*`
- **routing** → `src/**/Routing*`
- **analytics** → `src/**/Analytics*`
- **users** → `src/**/Users*`
- **api-keys** → `src/**/APIKeys*`
- **settings** → `src/**/Settings*`, `src/**/ConfigurePMTs*`

### Scenario Mode

Grep/glob for components mentioned in scenario text.

## Step 3: Analyze Application (Browser Tools)

Navigate to target module and document:

1. **Page Structure**
   - Main sections and components
   - Navigation elements
   - Form fields and inputs
   - Tables and data displays
   - Buttons and actions

2. **Dynamic Elements**
   - Modals and dialogs
   - Dropdowns and selects
   - Loading states
   - Error states

3. **User Journeys**
   - Primary flows (happy path)
   - Alternative flows
   - Error handling paths

## Step 4: Create Test Plan

Write `test-plan.json`:

```json
{
  "sessionId": "uuid",
  "source": "PR #123 - title | module:auth | scenario description",
  "mode": "full|plan-only",
  "timestamp": "ISO",
  "scenarios": [
    {
      "id": "scenario-1",
      "title": "Descriptive test name",
      "category": "happy-path|validation|error-handling|edge-case",
      "preconditions": ["List of required setup steps"],
      "steps": [
        {
          "action": "navigate|click|type|select|verify",
          "target": "selector or description",
          "value": "input value (if applicable)",
          "expected": "expected outcome"
        }
      ],
      "selectors": {
        "elementName": "[data-testid='value']"
      }
    }
  ],
  "selectors": {
    "global": {
      "elementName": "selector"
    }
  },
  "featureFlags": ["flag1", "flag2"],
  "url": "/dashboard/{module}"
}
```

### Coverage Requirements

Every test plan must include scenarios for:

- ✅ **Happy path** - Standard success flow
- ✅ **Edge cases** - Empty, min, max, special chars
- ✅ **Input validation** - Invalid, malformed data
- ✅ **Error handling** - API errors, network failures
- ✅ **Cross-component** - Impacts on related features
- ✅ **Second-order effects** - Components using changed code

### Scenario Categories

| Category             | Description                       | Example                          |
| -------------------- | --------------------------------- | -------------------------------- |
| Component visibility | All UI elements render            | Headings, buttons, inputs render |
| Happy path           | Primary flow works end-to-end     | Create, save, activate works     |
| Validation           | Form validation catches bad input | Invalid email rejected           |
| Empty state          | Behavior when no data             | "No results" message shown       |
| Error handling       | Graceful failure handling         | API error shows toast            |
| Navigation           | Links and routing work            | Sidebar nav, breadcrumbs         |
| Data display         | Tables/lists show correct data    | Column values match API          |
| Interaction          | Modals, dropdowns work            | Open/close modal, apply filters  |

## Step 5: Verify Output

Before returning to orchestrator:

- [ ] All `data-*` selectors reference attributes that exist in source
- [ ] Scenarios cover all coverage requirements
- [ ] Feature flags identified if module is FF-gated
- [ ] test-plan.json is valid JSON
- [ ] At least one scenario in each required category

## Step 6: Return to Orchestrator

Update `session.json`:

```json
{
  "phase": "planning-complete",
  "metrics": {
    "testsPlanned": N
  }
}
```

Report to orchestrator: "Planning complete. {N} scenarios created in test-plan.json"

---

## Conventions

- Use `data-testid` selectors as primary
- Add `{ timeout: 10000 }` for API-dependent renders
- One test per scenario
- Use `test.beforeEach` for common setup (document in preconditions)
- Prefer semantic selectors (getByRole, getByLabel) over testid

## References

- Conventions: `SKILL.md`
- Orchestrator: `orchestrator.md`
- Next step: `_generator.md`
