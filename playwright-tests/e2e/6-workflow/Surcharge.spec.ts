import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Surcharge } from "../../support/pages/workflow/Surcharge";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createSurchargeAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const setFeatureFlag = async (page: Page, surcharge: boolean) => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features = { ...json.features, surcharge };
    await route.fulfill({ response, json });
  });
};

const goToSurcharge = async (page: Page, homePage: HomePage) => {
  await homePage.workflow.click();
  await homePage.surchargeRouting.click();
  await page.waitForURL(/dashboard\/surcharge/, { timeout: 15000 });
};

// Per-test handle to the email of the currently signed-in user; populated in
// beforeEach so individual tests can pass it to createSurchargeAPI without
// re-fetching from the page.
let currentEmail: string;

test.describe("Surcharge", () => {
  test.beforeEach(async ({ page }) => {
    currentEmail = generateUniqueEmail();
    await signupUser(currentEmail, PLAYWRIGHT_PASSWORD);
    await loginUI(page, currentEmail, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  test.describe("Sidebar / Feature flag", () => {
    test("should expose the Surcharge menu under Workflows when surcharge flag is ON", async ({ page }) => {
      const homePage = new HomePage(page);
      await setFeatureFlag(page, true);
      await page.reload();

      await homePage.workflow.click();
      await expect(homePage.surchargeRouting).toBeVisible();
    });

    test("should hide the Surcharge menu when surcharge flag is OFF", async ({ page }) => {
      const homePage = new HomePage(page);
      await setFeatureFlag(page, false);
      await page.reload();

      await homePage.workflow.click();
      await expect(homePage.surchargeRouting).toHaveCount(0);
    });
  });

  test.describe("List view (LANDING)", () => {
    test("should show the empty state and Create New button when no rule exists", async ({ page }) => {
      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      // Fresh signup → no active surcharge rule on this merchant.
      await goToSurcharge(page, homePage);

      await expect(surcharge.pageHeading).toBeVisible();
      await expect(surcharge.pageSubtitle).toBeVisible();
      await expect(surcharge.emptyStateHeading).toBeVisible();
      await expect(surcharge.createNewButton).toBeVisible();
    });

    test("should display the active rule card with name and ACTIVE badge", async ({ page, context }) => {
      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      // Description is dashboard-only metadata — buildSurchargePayloadBody
      // strips it before PUT, so the backend never persists it. Asserting
      // on name only.
      const { name } = await createSurchargeAPI(page, context.request, {
        name: "playwright_card_surcharge",
      });

      await goToSurcharge(page, homePage);

      await expect(surcharge.activeBadge).toBeVisible();
      // ActiveRulePreview runs name through capitalizeString.
      await expect(page.getByText(name.charAt(0).toUpperCase() + name.slice(1))).toBeVisible();
      await expect(surcharge.editIcon).toBeVisible();
      await expect(surcharge.deleteIcon).toBeVisible();
    });

    test("Edit icon switches the page into the form (pageView = NEW)", async ({ page, context }) => {
      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      await createSurchargeAPI(page, context.request);
      await goToSurcharge(page, homePage);

      await surcharge.editIcon.click();

      await expect(surcharge.ruleNameInput).toBeVisible();
      await expect(surcharge.saveButton).toBeVisible();
      await expect(surcharge.cancelFormButton.first()).toBeVisible();
    });

    test("Delete icon opens the confirmation popup and removes the rule on Confirm", async ({ page, context }) => {
      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      await createSurchargeAPI(page, context.request);
      await goToSurcharge(page, homePage);

      await surcharge.deleteIcon.click();

      // Popup body (Surcharge.res:33–41).
      await expect(surcharge.deleteConfirmHeading).toBeVisible();
      await expect(surcharge.deleteConfirmDescription).toBeVisible();
      await expect(surcharge.confirmButton).toBeVisible();

      const deleteRequest = page.waitForRequest(
        (req) => /routing\/decision\/surcharge(\?|$)/.test(req.url()) && req.method() === "DELETE",
      );
      await surcharge.confirmButton.click();
      await deleteRequest;

      await expect(page.getByText(/Successfully deleted current active surcharge rule/)).toBeVisible();
      // After delete the page swaps back to the empty-state branch.
      await expect(surcharge.emptyStateHeading).toBeVisible();
      await expect(surcharge.createNewButton).toBeVisible();
    });
  });

  test.describe("Save flow", () => {
    test("Save fires PUT /routing/decision/surcharge and shows the success toast", async ({ page, context }) => {
      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      // Seed a valid rule so Edit lands the form with all required fields
      // filled in (the wasm validator passes and Save is enabled).
      await createSurchargeAPI(page, context.request, { name: "playwright_save_rule" });
      await goToSurcharge(page, homePage);
      await surcharge.editIcon.click();

      await expect(surcharge.saveButton).toBeVisible();
      await expect(surcharge.saveButton).toBeEnabled();

      const putRequest = page.waitForRequest(
        (req) =>
          /routing\/decision\/surcharge(\?|$)/.test(req.url()) &&
          req.method() === "PUT",
      );
      await surcharge.saveButton.click();
      await putRequest;

      await expect(page.getByText("Saved successfully!")).toBeVisible();
    });
  });

  test.describe("Rule list create", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      await goToSurcharge(page, homePage);
      await surcharge.createNewButton.click();
      await page.waitForLoadState("networkidle");
    });

    test("should render all elements in surcharge create page", async ({ page }) => {
      const surcharge = new Surcharge(page);

      // Page header
      await expect(surcharge.pageHeading).toBeVisible();
      await expect(surcharge.pageSubtitle).toBeVisible();

      // Configuration Name section — the default value is `Surcharge -<YYYY-MM-DD>`
      // built from the browser's `Date`. Match today/yesterday so the midnight
      // boundary doesn't flake (same guard as the volume-routing test).
      await expect(page.getByText("Configuration Name", { exact: false }).first()).toBeVisible();
      const [today, yesterday] = await page.evaluate(() => {
        const fmt = (d: Date) => d.toLocaleDateString("en-CA");
        const t = new Date();
        const y = new Date(t);
        y.setDate(y.getDate() - 1);
        return [fmt(t), fmt(y)];
      });
      await expect(surcharge.ruleNameInput).toHaveValue(new RegExp(`^Surcharge -(${today}|${yesterday})$`));

      // Surcharge section heading + helper copy
      await expect(page.getByText("Configure Advanced Rules to apply surcharges", { exact: true })).toBeVisible();
      await expect(surcharge.configureSurchargeBlock).toBeVisible();
      await expect(page.getByText("If payment_method = card && amount > 50000, apply 5% or 2500 surcharge.", { exact: true })).toBeVisible();
      await expect(page.getByText(/Ensure to enter the payment amount and surcharge fixed amount in the smallest currency unit/)).toBeVisible();
      await expect(page.getByText(/pass 100 to charge \$1\.00 \(USD\) and ¥100 \(JPY\) since ¥ is a zero-decimal currency/)).toBeVisible();

      // Rule 1 conditions — defaultStatements seeds `amount EQUAL TO <empty>`
      // and `currency IS <empty>`, so the value cells render as the numeric
      // placeholder ("Enter value") and the enum picker ("Select Value").
      await expect(surcharge.ruleHeading).toBeVisible();
      await expect(page.getByRole("button", { name: "amount" })).toBeVisible();
      await expect(page.getByRole("button", { name: "EQUAL TO" })).toBeVisible();
      await expect(page.getByPlaceholder("Enter value").first()).toBeVisible();
      await expect(page.getByRole("button", { name: "currency" })).toBeVisible();
      await expect(page.getByRole("button", { name: "IS" })).toBeVisible();
      await expect(surcharge.selectValueButton.first()).toBeVisible();
      // LogicalOps renders both AND/OR toggles for non-first conditions.
      await expect(page.getByText("AND", { exact: true }).first()).toBeVisible();
      await expect(page.getByText("OR", { exact: true }).first()).toBeVisible();

      // Surcharge type block — type defaults to "rate" and both value fields
      // (surcharge + tax) seed at 0.
      await expect(page.getByText("Surcharge is", { exact: true })).toBeVisible();
      await expect(page.getByRole("button", { name: "Rate" })).toBeVisible();
      await expect(page.getByText("Tax on Surcharge", { exact: true })).toBeVisible();
      await expect(surcharge.surchargeValueInput("percentage")).toHaveValue("0");
      await expect(surcharge.taxOnSurchargeInput).toHaveValue("0");

      // Form actions
      await expect(surcharge.saveButton).toBeVisible();
      await expect(surcharge.cancelFormButton.first()).toBeVisible();

      // Rule actions: Add + Copy are always shown; Drag/Delete only render
      // when notFirstRule = true (i.e., a second rule has been added).
      await expect(surcharge.addRuleButton).toBeVisible();
      await expect(surcharge.copyRuleButton).toBeVisible();
      await expect(surcharge.dragRuleHandle).toHaveCount(0);
      await expect(surcharge.deleteRuleButton).toHaveCount(0);
    });

    test("should expose drag handle and delete once a second rule exists", async ({ page }) => {
      const surcharge = new Surcharge(page);

      await surcharge.addRuleButton.click();

      await expect(surcharge.ruleHeadingByIndex(2)).toBeVisible();
      await expect(surcharge.dragRuleHandle).toBeVisible();
      await expect(surcharge.deleteRuleButton).toBeVisible();
    });

    test("Add button appends a new rule row", async ({ page }) => {
      const surcharge = new Surcharge(page);

      await expect(surcharge.ruleHeadingByIndex(1)).toBeVisible();
      await expect(surcharge.ruleHeadingByIndex(2)).toHaveCount(0);

      await surcharge.addRuleButton.click();

      await expect(surcharge.ruleHeadingByIndex(2)).toBeVisible();
    });

    test("Delete button removes a rule row", async ({ page }) => {
      const surcharge = new Surcharge(page);

      await surcharge.addRuleButton.click();
      await expect(surcharge.ruleHeadingByIndex(2)).toBeVisible();

      await surcharge.deleteRuleButton.click();

      await expect(surcharge.ruleHeadingByIndex(2)).toHaveCount(0);
      await expect(surcharge.ruleHeadingByIndex(1)).toBeVisible();
    });

    test("Copy button clones the rule into a new row", async ({ page }) => {
      const surcharge = new Surcharge(page);

      await expect(surcharge.ruleHeadingByIndex(2)).toHaveCount(0);

      await page.getByRole('textbox', { name: 'Enter value' }).fill("50000");
      await surcharge.copyRuleButton.click();
      await expect(surcharge.ruleHeadingByIndex(2)).toBeVisible();
      await expect(page.getByPlaceholder('Enter value').nth(1)).toHaveValue("50000");
    });

    test("Add Condition renders a row with Select Field, Operator and Value", async ({ page }) => {
      const surcharge = new Surcharge(page);

      // Default form seeds two conditions (amount, currency) with lhs/operator
      // pre-filled, so the empty Select buttons only appear after the user
      // clicks the condition-row plus.
      await expect(surcharge.selectFieldButton).toHaveCount(0);

      await surcharge.addConditionRowButton.click();

      await expect(surcharge.selectFieldButton).toBeVisible();
      await expect(surcharge.selectOperatorButton).toBeVisible();
      await expect(surcharge.selectValueButton).toBeVisible();
    });

    test("switching between Rate and Fixed swaps the value field to amount and percentage input", async ({ page }) => {
      const surcharge = new Surcharge(page);

      await surcharge.selectSurchargeTypeButton.click();
      await surcharge.surchargeTypeOption("Fixed").click();

      await expect(surcharge.surchargeValueInput("amount")).toBeVisible();
      await expect(surcharge.surchargeValueInput("percentage")).toHaveCount(0);

      await surcharge.selectSurchargeTypeButton.click();
      await surcharge.surchargeTypeOption("Rate").click();

      await expect(surcharge.surchargeValueInput("percentage")).toBeVisible();
      await expect(surcharge.surchargeValueInput("amount")).toHaveCount(0);
    });

    test("should fill the form, save the rule, and preview it on /surcharge", async ({ page }) => {
      const surcharge = new Surcharge(page);
      const ruleName = "Playwright surcharge config";

      // 1. Overwrite the auto-generated `Surcharge -<date>` name.
      await surcharge.ruleNameInput.clear();
      await surcharge.ruleNameInput.fill(ruleName);

      // 2. Fill the first condition's numeric value (amount EQUAL TO 50000).
      await page.getByPlaceholder("Enter value").first().fill("50000");

      // 3. Pick a currency for the second condition (currency IS USD).
      await surcharge.selectValueButton.first().click();
      await surcharge.dropdownOption("USD", 4).click();

      // 4. Surcharge rate must be > 0 and <= 100 to satisfy validateSurchargeRate.
      await surcharge.surchargeValueInput("percentage").fill("5");

      // 5. Tax on surcharge — non-zero so the preview's compressed view
      // shows a meaningful value.
      await surcharge.taxOnSurchargeInput.fill("1");

      // 6. Save and wait for the PUT to land before assertions.
      const putRequest = page.waitForRequest((req) => /routing\/decision\/surcharge(\?|$)/.test(req.url()) && req.method() === "PUT");
      await surcharge.saveButton.click();
      await putRequest;

      // 7. Page redirects back to /surcharge with the ActiveRulePreview card.
      await expect(page.getByText("Saved successfully!")).toBeVisible();
      await expect(page).toHaveURL(/dashboard\/surcharge$/);

      // ActiveRulePreview card metadata.
      await expect(surcharge.activeBadge).toBeVisible();
      // capitalizeString only uppercases the first character, so a name that
      // already starts uppercase renders verbatim.
      await expect(page.getByText(ruleName, { exact: true })).toBeVisible();
      await expect(surcharge.editIcon).toBeVisible();
      await expect(surcharge.deleteIcon).toBeVisible();

      // RulePreviewer body — one rule with two statements rendered as
      // <field> <operator> <value> tokens, separated by the AND/OR logical.
      const previewer = page.locator('[data-component="rulePreviewer"]');
      await expect(previewer).toBeVisible();
      await expect(previewer.getByText("Rule 1", { exact: true })).toBeVisible();
      await expect(previewer.getByText("amount", { exact: true })).toBeVisible();
      // getOperatorFromComparisonType maps `equal` + number -> "EQUAL TO",
      // and `equal` + enum_variant -> "IS" (AdvancedRoutingUtils.res:340).
      await expect(previewer.getByText("EQUAL TO", { exact: true })).toBeVisible();
      await expect(previewer.getByText("50000", { exact: true })).toBeVisible();
      await expect(previewer.getByText("AND", { exact: true })).toBeVisible();
      await expect(previewer.getByText("currency", { exact: true })).toBeVisible();
      await expect(previewer.getByText("IS", { exact: true })).toBeVisible();
      await expect(previewer.getByText("USD", { exact: true })).toBeVisible();

      // SurchargeCompressedView concatenates `${type} -> ${value} | Tax on
      // Surcharge -> ${percentage}` and runs the whole string through
      // capitalizeString, so "rate" becomes "Rate".
      await expect(previewer.getByText("Rate -> 5 | Tax on Surcharge -> 1", { exact: true })).toBeVisible();
    });

  });
});
