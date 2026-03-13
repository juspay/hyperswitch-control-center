---
name: cypress-pr-tests
description: Generates Cypress E2E test cases for a PR by analyzing its diff, identifying affected UI flows, and producing Page Object classes, test specs, and custom commands that follow the repository's existing patterns.
---

# Cypress PR Test Generator

Generate comprehensive Cypress end-to-end tests for Pull Requests in the Hyperswitch Control Center.

## When to Use

Use this skill when you need to:

- Generate Cypress tests covering the changes introduced by a PR
- Add E2E coverage for a new feature, page, or flow
- Extend existing test suites after UI or API changes

## Step-by-Step Workflow

### Step 1 — Gather the PR diff

Obtain the full diff for the PR. Use `gh pr diff <number>` or `git diff <base>...HEAD`.

Identify:

- New or modified ReScript/React components (`.res` files compiled to `.bs.js`)
- New routes or pages added to the application
- New or changed `data-testid`, `data-button-for`, `data-component`, `data-icon`, `data-table-*`, `data-toast`, `data-dropdown-*`, `data-date-picker-*`, `data-form-error`, `data-value`, `data-label`, `data-searched-text` attributes in the diff
- New or modified API endpoints hit by the dashboard
- Changes to feature flags or permission models

### Step 2 — Map changes to testable flows

For each meaningful change, determine:

1. Which user-facing flow is affected (e.g., login, connector setup, payment operations)
2. Whether this is a new page, a modification to an existing page, or a backend-only change
3. What prerequisite state is needed (logged-in user, connector created, payment created)
4. Whether RBAC permission tags are relevant

### Step 3 — Check for existing coverage

Before writing new tests, search the existing suite:

- Test files: `cypress/e2e/<N>-<feature>/<name>.cy.js`
- Page objects: `cypress/support/pages/<feature>/<PageName>.js`
- Custom commands: `cypress/support/commands.js`
- Helper utilities: `cypress/support/helper.js`
- Permissions matrix: `cypress/support/permissions.js`

If tests already exist for the affected flow, extend them rather than creating duplicates.

### Step 4 — Generate test artifacts

Produce the following as needed:

#### 4a. Page Object classes

Location: `cypress/support/pages/<feature>/<PageName>.js`

```js
class ExamplePage {
  // Use getter pattern — every getter returns a cy.get() call
  get elementName() {
    return cy.get('[data-testid="element-name"]');
  }

  get actionButton() {
    return cy.get('[data-button-for="actionName"]');
  }

  get modalContainer() {
    return cy.get('[data-component="modal:Modal Title"]');
  }

  get toastMessage() {
    return cy.get('[data-toast="Success message"]');
  }

  get tableCell() {
    // Format: {TableName}_tr{row}_td{col}
    return cy.get('[data-table-location="Orders_tr1_td2"]');
  }

  get columnHeader() {
    return cy.get('[data-table-heading="ColumnName"]');
  }
}

export default ExamplePage;
```

Selector priority (use the highest-priority selector available):

1. `[data-testid="..."]` — interactive elements, form inputs, sidebar nav
2. `[data-button-for="..."]` — buttons (camelCase action: `connectAndProceed`, `saveChanges`)
3. `[data-component="modal:..."]` — modals
4. `[data-toast="..."]` — toast notifications
5. `[data-table-location="..."]` / `[data-table-heading="..."]` — tables
6. `[data-icon="..."]` — icon elements
7. `[data-dropdown-value="..."]` / `[data-dropdown-numeric="..."]` — dropdowns
8. `[data-date-picker-predefined="..."]` — date pickers
9. `[data-form-error]` — form validation errors
10. `[data-value="..."]` — value-bearing elements
11. `[data-label="..."]` — status labels
12. `[data-searched-text="..."]` — search results
13. `[name="..."]` — form inputs (fallback)
14. `#id` — only when data attributes are unavailable
15. `cy.contains("text")` — last resort for text-based lookups

Avoid exact `[class="..."]` selectors — they are brittle with Tailwind.

#### 4b. Test spec files

Location: `cypress/e2e/<N>-<feature>/<name>.cy.js`

Directory numbering follows the existing convention:

- `1-auth/` — authentication flows
- `2-homepage/` — homepage components
- `3-operations/` — payment operations
- `4-connectors/` — connector management
- `5-analytics/` — analytics/performance
- `6-workflow/` — routing/workflows
- `7-developers/` — developer settings
- `8-settings/` — user/settings management
- `9-profile/` — user profile

