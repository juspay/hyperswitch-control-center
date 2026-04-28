# Hyperswitch Control Center - Navigation Reference for Playwright MCP

> **Purpose**: This document provides comprehensive locator references and navigation flows for agents using Playwright MCP to explore the Hyperswitch Control Center application.

## Table of Contents

1. [Authentication & Login Flows](#authentication--login-flows)
2. [Sidebar Navigation](#sidebar-navigation)
3. [Common UI Components](#common-ui-components)
4. [Search & Filters](#search--filters)
5. [Tables & Data Grids](#tables--data-grids)
6. [Module-Specific Navigation](#module-specific-navigation)

---

## Authentication & Login Flows

### Login Page (`/`)

#### Login Form Elements

| Element              | Locator                                           | Type           |
| -------------------- | ------------------------------------------------- | -------------- |
| Email Input          | `page.getByPlaceholder("Enter your Email")`       | text input     |
| Password Input       | `page.getByPlaceholder("Enter your Password")`    | password input |
| Sign In Button       | `page.locator('[data-button-for="continue"]')`    | button         |
| Forgot Password Link | `page.locator('[data-testid="forgot-password"]')` | link           |
| Sign Up Link         | `page.locator("#card-subtitle")`                  | link           |
| Email Sign-in Link   | `page.locator('[data-testid="card-foot-text"]')`  | link           |

#### Error States

| Element                   | Locator                                                      |
| ------------------------- | ------------------------------------------------------------ |
| Invalid Credentials Toast | `page.locator('[data-toast="Incorrect email or password"]')` |
| Card Header               | `page.locator("#card-header")`                               |
| Terms Text                | `page.locator("#tc-text")`                                   |
| Footer Text               | `page.locator("#footer")`                                    |

### Sign Up Page (`/register`)

| Element        | Locator                                           |
| -------------- | ------------------------------------------------- |
| Email Input    | `page.getByPlaceholder("Enter your Email")`       |
| Sign Up Button | `page.locator('[data-testid="auth-submit-btn"]')` |
| Header Text    | `page.locator('[data-testid="card-header"]')`     |
| Sign In Link   | `page.locator('[data-testid="card-subtitle"]')`   |
| Footer Text    | `page.locator('[data-testid="card-foot-text"]')`  |
| Form Error     | `page.locator("[data-form-error]")`               |

### Two-Factor Authentication (2FA) Setup

#### Skip 2FA Flow (For Testing)

```javascript
// After successful login, skip 2FA setup
await page.locator('[data-testid="skip-now"]').click();
```

#### 2FA Setup Page Elements

| Element           | Locator                                                                          |
| ----------------- | -------------------------------------------------------------------------------- |
| Header Text       | `page.locator('[class="text-fs-24 leading-32 font-semibold font-inter-style"]')` |
| Instructions      | `page.locator('[class="flex flex-col gap-4"]')`                                  |
| OTP Box           | `page.locator('[class="flex justify-center relative "]')`                        |
| Skip 2FA Button   | `page.locator('[data-testid="skip-now"]')`                                       |
| Enable 2FA Button | `page.locator('[data-button-for="enterCode"]')`                                  |
| Logout Link       | `page.getByText("Click here to log out.")`                                       |

#### Fill OTP Code

```javascript
const textboxes = page.getByRole("textbox");
const count = await textboxes.count();
for (let i = 0; i < otp.length && i < count; i++) {
  await textboxes.nth(i).fill(otp.charAt(i));
}
```

### Reset Password Page

| Element                      | Locator                                                  |
| ---------------------------- | -------------------------------------------------------- |
| Create Password              | `page.locator('[name="create_password"]')`               |
| Confirm Password             | `page.getByPlaceholder("Re-enter your Password")`        |
| Eye Icon (toggle visibility) | `page.locator('[data-icon="eye-slash"]')`                |
| Confirm Button               | `page.locator('[data-button-for="confirm"]')`            |
| New Password Field           | `page.locator('[data-testid="create_password"] input')`  |
| Confirm Password Field       | `page.locator('[data-testid="confirm_password"] input')` |

---

## Sidebar Navigation

### Main Navigation Categories

```javascript
// Click pattern for sidebar navigation
await page.locator("[data-testid=<testid>]").click();
```

#### Overview Section

| Menu Item | data-testid                       | Route                |
| --------- | --------------------------------- | -------------------- |
| Home V2   | Not directly clickable via testid | `/dashboard/v2/home` |
| Overview  | `"overview"`                      | `/dashboard/home`    |
| Users     | `"users"`                         | `/dashboard/users`   |

#### Operations Section

| Menu Item           | data-testid    | Route                  |
| ------------------- | -------------- | ---------------------- |
| Operations (parent) | `"operations"` | Expands submenu        |
| Payments            | `"payments"`   | `/dashboard/payments`  |
| Refunds             | `"refunds"`    | `/dashboard/refunds`   |
| Disputes            | `"disputes"`   | `/dashboard/disputes`  |
| Payouts             | `"payouts"`    | `/dashboard/payouts`   |
| Customers           | `"customers"`  | `/dashboard/customers` |

#### Connectors Section

| Menu Item           | data-testid           | Route                                    |
| ------------------- | --------------------- | ---------------------------------------- |
| Connectors (parent) | `"connectors"`        | Expands submenu                          |
| Payment Processors  | `"paymentprocessors"` | `/dashboard/connectors`                  |
| Payout Processors   | `"payoutprocessors"`  | `/dashboard/payoutconnectors`            |
| 3DS Authenticators  | `"3dsauthenticators"` | `/dashboard/3ds-authenticators`          |
| Fraud & Risk        | `"fraud&risk"`        | `/dashboard/fraud-risk-management`       |
| PM Auth Processor   | `"pmauthprocessor"`   | `/dashboard/pm-authentication-processor` |
| Tax Processor       | `"taxprocessor"`      | `/dashboard/tax-processor`               |
| Billing Processor   | `"billingprocessor"`  | `/dashboard/billing-processor`           |
| Vault Processor     | `"vaultprocessor"`    | `/dashboard/vault-processor`             |

#### Analytics Section

| Menu Item          | data-testid   | Route                           |
| ------------------ | ------------- | ------------------------------- |
| Analytics (parent) | `"analytics"` | Expands submenu                 |
| Payments Analytics | `"payments"`  | `/dashboard/analytics-payments` |
| Refund Analytics   | `"refunds"`   | `/dashboard/analytics-refunds`  |

#### Workflow Section

| Menu Item             | data-testid             | Route                      |
| --------------------- | ----------------------- | -------------------------- |
| Workflow (parent)     | `"workflow"`            | Expands submenu            |
| Routing               | `"routing"`             | `/dashboard/routing`       |
| Surcharge             | `"surcharge"`           | `/dashboard/surcharge`     |
| 3DS Decision Manager  | `"3dsdecisionmanager"`  | `/dashboard/3ds`           |
| Payout Routing        | `"payoutrouting"`       | `/dashboard/payoutrouting` |
| 3DS Exemption Manager | `"3dsexemptionmanager"` | `/dashboard/3ds-exemption` |

#### Vault Section

| Menu Item          | data-testid          | Route                               |
| ------------------ | -------------------- | ----------------------------------- |
| Vault (parent)     | `"vault"`            | Expands submenu                     |
| Configuration      | `"configuration"`    | `/dashboard/vault-onboarding`       |
| Customers & Tokens | `"customers&tokens"` | `/dashboard/vault-customers-tokens` |

#### Developer Section

| Menu Item          | data-testid         | Route                           |
| ------------------ | ------------------- | ------------------------------- |
| Developer (parent) | `"developers"`      | Expands submenu                 |
| Payment Settings   | `"paymentsettings"` | `/dashboard/payment-settings`   |
| API Keys           | `"apikeys"`         | `/dashboard/developer-api-keys` |
| Webhooks           | `"webhooks"`        | `/dashboard/webhooks`           |

#### Settings Section

| Menu Item             | data-testid              | Route                              |
| --------------------- | ------------------------ | ---------------------------------- |
| Settings (parent)     | `"settings"`             | Expands submenu                    |
| Configure PMTs        | `"configurepmts"`        | `/dashboard/configure-pmts`        |
| Organization Settings | `"organizationsettings"` | `/dashboard/organization-settings` |

### Top Bar Elements

| Element               | Locator                                               |
| --------------------- | ----------------------------------------------------- |
| User Account Dropdown | `page.locator('[data-icon="nd-dropdown-menu"]')`      |
| Sign Out              | `page.getByText("Sign out")`                          |
| Global Search         | `page.locator('[class="w-max"]')`                     |
| Merchant Dropdown     | `page.locator('[class="w-fit flex flex-col gap-4"]')` |
| Profile Dropdown      | `page.locator('[class="md:max-w-40 max-w-16"]')`      |
| Org Chart Icon        | `page.locator('[data-icon="github-fork"]')`           |

---

## Common UI Components

### Button Patterns

| Button Type     | Attribute Pattern        | Examples                                                         |
| --------------- | ------------------------ | ---------------------------------------------------------------- |
| Primary Actions | `data-button-for="..."`  | `[data-button-for="continue"]`, `[data-button-for="connectNow"]` |
| Text Buttons    | `data-button-text="..."` | `[data-button-text="Connect"]`, `[data-button-text="Save"]`      |
| Icon Buttons    | `data-icon="..."`        | `[data-icon="plus"]`, `[data-icon="eye-slash"]`                  |

### Common Button Selectors

```javascript
// Save button
page.locator('[data-button-text="Save"]');

// Cancel button
page.getByRole("button", { name: "Cancel" });

// Update button
page.getByRole("button", { name: "Update" });

// Connect button
page.locator('[data-button-text="Connect"]');

// Download button
page.locator('[data-button-for="download"]');

// Try It Out button
page.locator('[data-button-for="tryItOut"]');

// Show Preview button
page.locator('[data-button-for="showPreview"]');

// Proceed button
page.locator("[data-button-for=proceed]");

// Done button
page.locator("[data-button-for=done]");
```

### Form Inputs

```javascript
// Generic text input by name
page.locator('input[name="fieldName"]');

// Input by placeholder
page.getByPlaceholder("Enter your Email");
page.getByPlaceholder("Enter your Password");
page.getByPlaceholder("Enter key");
page.getByPlaceholder("Enter value");
page.getByPlaceholder("Enter Return URL");
page.getByPlaceholder("Enter Webhook URL");
page.getByPlaceholder("Enter Domain Name");
page.getByPlaceholder("Enter Allowed Domain");

// Input by data-testid
page.locator('[data-testid="search-processor"]');
page.locator('[data-testid="amount"] input');
```

### Dropdowns & Selects

```javascript
// Generic role-based dropdown
page.getByRole("button", { name: "Select Option" });

// Dropdown with value attribute
page.locator('[value="stripe_test_1"]');

// Date picker dropdown
page.locator('[data-daterange-dropdown-value="Custom Range"]');
```

### Modals & Dialogs

```javascript
// Modal container by component attribute
page.locator('[data-component="modal:Connect a Dummy Processor"]');

// Close modal (cross icon)
page.locator('[data-icon="cross-outline"]');
```

### Toasts & Notifications

```javascript
// Success toast
page.locator('[data-toast="Connector Created Successfully!"]');
page.locator('[data-toast="Successfully Created a new Configuration !"]');
page.locator('[data-toast="Successfully Activated !"]');

// Info toast
page.locator('[data-toast="Please check your registered e-mail"]');

// Error toast
page.locator('[data-toast="Forgot Password Failed, Try again"]');
page.locator('[data-toast="Incorrect email or password"]');

// Password change success
page.locator('[data-toast="Password Changed Successfully"]');
```

---

## Search & Filters

### Global Search

```javascript
// Global search input
page.locator('[class="w-max"]');
```

### Page-Specific Search

```javascript
// Payment operations search
page.locator('[name="name"]');

// Connector search
page.locator('[data-testid="search-processor"]');

// Search with placeholder containing text
page.locator('input[placeholder*="Search for payment ID or refund ID"]');
```

### Date Range Selector

```javascript
// Date range dropdown
page.locator('[data-testid="date-range-selector"]');

// Predefined options
page.locator('[data-date-picker-predefined="predefined-options"]');

// Apply button
page.locator('[data-button-text="Apply"]');
```

### Filter Components

```javascript
// Add filters button
page.locator('[data-icon="plus"]');

// Filter menu items
page.locator(".mr-5.text-left").getByText("Connector");
page.locator(".mr-5.text-left").getByText("Status");
page.locator(".mr-5.text-left").getByText("Currency");
page.locator(".mr-5.text-left").getByText("Customer Id");

// Filter dropdown wrapper
page.locator('[class="flex relative  flex-row  flex-wrap"]');
```

### Column Customization

```javascript
// Column button (custom icon)
page.locator('[data-button-for="CustomIcon"]');

// Table heading by column name
page.locator('[data-table-heading="ColumnName"]');

// Dropdown value selector
page.locator('[data-dropdown-value="ColumnName"]');
```

---

## Tables & Data Grids

### Table Location Pattern

Tables use `data-table-location` attribute with format: `{TableName}_tr{row}_td{col}`

```javascript
// Orders table cells
page.locator('[data-table-location="Orders_tr1_td1"]'); // Row 1, Cell 1
page.locator('[data-table-location="Orders_tr1_td2"]'); // Row 1, Cell 2
page.locator('[data-table-location="Orders_tr1_td3"]'); // Row 1, Cell 3
// ... up to td11

// Refunds table
page.locator('[data-table-location="Refunds_tr1_td1"]');

// Attempts table
page.locator('[data-table-location="Attempts_tr1_td1"]');

// Customers table
page.locator('[data-table-location="Customers_tr1_td1"]');

// History table
page.locator('[data-table-location="History_tr1_td2"]');

// Payouts table
page.locator('[data-table-location="Payouts_tr1_td1"]');
```

### Table Headings

```javascript
// Table headers
page.locator('[data-table-heading="Title"]');

// Table heading with title attribute
page.locator('[data-table-heading-title="Title"]');

// Table heading description
page.locator('[data-table-heading-desc="Description"]');
```

### Table Interactions

```javascript
// Click first row cell to expand details
await page.locator('[data-table-location="Orders_tr1_td1"]').click();

// Expandable table
page.locator('table[data-expandable-table="Refunds"]');

// Table row expanded state
page.locator('[data-table-row-expanded="1"]');
```

### Generic Table Selectors

```javascript
// Table headers
page.locator("table thead tr th");

// Table rows
page.locator("table tbody tr");

// Specific header by index
page.locator("table thead tr th").nth(i);

// Cell by index
page.locator("table tbody tr").nth(rowIndex).locator("td").nth(colIndex);
```

---

## Module-Specific Navigation

### Payment Operations (`/dashboard/payments`)

#### Key Elements

```javascript
// Transaction view cards container
page.locator(
  '[class="grid lg:grid-cols-5 md:grid-cols-4 sm:grid-cols-3 grid-cols-2 gap-6 mb-8"]',
);

// View dropdown
page.locator('[class="flex h-fit rounded-lg hover:bg-opacity-80"]');

// Generate reports button
page.locator('[data-button-for="generateReports"]');

// Search for previous 90 days button
page.locator('[data-button-for="expandTheSearchToThePrevious90Days"]');

// Payment ID copy button
page.locator('[class="fill-current cursor-pointer opacity-70 h-7 py-1"]');
```

#### Refund Action

```javascript
// Initiate refund button
page.locator('[data-button-text="+ Refund"]');

// Amount input
page.locator('[name="amount"]');

// Initiate refund submit
page.locator('[data-button-text="Initiate Refund"]');
```

### Payment Connectors (`/dashboard/connectors`)

```javascript
// Page heading
page.locator('[class="flex items-center gap-4 "]');

// Page banner
page.locator('[class="flex flex-col gap-2.5"]');

// Connect now button
page.locator('[data-button-for="connectNow"]');

// Stripe dummy connector
page.locator('[data-testid="stripe_test"]');

// Connect and proceed
page.locator("[data-button-for=connectAndProceed]");

// Payment method checkboxes
page.locator("[data-testid=credit_select_all]");
page.locator("[data-testid=credit_mastercard]");
page.locator("[data-testid=debit_cartesbancaires]");
page.locator("[data-testid=pay_later_klarna]");
page.locator("[data-testid=wallet_we_chat_pay]");

// Connector label input
page.locator("[name=connector_label]");

// API key input
page.locator("[name=connector_account_details\\.api_key]");
```

### Payment Routing (`/dashboard/routing`)

```javascript
// Volume-based routing setup
page.locator('[data-button-for="setup"]').nth(0);

// Rule-based routing setup
page.locator('[data-button-for="setup"]').nth(1);

// Default fallback manage
page.locator('[data-button-for="manage"]').nth(0);

// Configuration name input
page.locator('[placeholder="Enter Configuration Name"]');

// Connector dropdown
page.locator('[data-value="addProcessors"]');

// Configure rule button
page.locator('[data-button-for="configureRule"]');

// Save rule button
page.locator('[data-button-for="saveRule"]');

// Save and activate button
page.locator('[data-button-for="saveAndActivateRule"]');

// Active indicator
page.locator('[data-icon="check"]').first();
```

### Payment Settings (`/dashboard/payment-settings`)

#### Tabs

```javascript
page.locator("text=Payment Behaviour");
page.locator("text=3DS");
page.locator("text=Custom Headers");
page.locator("text=Metadata Headers");
page.locator("text=Payment Link");
```

#### Toggles

```javascript
page.getByText("Collect billing details from wallets");
page.getByText("Collect shipping details from wallets");
page.getByText("Auto Retries", { exact: true });
page.getByText("Manual Retries", { exact: true });
page.getByText("Extended Authorization", { exact: true });
page.getByText("Always Enable Overcapture", { exact: true });
page.getByText("Network Tokenization", { exact: true });
page.getByText("Click to Pay", { exact: true });
page.getByText("Force 3DS Challenge");
```

### API Keys (`/dashboard/developer-api-keys`)

```javascript
// Create new API key button
page.getByRole("button", { name: "Create New API Key" });

// Name input
page.locator('input[name="name"]');

// Description input
page.locator('input[name="description"]');

// Create button
page.getByRole("button", { name: "Create", exact: true });

// Download button
page.getByRole("button", { name: "Download the key" });

// Delete icon
page.locator('[data-icon="delete"]');
```

### Users (`/dashboard/users`)

```javascript
// Invite users button
page.locator('[data-button-for="inviteUsers"]');

// Email list input
page.locator('[name="email_list"]');

// Send invite button
page.locator('[data-button-for="sendInvite"]');
```

---

## Common Page Layout Elements

### Labels and Data Display

```javascript
// Data labels
page.locator('[data-label="Created"]');
page.locator('[data-label="Last Updated"]');
page.locator('[data-label="Amount Received"]');
page.locator('[data-label="Payment ID"]');
page.locator('[data-label="Profile Id"]');
page.locator('[data-label="Profile Name"]');
page.locator('[data-label="Payment connector"]');
page.locator('[data-label="Connector Label"]');
page.locator('[data-label="Payment Method"]');
page.locator('[data-label="Payment Method Type"]');
page.locator('[data-label="Auth Type"]');
page.locator('[data-label="Card Network"]');
page.locator('[data-label="Error Message"]');
page.locator('[data-label="Transaction Flow"]');
page.locator('[data-label="Message"]');
page.locator('[data-label="Tag"]');
page.locator('[data-label="INACTIVE"]');
```

### Sections

```javascript
// Flex columns
page.locator('[class="flex flex-col gap-4"]').nth(0);
page.locator('[class="flex flex-col gap-4"]').nth(1);

// Font bold headings
page.locator('[class="font-bold text-lg mb-5"]').nth(0);

// Large text display
page.locator('[class="md:text-5xl font-bold"]');

// Section headers
page.getByText("Summary");
page.getByText("Events and logs");
page.getByText("Customer Details");
page.getByText("More Payment Details");
page.getByText("Payment Method Details");
page.getByText("Payment Metadata");
page.getByText("FRM Details");
```

---

## Quick Reference: Common Actions

### Login Flow

```javascript
// Standard login
await page.goto("/");
await page.getByPlaceholder("Enter your Email").fill(email);
await page.getByPlaceholder("Enter your Password").fill(password);
await page.locator('[data-button-for="continue"]').click();
await page.locator('[data-testid="skip-now"]').click(); // Skip 2FA
await expect(page).toHaveURL(/.*dashboard\/home/);
```

### Navigate via Sidebar

```javascript
// Operations > Payments
await page.locator("[data-testid=operations]").click();
await page.locator("[data-testid=payments]").click();

// Connectors > Payment Processors
await page.locator("[data-testid=connectors]").click();
await page.locator("[data-testid=paymentprocessors]").click();
```

### Perform Search

```javascript
await page.locator('[name="name"]').fill("search term");
await page.keyboard.press("Enter");
```

### Apply Filter

```javascript
await page.locator('[data-icon="plus"]').click();
await page.locator(".mr-5.text-left").getByText("Connector").click();
await page.locator('[value="Stripe Dummy"]').click();
await page.locator('[data-button-text="Apply"]').click();
```

### Create Connector

```javascript
await page.locator("[data-testid=connectors]").click();
await page.locator("[data-testid=paymentprocessors]").click();
await page.locator("[data-button-for=connectNow]").click({ force: true });
await page
  .locator('[data-testid="stripe_test"]')
  .locator("button")
  .click({ force: true });
await page
  .locator("[name=connector_account_details\\.api_key]")
  .fill("dummy_api_key");
await page.locator("[data-button-for=connectAndProceed]").click();
await page.locator("[data-button-for=proceed]").click();
await page.locator("[data-button-for=done]").click();
```

### Process Refund

```javascript
await page.locator('[data-table-location="Orders_tr1_td1"]').click();
await page.locator('[data-button-text="+ Refund"]').click();
await page.locator('[name="amount"]').fill("12.34");
await page.locator('[data-button-text="Initiate Refund"]').click();
```

---

## URL Patterns

| Module                | URL Pattern                              |
| --------------------- | ---------------------------------------- |
| Login                 | `/` or `/login`                          |
| Register              | `/register`                              |
| Forgot Password       | `/dashboard/forget-password`             |
| Home                  | `/dashboard/home`                        |
| Home V2               | `/dashboard/v2/home`                     |
| Users                 | `/dashboard/users`                       |
| Payments              | `/dashboard/payments`                    |
| Refunds               | `/dashboard/refunds`                     |
| Disputes              | `/dashboard/disputes`                    |
| Payouts               | `/dashboard/payouts`                     |
| Customers             | `/dashboard/customers`                   |
| Payment Processors    | `/dashboard/connectors`                  |
| Payout Processors     | `/dashboard/payoutconnectors`            |
| 3DS Authenticators    | `/dashboard/3ds-authenticators`          |
| Fraud Risk            | `/dashboard/fraud-risk-management`       |
| PM Auth               | `/dashboard/pm-authentication-processor` |
| Tax                   | `/dashboard/tax-processor`               |
| Billing               | `/dashboard/billing-processor`           |
| Vault                 | `/dashboard/vault-processor`             |
| Analytics - Payments  | `/dashboard/analytics-payments`          |
| Analytics - Refunds   | `/dashboard/analytics-refunds`           |
| Routing               | `/dashboard/routing`                     |
| Surcharge             | `/dashboard/surcharge`                   |
| 3DS                   | `/dashboard/3ds`                         |
| Payout Routing        | `/dashboard/payoutrouting`               |
| 3DS Exemption         | `/dashboard/3ds-exemption`               |
| Vault Onboarding      | `/dashboard/vault-onboarding`            |
| Vault Customers       | `/dashboard/vault-customers-tokens`      |
| Payment Settings      | `/dashboard/payment-settings`            |
| API Keys              | `/dashboard/developer-api-keys`          |
| Webhooks              | `/dashboard/webhooks`                    |
| Configure PMTs        | `/dashboard/configure-pmts`              |
| Organization Settings | `/dashboard/organization-settings`       |

---

## Tips for MCP Navigation

1. **Always wait for elements**: Use `{ timeout: 10000 }` for potentially slow-loading elements
2. **Skip 2FA in test flows**: Click `[data-testid="skip-now"]` after login
3. **Use force click for modals**: Some elements need `{ force: true }`
4. **Route interception**: Use `page.route()` for mocking API responses
5. **Iframe handling**: SDK elements are in iframes - use `page.frameLocator("iframe").first()`

---

_Generated from Playwright test suite analysis - For use with Playwright MCP exploration_
