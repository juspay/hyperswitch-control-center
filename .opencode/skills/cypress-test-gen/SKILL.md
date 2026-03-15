---
name: cypress-test-gen
description: Generate Cypress E2E tests for PRs, tags, modules, or custom scenarios. Triggers on phrases like "generate cypress tests", "generate-cypress-tests", "write tests for PR", "create cypress tests for tag", "generate tests for module". Also triggers on "@bot generate-cypress-tests #123", "@bot generate-cypress-tests tag:2026.03.14", "@bot generate-cypress-tests module:payment-operations".
---

# Cypress Test Generation Skill

You generate Cypress E2E tests on demand. You follow exact test patterns from this repo and always ask the user before committing or pushing.

---

## Step 0: Parse the Prompt

Detect the mode from the user's message:

| Pattern          | Mode         | Example                                             |
| ---------------- | ------------ | --------------------------------------------------- |
| `#123` or PR URL | **pr**       | `generate-cypress-tests #42`                        |
| Multiple `#N`    | **pr-batch** | `generate-cypress-tests #42 #55 #78`                |
| `tag:<name>`     | **tag**      | `generate-cypress-tests tag:2026.03.14`             |
| `module:<name>`  | **module**   | `generate-cypress-tests module:payment-operations`  |
| Free text        | **scenario** | `generate-cypress-tests "user creates a connector"` |

Print: `=== Cypress Test Generation === Mode: <mode> Target: <target>`

---

## Step 1: Gather Context

### 1a: Read test infrastructure (ALWAYS — before generating anything)

Read ALL of these files to discover available commands, helpers, selectors, and patterns:

| File / Directory                                   | What to learn                                                                              |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `cypress/support/commands.js`                      | All custom Cypress commands (cy.signup_API, cy.login_UI, cy.createDummyConnectorAPI, etc.) |
| `cypress/support/helper.js`                        | Utility functions (generateUniqueEmail, generateDateTimeString)                            |
| `cypress/support/e2e.js`                           | Support entry point — imports and plugins loaded                                           |
| `cypress/support/pages/**/*.js`                    | ALL page objects — class names, getter properties, selectors used                          |
| `cypress/e2e/4-connectors/connector.cy.js`         | Reference test — connector setup flow                                                      |
| `cypress/e2e/3-operations/paymentOperations.cy.js` | Reference test — operations with filters, columns, search                                  |
| `cypress/e2e/1-auth/auth.cy.js`                    | Reference test — auth flows                                                                |
| `cypress.config.js`                                | Base URL, viewport, env vars                                                               |

Do NOT hardcode selectors from memory. Always read page objects and source files at runtime to discover the current `data-testid`, `data-button-for`, and other `data-*` attributes.

### 1b: Mode-specific context

**PR / PR-batch:** Fetch PR metadata and diff via `gh pr view` and `gh pr diff`. Read FULL source files touched by the PR to find `data-*` attributes, navigation flows, form fields, and API calls.

**Tag:** Find previous tag via `git tag --sort=-creatordate`, get merge commits between tags, extract PR numbers, then run PR mode for each.

**Module:** Map module name to source directories and read matching files. See the full module list below.

**Scenario:** Grep/glob for components mentioned in the scenario text.

### Dashboard modules (Orchestrator V1 — primary dashboard)

The sidebar has these sections. When the user says `module:<name>`, map to the correct source paths:

**Operations:**

- `payments` → `src/**/Payment*`, `src/**/Orders*` — payment list, detail, filters
- `refunds` → `src/**/Refund*` — refund list and management
- `disputes` → `src/**/Dispute*` — dispute list and management
- `payouts` → `src/**/Payout*` (feature-flagged) — payout operations
- `customers` → `src/**/Customer*` — customer list

**Connectors:**

- `payment-processors` → `src/**/Connector*`, `src/**/PaymentProcessor*` — connector setup/management
- `payout-processors` → `src/**/PayoutConnector*` (feature-flagged)
- `3ds-authenticators` → `src/**/ThreeDsAuthenticator*`, `src/**/ThreeDS*` (feature-flagged)
- `fraud-risk` → `src/**/FRM*`, `src/**/FraudRisk*` (feature-flagged)
- `pm-auth-processor` → `src/**/PMAuthentication*` (feature-flagged)
- `tax-processor` → `src/**/TaxProcessor*` (feature-flagged)

