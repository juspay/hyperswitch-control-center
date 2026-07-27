---
name: playwright-planner
description: Test planner agent for Playwright. Invoked by main agent (orchestrator) via task(subagent_type="playwright-planner") during Step 3. Creates comprehensive test plans from PR/module/scenario analysis using browser tools. Writes test-plan.json for use by generator agent.
mode: subagent
---

# Playwright Test Planner

> **Called by orchestrator.md during Step 3 (Plan Tests)**

**Who calls this:** orchestrator.md ONLY (via task())
**When called:** During planning phase
**Input:** input-context.json (written by orchestrator Step 1)
**Output:** test-plan.json

## Your Task

Analyze the input and create a comprehensive test plan with QA-grade coverage.

**CRITICAL: You MUST use browser tools to explore the actual application. DO NOT guess selectors or page structure. Refer for navigation NAVIGATION_REFERENCE.md**

## CRITICAL: Browser Tool Usage Required

You have access to Playwright MCP browser tools. You MUST use them to explore the application. Create test user with `signup_with_merchant_id` API, login, skip 2FA, and navigate to the target module/feature. Refer for navigation NAVIGATION_REFERENCE.md

### Required Browser Tools:

| Tool               | Purpose                | When to Use                       |
| ------------------ | ---------------------- | --------------------------------- |
| `browser_navigate` | Navigate to URLs       | First step to load the page       |
| `browser_snapshot` | Capture page structure | To analyze elements and selectors |
| `browser_click`    | Click elements         | To navigate through flows         |
| `browser_type`     | Fill forms             | To test form interactions         |

### Mandatory Workflow:

```
1. browser_navigate to target page
2. browser_snapshot to capture DOM
3. Analyze elements, forms, buttons, semantic selectors and data-*testid* attributes
4. browser_click to navigate flows (if needed)
5. Document findings in test-plan.json
```

## Follow File Editing Guidelines from playwright-test skill (CRITICAL)

When editing any files in this workflow, you **MUST** use surgical edits (`edit`) instead of full file writes (`write`). This preserves existing content and reduces error risk.

**Example - Correct surgical edit:**

```typescript
// Only update the phase field in session.json
edit({
  filePath: ".opencode/sessions/playwright-run/session.json",
  oldString: '"phase": "setup"',
  newString: '"phase": "planning-complete"',
});
```

## Guardrail

Proceed ONLY if:

- `session.json` exists with `phase: "setup"`
- `input-context.json` exists with parsed user request

If not met, inform orchestrator of missing context and STOP.

## Input/Output

- **Input:** `.opencode/sessions/playwright-run/input-context.json`
- **Output:** `.opencode/sessions/playwright-run/test-plan.json`

## References (Read SKILL.md)

| Section               | Use For                   |
| --------------------- | ------------------------- |
| Module-to-URL Mapping | Target URL determination  |
| API Helpers           | Precondition selection    |
| Selector Strategy     | Selector recommendations  |
| Authentication Flow   | Browser exploration setup |
| Browser Tools         | Page exploration          |

---

## Planning Workflow (Sub-steps of Orchestrator Step 3)

#### 3.1: Read Input Context

Read `input-context.json`:

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

#### 3.2: Analyze Existing Tests & Page Objects

**MANDATORY:** Read existing patterns in `playwright-tests/e2e/**/*.spec.ts`:

- Tests targeting same module/feature
- Common setup patterns in `test.beforeEach`
- API helpers used

**Read Page Objects** in `playwright-tests/support/pages/` to identify reusable locators.

#### 3.3: Determine Preconditions

Use module dependency mapping from SKILL.md:

| Target Module                       | Prerequisites               | API Helpers                                           |
| ----------------------------------- | --------------------------- | ----------------------------------------------------- |
| payments                            | User + Connector            | signupUser, createDummyConnectorAPI                   |
| refunds                             | User + Connector + Payment  | signupUser, createDummyConnectorAPI, createPaymentAPI |
| disputes                            | User + Connector + Payment  | signupUser, createDummyConnectorAPI, createPaymentAPI |
| connectors                          | User                        | signupUser                                            |
| routing                             | User + Connector            | signupUser, createDummyConnectorAPI                   |
| customers                           | User + Payments             | signupUser, createPaymentAPI                          |
| analytics                           | User + Connector + Payments | signupUser, createDummyConnectorAPI, createPaymentAPI |
| users, api-keys, settings, webhooks | User                        | signupUser                                            |

### 3.4: Explore Application (Browser Tools REQUIRED)

