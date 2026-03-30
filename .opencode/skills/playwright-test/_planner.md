---
name: playwright-planner
description: Test planner sub-agent. Called by orchestrator Step 3 via task(). Analyzes existing tests for deterministic prerequisites, explores live app with browser tools, writes test-plan.json.
mode: subagent
---

# Playwright Test Planner

**Called by:** orchestrator.md Step 3 ONLY (via task())
**Input:** `.opencode/sessions/playwright-run/input-context.json`
**Output:** `.opencode/sessions/playwright-run/test-plan.json`

## Guardrail

Only proceed if `session.json` has `status: "planning"` AND `input-context.json` exists. Otherwise inform orchestrator.

## Step 0: Discover Prerequisites (MANDATORY FIRST)

This is the most critical step. Wrong prerequisites = tests fail in beforeEach = wasted pipeline.

### 0.1 Find Existing Tests for the Target Module

```
Search playwright-tests/e2e/ for spec files matching the target module name.
Read their beforeEach/beforeAll blocks completely.
```

### 0.2 Extract the Setup Chain

From existing tests, extract the EXACT sequence of:
- API calls: `signupUser`, `loginUser`, `createDummyConnectorAPI`, `createPaymentAPI`, etc.
- UI calls: `loginUI`, feature flag mocking, route interception
- Data dependencies: connector needed before payment, payment before refund, user invite before user tests

### 0.3 Read commands.ts

Read `playwright-tests/support/commands.ts` to verify function signatures and return values match what you plan to use.

### 0.4 Read Page Objects

Search `playwright-tests/support/pages/` for Page Objects related to the target module. Record which ones exist for the `existingPageObjects` field.

### 0.5 Determine Prerequisites

**Priority order:**
1. Copy EXACTLY from an existing test's beforeEach for this module
2. If no existing test, compose from the Module Prerequisites table in SKILL.md
3. For unlisted modules: find the closest existing test, adapt its setup chain

**Common prerequisite chains:**
- View-only pages (home, analytics): `signupUser → loginUI`
- Data-dependent pages (payments, refunds, disputes): `signupUser → loginUser → createDummyConnectorAPI → createPaymentAPI`
- Configuration pages (connectors, routing): `signupUser → loginUser → createDummyConnectorAPI`
- User management: `signupUser → loginUI` (invite happens in test body)

## Step 1: Read Input Context

Read `.opencode/sessions/playwright-run/input-context.json`. Extract `target`, `targetType`, `mode`.

## Step 2: Authenticate and Explore (BROWSER TOOLS REQUIRED)

Follow the **Browser Auth for Sub-Agent Exploration** flow from SKILL.md exactly:

1. `browser_navigate` → `http://localhost:9000/dashboard/login`
2. `browser_snapshot` → check URL
3. If NOT on login page → sign out first
4. Create temp user via curl (bash tool)
5. `browser_type` email and password → `browser_click` continue
6. `browser_snapshot` → if 2FA/Skip prompt → `browser_click` "Skip now"
7. Verify on `/dashboard/home`

### Explore Target Page

1. `browser_navigate` to target URL (from module-to-URL mapping in SKILL.md)
2. `browser_snapshot` to capture DOM structure
3. Extract: sections, forms, buttons, `data-testid` attributes, navigation elements
4. For multi-step flows: `browser_click` through each step, `browser_snapshot` at each stage
5. Document all discovered selectors with their purpose

## Step 3: Create Test Plan

Write `.opencode/sessions/playwright-run/test-plan.json`:

```json
{
  "sessionId": "from input-context",
  "source": "PR #N — title | module:name | scenario description",
  "mode": "from input-context",
  "timestamp": "ISO",
  "prerequisites": {
    "description": "Human-readable setup description",
    "sourceTest": "playwright-tests/e2e/{N}-{module}/{file}.spec.ts or 'none — from prerequisites table'",
    "apiSetup": [
      { "function": "signupUser", "args": ["email", "password", "request"] },
      { "function": "loginUser", "args": ["email", "password", "request"], "returns": ["token", "merchantId"] }
    ],
    "uiSetup": [
      { "function": "loginUI", "args": ["page", "email", "password"] }
    ],
    "featureFlags": []
  },
  "scenarios": [
    {
      "id": "scenario-1",
      "title": "Descriptive test name",
      "category": "happy-path|validation|error-handling|edge-case|empty-state|navigation",
      "preconditions": ["Additional setup beyond shared prerequisites"],
      "steps": [
        { "action": "navigate|click|type|select|verify|wait", "target": "selector", "value": "optional", "expected": "outcome" }
      ],
      "selectors": { "elementName": "[data-testid='value']" }
    }
  ],
  "existingPageObjects": ["HomePage", "PaymentOperations"],
  "newLocators": [
    { "element": "description", "selector": "[data-testid='x']", "suggestedPageObject": "ModulePage" }
  ],
  "url": "/dashboard/{module}"
}
```

### Coverage Requirements

Every plan MUST include scenarios for:
- **Happy path** — primary success flow
- **Validation** — invalid/malformed input rejected
- **Edge cases** — empty, min, max, special chars
- **Error handling** — API errors, network failures
- **Component visibility** — all expected UI elements render

## Step 4: Validate and Return

Before returning:
- [ ] `test-plan.json` is valid JSON
- [ ] `prerequisites.sourceTest` points to a real file (or states "none")
- [ ] `prerequisites.apiSetup` uses only functions from commands.ts
- [ ] All `selectors` reference attributes verified via browser_snapshot
- [ ] ≥1 scenario exists
- [ ] Browser tools were actually used

**Call `browser_close` to close the browser session.**

Report: "Planning complete. {N} scenarios in test-plan.json."