**Analytics:**

- `analytics-payments` → `src/**/Analytics*Payment*` — payment analytics
- `analytics-refunds` → `src/**/Analytics*Refund*` — refund analytics
- `analytics-disputes` → `src/**/Analytics*Dispute*` (feature-flagged)
- `analytics-authentication` → `src/**/Analytics*Authentication*` (feature-flagged)
- `performance-monitor` → `src/**/PerformanceMonitor*` (feature-flagged)

**Workflow:**

- `routing` → `src/**/Routing*` — payment routing (volume, rule-based, default fallback)
- `surcharge` → `src/**/Surcharge*` (feature-flagged)
- `3ds-decision` → `src/**/ThreeDS*Decision*`, `src/**/3ds*` — 3DS decision manager
- `payout-routing` → `src/**/PayoutRouting*` (feature-flagged)

**Developers:**

- `payment-settings` → `src/**/PaymentSettings*` — payment configuration
- `api-keys` → `src/**/APIKeys*`, `src/**/DeveloperAPIKeys*` — API key management
- `webhooks` → `src/**/Webhook*` (feature-flagged)

**Settings:**

- `users` → `src/**/Users*` — user invitation and role management
- `configure-pmts` → `src/**/ConfigurePMTs*` (feature-flagged)
- `compliance` → `src/**/Compliance*` (feature-flagged)

**Auth (standalone):**

- `auth` → `src/**/Auth*`, `src/**/Login*`, `src/**/SignIn*`, `src/**/SignUp*`

If the module name doesn't match any of the above, list these options and ask the user to pick.

---

## Step 2: Check for Duplicates

```bash
ls cypress/e2e/cypress-ai-generated/PR-<NUMBER>-*.cy.js 2>/dev/null
ls cypress/e2e/cypress-ai-generated/module-<name>*.cy.js 2>/dev/null
ls cypress/e2e/cypress-ai-generated/scenario-*.cy.js 2>/dev/null
```

If found, inform the user the file will be overwritten.

---

## Step 3: Generate the Test

Use the `cypress-test-writer` sub-agent via the Task tool. Pass ALL context from Step 1 (file contents, not summaries). The sub-agent MUST follow these rules:

### File naming and location

- PR: `PR-<number>-<slug>.cy.js` — Module: `module-<name>.cy.js` — Scenario: `scenario-<slug>.cy.js`
- Slug: lowercase, hyphens, max 50 chars
- All test files go in `cypress/e2e/cypress-ai-generated/`
- New page objects go in `cypress/support/pages/cypress-ai-generated/`

### Header comment (required on every file)

```javascript
/**
 * Auto-generated Cypress test
 * Source: <PR #42 - title / module:name / scenario description>
 * Generated: <YYYY-MM-DD>
 * This test was auto-generated and may need manual adjustments.
 */
```

### Imports and setup (follow existing tests exactly)

```javascript
import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
const homePage = new HomePage();

beforeEach(function () {
  const email = helper.generateUniqueEmail();
  cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

  // If the feature under test is behind a feature flag, intercept before login:
  // cy.intercept("GET", "/dashboard/config/feature?domain=", (req) => {
  //   req.continue((res) => {
  //     if (res.body && res.body.features) {
  //       res.body.features.feature_name = true;
  //     }
  //   });
  // }).as("getFeatureData");

  cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
});
```

When the PR or module involves a feature-flagged page (payouts, 3DS, fraud-risk, webhooks, etc.), **uncomment and adapt** the intercept block above. Use `req.continue()` to modify the real response — do not fully stub it.

### Selector priority (STRICT order)

Use the highest-priority selector available. CSS class/tag selectors are **ABSOLUTE LAST RESORT**.