For a new feature, use the next available number or the most appropriate existing directory.

```js
import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import FeaturePage from "../../support/pages/<feature>/FeaturePage";

const homePage = new HomePage();
const featurePage = new FeaturePage();

beforeEach(function () {
  // Every test creates a fresh isolated user
  const email = helper.generateUniqueEmail();
  cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

  // Optional: intercept feature flags if the feature requires them
  cy.intercept("GET", "/dashboard/config/feature?domain=", (req) => {
    req.continue((res) => {
      if (res.body && res.body.features) {
        res.body.features.my_feature = true;
      }
    });
  }).as("getFeatureData");

  cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
});

describe("Feature Name", () => {
  // --- Happy-path tests ---

  it("should display all components on the page", () => {
    // Navigate via sidebar using HomePage page object
    homePage.sidebarItem.click();

    // Assert page elements are visible
    featurePage.heading.should("be.visible");
    featurePage.description.should("contain.text", "Expected text");
    featurePage.actionButton.should("be.visible");
  });

  it("should complete the primary flow successfully", () => {
    // Setup prerequisite data via API
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
      });

    // Navigate and perform actions
    homePage.sidebarItem.click();
    featurePage.inputField.type("value");
    featurePage.submitButton.click();

    // Assert success
    cy.get('[data-toast="Success!"]').should("be.visible");
    cy.url().should("include", "/expected-path");
  });

  // --- Error / validation tests ---

  it("should show validation error for invalid input", () => {
    homePage.sidebarItem.click();
    featurePage.inputField.type("invalid");
    featurePage.inputField.blur();
    cy.get("[data-form-error]").should("be.visible");
    featurePage.submitButton.should("be.disabled");
  });

  // --- Empty-state tests ---

  it("should display empty state when no data exists", () => {
    homePage.sidebarItem.click();
    cy.contains("No results found").should("be.visible");
  });

  // --- RBAC-tagged tests (if applicable) ---

  it("should allow access for admin @operations @org", () => {
    // Test with permission tags in the title
    homePage.sidebarItem.click();
    featurePage.adminAction.should("be.visible");
  });
});
```

#### 4c. Custom commands (if needed)

Add to `cypress/support/commands.js`. Follow the naming convention: `verb_noun` or `verbNoun`.

```js
Cypress.Commands.add("createFeatureDataAPI", (merchant_id) => {
  cy.createAPIKey(merchant_id).then((apiKey) => {
    cy.request({
      method: "POST",
      url: `http://localhost:8080/feature-endpoint`,
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
      body: {
        // request body matching the API contract
      },
    });
  });
});
```

Key points for custom commands:

- API setup calls go to `http://localhost:8080` (the backend directly)
- Dashboard API calls go to `http://localhost:9000/api/...`
- Use `cy.createAPIKey(merchant_id)` to get an API key for backend calls
- Return values from commands using `.then()` chains
- Use `Cypress.env("CYPRESS_USERNAME")` and `Cypress.env("CYPRESS_PASSWORD")` as defaults

### Step 5 — Define test scenarios

For every PR, generate tests covering these categories:

| Category             | What to test                           | Example                                  |
| -------------------- | -------------------------------------- | ---------------------------------------- |
| Component visibility | All UI elements render correctly       | Headings, buttons, inputs, cards         |
| Happy path           | Primary user flow works end-to-end     | Create, save, activate                   |
| Validation           | Form validation catches bad input      | Invalid email, empty required fields     |
| Empty state          | Behavior when no data exists           | "No results found" message               |
| Error handling       | Graceful handling of failures          | API errors, invalid credentials          |
| Navigation           | Links and routing work correctly       | Sidebar nav, breadcrumbs, URL assertions |
| Data display         | Tables/lists show correct data         | Column values match API response         |
| Interaction          | Modals, dropdowns, filters work        | Open/close modal, apply/clear filters    |
| Prerequisite setup   | Tests that need data create it via API | Connectors, payments, API keys           |

### Step 6 — Verify output

Before finalizing, check:

- [ ] Skill name in directory matches `name` in frontmatter
- [ ] All `data-testid` values reference attributes that exist in the PR diff or the current codebase
- [ ] `beforeEach` creates a fresh user (no shared state between tests)
- [ ] No `afterEach` needed (tests are self-contained)
- [ ] Page object getters return `cy.get(...)` calls (not stored values)
- [ ] Imports use relative paths from `cypress/e2e/<N>-<feature>/` to `../../support/...`
- [ ] Assertions use `.should("be.visible")`, `.should("contain.text", ...)`, `.should("include", ...)`
- [ ] API setup uses the correct host (`localhost:8080` for backend, `localhost:9000` for dashboard)
- [ ] Feature flag intercepts use `req.continue()` to modify real responses (not full stubs) unless stubbing is intentional
- [ ] Tests do not duplicate existing coverage in the suite
- [ ] merchant_id is obtained from the DOM: `homePage.merchantID.eq(0).invoke("text")`
- [ ] RBAC tags are included in test titles when the feature is permission-gated

## Reference: Available Custom Commands

| Command                                          | Purpose                                             |
| ------------------------------------------------ | --------------------------------------------------- |
| `cy.signup_API(email, password)`                 | Create a test user via backend API                  |
| `cy.login_UI(email, password)`                   | Login through the UI (types credentials, skips 2FA) |
| `cy.login_API(email, password)`                  | Login via API (no UI interaction)                   |
| `cy.visit_signupPage()`                          | Navigate to `/register`                             |
| `cy.sign_up_with_email(username, password)`      | Full email signup flow with MailHog verification    |
| `cy.enable_email_feature_flag()`                 | Intercept feature config to enable email feature    |
| `cy.mock_magic_link_signin_success(email)`       | Stub magic link API to return success               |
| `cy.createAPIKey(merchant_id)`                   | Create an API key for a merchant (returns key)      |
| `cy.createDummyConnectorAPI(merchant_id, label)` | Create a Stripe Test connector via API              |
| `cy.createPaymentAPI(merchant_id)`               | Create a $100 USD card payment via API              |
| `cy.create_connector_UI()`                       | Full UI flow to connect Stripe Dummy processor      |
| `cy.deleteConnector(mca_id)`                     | Delete a connector via API                          |
| `cy.process_payment_sdk_UI()`                    | Process a payment through the SDK iframe            |
| `cy.checkPermissionsFromTestName(testName)`      | Check RBAC permissions from test title tags         |
| `cy.redirect_from_mail_inbox()`                  | Navigate to MailHog, click verification link        |
| `cy.signin_from_mail_inbox()`                    | Navigate to MailHog, click magic link sign-in       |
| `cy.create_auth()`                               | Create OpenID Connect auth method for Okta SSO      |
| `cy.get_authID_by_email()`                       | Get auth ID by email domain                         |

## Reference: Helper Utilities

From `cypress/support/helper.js`:

- `helper.generateUniqueEmail()` — returns `cypress+org_admin_{timestamp}@test.com`
- `helper.generateDateTimeString()` — returns compact ISO datetime string (14 chars)

## Reference: RBAC Permission Tags

**Access level tags** (in test title): `@org`, `@merchant`, `@profile`

**Section tags** (in test title): `@operations`, `@connectors`, `@analytics`, `@workflows`, `@reconOps`, `@reconReports`, `@users`, `@account`

**Roles**: `admin`, `customer_support`, `developer`, `iam_admin`, `operator`, `view_only`

The `RBAC` env var format is `"accessLevel,role"` (e.g., `"profile,admin"`). When empty, RBAC checking is skipped.

## Reference: Iframe Access Pattern

For testing embedded iframes (e.g., payment SDK):

```js
const getIframeBody = () => {
  return cy
    .get("iframe")
    .its("0.contentDocument.body")
    .should("not.be.empty")
    .then(cy.wrap);
};

// Usage:
getIframeBody()
  .find("[data-testid=cardNoInput]", { timeout: 20000 })
  .should("exist")
  .type("4242424242424242");
```

## Reference: Clipboard Access Pattern

For testing copy-to-clipboard:

```js
cy.window()
  .its("navigator.clipboard")
  .then((clip) => clip.readText())
  .then((copiedText) => {
    // use copiedText
  });
```

## Reference: Feature Flag Intercept Pattern

To enable a feature flag for tests:

```js
cy.intercept("GET", "/dashboard/config/feature?domain=", (req) => {
  req.continue((res) => {
    if (res.body && res.body.features) {
      res.body.features.feature_name = true;
    }
  });
}).as("getFeatureData");
```

## Reference: Table Data Verification Pattern

```js
// Verify table headers
cy.get("table thead tr th").should("have.length", expectedCount);

// Verify specific header exists
cy.get('[data-table-heading="PaymentId"]').should("exist");

// Verify table cell content (row 1, column 2)
cy.get('[data-table-location="Orders_tr1_td2"]')
  .should("be.visible")
  .and("contain.text", "expected value");
```