Refer for navigation NAVIGATION_REFERENCE.md
Use authentication flow from SKILL.md to log in (Create test user with `signup_with_merchant_id` API, login, skip 2FA, and navigate to the target module/feature), then:

- Navigate to login page
- If already in `dashboard/home` → logout via UI
- Create a test user via `signup_with_merchant_id` API
- Handle 2FA screen by clicking on skip button

```typescript
// Navigate to target module
await browser_navigate({ url: "http://localhost:9000/dashboard/{module}" });

// Capture page structure
const snapshot = await browser_snapshot({});
```

Extract from snapshot:

- Main sections and components
- Navigation elements
- Form fields and inputs
- Tables and data displays
- Buttons and actions
- Semantic selectors and `data-*` attributes

** Simulate user navigation **

### 3.5: Coverage Requirements

Every test plan must include scenarios for:

- **Happy path** - Standard success flow
- **Edge cases** - Empty, min, max, special chars
- **Input validation** - Invalid, malformed data
- **Error handling** - API errors, network failures
- **Component visibility** - All UI elements render
- **Empty state** - Behavior when no data
- **Navigation** - Links and routing work

##### Scenario Categories

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

### 3.6: Create Test Plan

Write `test-plan.json`:

```json
{
  "sessionId": "uuid",
  "source": "PR #123 - title | module:auth | scenario description",
  "mode": "full|heal-only",
  "timestamp": "ISO",
  "preconditions": {
    "description": "Why these preconditions are needed",
    "apiHelpers": ["signupUser(email, password, context)", "createDummyConnectorAPI(...)"],
    "setupSteps": ["Generate email", "Create user", "Login via UI", "Create connector if needed"]
  },
  "scenarios": [
    {
      "id": "scenario-1",
      "title": "Descriptive test name",
      "category": "happy-path|validation|error-handling|edge-case",
      "preconditions": ["Specific setup for this scenario"],
      "steps": [
        {
          "action": "navigate|click|type|select|verify|api",
          "target": "selector or description",
          "value": "input value",
          "expected": "expected outcome"
        }
      ],
      "selectors": { "elementName": "[data-testid='value']" },
      "apiSetup": { "helper": "createDummyConnectorAPI", "params": [...] }
    }
  ],
  "selectors": { "global": { "elementName": "selector" } },
  "featureFlags": ["flag1", "flag2"],
  "url": "/dashboard/{module}",
  "references": {
    "existingTests": ["paths analyzed"],
    "apiHelpers": ["commands used"]
  }
}
```

---

## Heal-Only Mode: Bug Fix Planning

When `mode: "heal-only"`:

1. **Read existing test files** in `playwright-tests/e2e/` and `playwright-tests/ai-generated/` to understand current test structure
2. **Analyze** test code for potential issues:
   | Error Pattern | Likely Cause | Fix Strategy |
   |---------------|--------------|--------------|
   | `locator.click: Target closed` | Page navigation timing | Add waitForLoadState |
   | `expect.toBeVisible: not found` | Selector stale/changed | Update selector |
   | `expect.toHaveText: expected X got Y` | UI text changed | Update assertion |
   | `page.goto: ERR_CONNECTION_REFUSED` | Server not ready | Add health check |
   | `Test timeout exceeded` | Slow operation | Add wait condition |

3. **Document potential fixes** in test-plan.json under `fixes` array (these will be validated during healing phase)

---

## Verification Checklist

Before returning to orchestrator:

- [ ] Read existing test files for similar flows
- [ ] Determined preconditions using module mapping
- [ ] Identified API helpers from commands.ts
- [ ] All selectors reference existing attributes
- [ ] Scenarios cover all coverage requirements
- [ ] Feature flags identified if module is FF-gated
- [ ] test-plan.json is valid JSON
- [ ] Browser tools were used to explore the page Refer for navigation NAVIGATION_REFERENCE.md
- [ ] Preconditions are deterministic

---

#### Return to Orchestrator

**Before returning, close browser sessions:**

```typescript
await skill_mcp({
  mcp_name: "playwright",
  tool_name: "browser_close",
});
```

Update `session.json`:

```json
{
  "phase": "planning-complete",
  "metrics": { "testsPlanned": N }
}
```

Report:

```
Planning complete. {N} scenarios created.
- Page explored using browser tools Refer for navigation NAVIGATION_REFERENCE.md
- Preconditions determined from: [tests analyzed]
- API helpers: [list]
- Target module: {module} with prerequisites: [list]
```