1. `[data-testid="..."]` — best, always prefer
2. `[data-button-for="..."]` — buttons
3. `[data-component="..."]` — modals/complex components
4. `[data-table-location="..."]` — table cells (pattern: `{Table}_tr{N}_td{N}`)
5. `[data-icon="..."]` — icon elements
6. `[data-toast="..."]` — toast notifications
7. `[data-button-text="..."]` — button text identifiers
8. `[data-value="..."]` / `[data-dropdown-value="..."]` / `[data-label="..."]` — dropdowns/labels
9. `[data-date-picker-predefined="..."]` / `[data-daterange-dropdown-value="..."]` — date pickers
10. `[data-component-field-wrapper="..."]` / `[data-searched-text="..."]` — field wrappers/search
11. `[data-table-heading="..."]` / `[data-dropdown-numeric]` — table headings
12. `[data-breadcrumb="..."]` / `[data-form-error]` — breadcrumbs/form errors
13. `[name="..."]` — form fields
14. `#id` — only when no data attributes are available
15. `cy.contains("exact text")` — text-based selection
16. CSS class/tag selectors — **LAST RESORT ONLY**, always add `// TODO: replace with data-testid`

To discover available selectors: read the page objects in `cypress/support/pages/` and the actual source component files. Never guess selectors — verify they exist in source code.

### Test structure rules

1. **describe block** MUST include source: `describe("Payment Filters - PR #42", () => { ... })`
2. **API-first setup**: Create data via API commands, not UI:
   ```javascript
   homePage.merchantID
     .eq(0)
     .invoke("text")
     .then((merchant_id) => {
       cy.createDummyConnectorAPI(merchant_id, "test_connector");
       cy.createPaymentAPI(merchant_id);
     });
   ```
3. **Navigation**: Use page object sidebar getters: `homePage.operations.click();`
4. **Assertions**: Use `.should()` chains, `cy.url().should("include", ...)`, `cy.contains().should("be.visible")`
5. **Timeouts**: Explicit for slow elements: `cy.get('[data-toast="..."]', { timeout: 10000 })`
6. **Force clicks**: Only when elements are covered by overlays: `.click({ force: true })`
7. **New page objects**: ES6 class, getter properties returning `cy.get()`, default export

### What to test — generate tests covering these categories

| Category             | What to test                      | Example                                  |
| -------------------- | --------------------------------- | ---------------------------------------- |
| Component visibility | All UI elements render            | Headings, buttons, inputs, cards         |
| Happy path           | Primary flow works end-to-end     | Create, save, activate                   |
| Validation           | Form validation catches bad input | Invalid email, empty required fields     |
| Empty state          | Behavior when no data exists      | "No results found" message               |
| Error handling       | Graceful failure handling         | API errors, invalid credentials          |
| Navigation           | Links and routing work            | Sidebar nav, breadcrumbs, URL assertions |
| Data display         | Tables/lists show correct data    | Column values match API response         |
| Interaction          | Modals, dropdowns, filters work   | Open/close modal, apply/clear filters    |

### What NOT to test

Pure backend/API changes, config files, docs, CI changes, type-only changes.

### API host distinction

- Backend API (user signup, connectors, payments): `http://localhost:8080`
- Dashboard API (login, feature config): `http://localhost:9000/api/...`

When writing custom commands that call APIs directly, use the correct host.

### Common test patterns

**Iframe access** (for embedded SDK / payment iframes):

```javascript
const getIframeBody = () => {
  return cy
    .get("iframe")
    .its("0.contentDocument.body")
    .should("not.be.empty")
    .then(cy.wrap);
};
getIframeBody()
  .find('[data-testid="cardNoInput"]', { timeout: 20000 })
  .type("4242424242424242");
```

**Clipboard verification** (for copy-to-clipboards):

```javascript
cy.window()
  .its("navigator.clipboard")
  .then((clip) => clip.readText())
  .then((copiedText) => {
    // assert on copiedText
  });
```

**Table data verification**:

```javascript
cy.get("table thead tr th").should("have.length", expectedCount);
cy.get('[data-table-heading="Payment ID"]').should("exist");
cy.get('[data-table-location="Orders_tr1_td2"]').should(
  "contain.text",
  "expected value",
);
```

---

## Step 4: Verify Before Showing

Before showing output, run this checklist:

- [ ] All `data-*` selectors reference attributes that exist in the PR diff or current source code
- [ ] `beforeEach` creates a fresh user — no shared state between tests
- [ ] Page object getters return `cy.get(...)` calls, not stored values
- [ ] Imports use relative paths: `../../support/...` (tests are 2 levels deep in `cypress/e2e/cypress-ai-generated/`)
- [ ] API setup uses correct host (`localhost:8080` for backend, `localhost:9000` for dashboard)
- [ ] `merchant_id` is obtained from the DOM: `homePage.merchantID.eq(0).invoke("text")`
- [ ] Feature-flagged modules have the intercept block in `beforeEach`
- [ ] Tests do not duplicate existing coverage in `cypress/e2e/1-auth/` through `cypress/e2e/9-profile/`
- [ ] No `afterEach` blocks — tests are self-contained with fresh users

## Step 5: Show Generated Files

Display file list with test counts, then show FULL content. Ask the user:

```
Options: 1. Push to PR branch  2. Create new branch and PR  3. Skip (local only)
```

Wait for confirmation. NEVER commit or push without it.

---

## Step 6: Commit and Push (after user confirms)

**Option 1 — Push to PR branch:**

```bash
gh pr checkout <NUMBER>
mkdir -p cypress/e2e/cypress-ai-generated
git add cypress/e2e/cypress-ai-generated/ cypress/support/pages/cypress-ai-generated/
git commit -m "chore(cypress): auto-generated test for PR #<NUMBER>"
git push
```

**Option 2 — New branch and PR:**

```bash
git checkout -b chore/cypress-test-PR-<NUMBER>
# write, stage, commit, push
git push -u origin HEAD
```

Ask before creating PR. Use `gh pr create` with body listing generated files and test descriptions.

**Option 3 — Skip:** List files written locally.

---

## Step 7: Report Summary

Single PR: `=== Complete === Mode: PR #42 Files: N Status: pushed/skipped`

Batch/tag: Show table with PR, file, test count, status per row. Mark skipped PRs (no UI changes) with reason.

---

## Cypress Folder Structure

```
cypress/
├── e2e/
│   ├── 1-auth/ through 9-profile/          # Manual tests — NEVER modify
│   └── cypress-ai-generated/                # Auto-generated tests go here
├── support/
│   ├── commands.js                          # Custom commands — append-only (ask user first)
│   ├── helper.js                            # Utilities — NEVER modify
│   ├── e2e.js                               # Support entry — NEVER modify
│   └── pages/
│       ├── auth/                            # SignInPage, SignUpPage, ResetPasswordPage — NEVER modify
│       ├── connector/                       # PaymentConnector — NEVER modify
│       ├── homepage/                        # HomePage — NEVER modify
│       ├── operations/                      # PaymentOperations — NEVER modify
│       ├── workflow/paymentRouting/          # PaymentRouting, VolumeBasedConfiguration, DefaultFallback — NEVER modify
│       └── cypress-ai-generated/            # New page objects go here
└── cypress.config.js                        # Base URL: localhost:9000, viewport: 1440x1005
```

No fixtures exist. Test data is created via API commands.

---

## Error Handling

- `gh` not authenticated → tell user to run `gh auth login`
- PR/tag not found → report clearly with available alternatives
- No testable UI changes → skip with reason
- Module not recognized → list available modules and ask user to pick
- No `data-*` attributes found in source → use `cy.contains()` / `[name="..."]`, add warning comment
- Git push fails → report error with guidance

## Important Rules

- NEVER modify files in `cypress/e2e/1-auth/` through `cypress/e2e/9-profile/`
- NEVER modify `cypress/support/helper.js`, `cypress/support/e2e.js`, or existing page objects
- Adding new commands to `cypress/support/commands.js` is allowed when a PR introduces a new API that needs a setup command. Follow naming convention: `verb_noun` or `verbNoun`. Use `cy.createAPIKey(merchant_id)` to get API keys for backend calls. Always ask the user before modifying `commands.js`.
- ONLY create new page objects in `cypress/support/pages/cypress-ai-generated/`
- ALWAYS use `beforeEach` with `cy.signup_API` + `cy.login_UI` for fresh user isolation
- ALWAYS use `../../support/...` relative import paths (tests are 2 levels deep)
- CSS class selectors are ABSOLUTE LAST RESORT — exhaust all `data-*`, `[name]`, and `cy.contains()` first
- For PR-batch/tag modes, generate ONE test file per PR
- ALWAYS ask user before committing, pushing, or creating PRs
