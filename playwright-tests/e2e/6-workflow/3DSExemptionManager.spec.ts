import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { ThreeDSExemptionManager } from "../../support/pages/workflow/ThreeDSExemptionManager";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createThreeDsExemptionAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// FeatureFlagUtils.res reads `threeds_exemption` off the dashboard config —
// not the existing spec's `threeds_exemption_manager`. Keep the key in sync
// with FeatureFlagUtils.res.js:57 so the FF actually flips.
const setFeatureFlag = async (page: Page, threeds_exemption: boolean) => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features = { ...(json.features ?? {}), threeds_exemption };
    await route.fulfill({ response, json });
  });
};

const goToExemption = async (page: Page, homePage: HomePage) => {
  await homePage.workflow.click();
  await homePage.threeDSExemptionManager.click();
  await page.waitForURL(/dashboard\/3ds-exemption/, { timeout: 15000 });
};

// Per-test handle to the email of the currently signed-in user; populated in
// beforeEach so individual tests can pass it to createThreeDsExemptionAPI
// without re-fetching from the page.
let currentEmail: string;

test.describe("3DS Exemption Manager", () => {
  test.beforeEach(async ({ page }) => {
    // Register the FF mock BEFORE loginUI navigates so the initial fetch of
    // `/dashboard/config/feature` returns threeds_exemption=true. Playwright
    // tries route handlers in reverse-registration order, so per-test routes
    // (e.g. the FF-off test) can still override this default.
    await setFeatureFlag(page, true);

    currentEmail = generateUniqueEmail();
    await signupUser(currentEmail, PLAYWRIGHT_PASSWORD);
    await loginUI(page, currentEmail, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  test.describe("Sidebar / Feature flag", () => {
    test("should expose the 3DS Exemption menu under Workflows when threeds_exemption flag is ON", async ({
      page,
    }) => {
      const homePage = new HomePage(page);

      await homePage.workflow.click();
      await expect(homePage.threeDSExemptionManager).toBeVisible();
    });

    test("should hide the 3DS Exemption menu when threeds_exemption flag is OFF", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      await setFeatureFlag(page, false);
      await page.reload();

      await homePage.workflow.click();
      await expect(homePage.threeDSExemptionManager).toHaveCount(0);
    });
  });

  test.describe("List view (LANDING)", () => {
    test("should show the empty state and Create New button when no rule exists", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      // Fresh signup → no active 3DS exemption rule on this merchant.
      await goToExemption(page, homePage);

      await expect(exemption.pageHeading).toBeVisible();
      await expect(exemption.pageSubtitle).toBeVisible();
      await expect(exemption.configureSectionHeading).toBeVisible();
      await expect(exemption.createNewButton).toBeVisible();
    });

    test("should display the active rule card with name and ACTIVE badge", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      const { name } = await createThreeDsExemptionAPI(page, context.request, {
        name: "playwright_card_3ds_exemption",
      });

      await goToExemption(page, homePage);

      await expect(exemption.activeBadge).toBeVisible();
      // ActiveRulePreview runs name through capitalizeString.
      await expect(
        page.getByText(name.charAt(0).toUpperCase() + name.slice(1)),
      ).toBeVisible();
      await expect(exemption.deleteIcon).toBeVisible();
    });

    test("Delete icon opens the confirmation popup and removes the rule on Confirm", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      await createThreeDsExemptionAPI(page, context.request);
      await goToExemption(page, homePage);

      await exemption.deleteIcon.click();

      // Popup body (HSwitchThreeDsExemption.res:48-56).
      await expect(exemption.deleteConfirmHeading).toBeVisible();
      await expect(exemption.deleteConfirmDescription).toBeVisible();
      await expect(exemption.confirmButton).toBeVisible();

      const deleteRequest = page.waitForRequest(
        (req) =>
          /routing\/deactivate(\?|$)/.test(req.url()) &&
          req.method() === "POST",
      );
      await exemption.confirmButton.click();
      await deleteRequest;

      await expect(
        page.getByText(/Successfully deleted active 3ds exemption rule/),
      ).toBeVisible();
      // After delete the page swaps back to the empty-state branch.
      await expect(exemption.configureSectionHeading).toBeVisible();
      await expect(exemption.createNewButton).toBeVisible();
    });

    test("Create New on top of an existing rule opens the override-warning modal", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      await createThreeDsExemptionAPI(page, context.request);
      await goToExemption(page, homePage);

      await exemption.createNewButton.click();

      // handleCreateNew shows the override popup only when initialRule is Some
      // (HSwitchThreeDsExemption.res:339-358).
      await expect(exemption.overrideWarningHeading).toBeVisible();
      await expect(exemption.overrideWarningDescription).toBeVisible();
    });
  });

  test.describe("Rule list create", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      await goToExemption(page, homePage);
      await exemption.createNewButton.click();
      await page.waitForLoadState("networkidle");
    });

    test("should render all elements in 3DS exemption create page", async ({
      page,
    }) => {
      const exemption = new ThreeDSExemptionManager(page);

      // Page header
      await expect(exemption.pageHeading).toBeVisible();
      await expect(exemption.pageSubtitle).toBeVisible();

      // Configuration Name section — the default value is `3DS Rule-<YYYY-MM-DD>`
      // built from the browser's `Date`. Match today/yesterday so the midnight
      // boundary doesn't flake (same guard as the surcharge test).
      await expect(
        page.getByText("Configuration Name", { exact: false }).first(),
      ).toBeVisible();
      const [today, yesterday] = await page.evaluate(() => {
        const fmt = (d: Date) => d.toLocaleDateString("en-CA");
        const t = new Date();
        const y = new Date(t);
        y.setDate(y.getDate() - 1);
        return [fmt(t), fmt(y)];
      });
      await expect(exemption.ruleNameInput).toHaveValue(
        new RegExp(`^3DS Rule-(${today}|${yesterday})$`),
      );

      // Rule based configuration helper block (HSwitchThreeDsExemption.res:370-393)
      await expect(
        page.getByText("Rule Based Configuration", { exact: true }),
      ).toBeVisible();
      await expect(page.getByText(/For example:/).first()).toBeVisible();
      await expect(
        page.getByText(
          /If amount is > 100 and currency is USD, enforce 3DS authentication/,
        ),
      ).toBeVisible();
      await expect(
        page.getByText(
          /Ensure to enter the payment amount in the smallest currency unit/,
        ),
      ).toBeVisible();

      // Rule 1 conditions — defaultStatements seeds `amount EQUAL TO <empty>`
      // and `currency IS <empty>`, so the value cells render as the numeric
      // placeholder ("Enter value") and the enum picker ("Select Value").
      await expect(exemption.ruleHeading).toBeVisible();
      await expect(page.getByRole("button", { name: "amount" })).toBeVisible();
      await expect(
        page.getByRole("button", { name: "EQUAL TO" }),
      ).toBeVisible();
      await expect(page.getByPlaceholder("Enter value").first()).toBeVisible();
      await expect(
        page.getByRole("button", { name: "currency" }),
      ).toBeVisible();
      await expect(page.getByRole("button", { name: "IS" })).toBeVisible();
      await expect(exemption.selectValueButton.first()).toBeVisible();
      // LogicalOps renders both AND/OR toggles for non-first conditions.
      await expect(
        page.getByText("AND", { exact: true }).first(),
      ).toBeVisible();
      await expect(page.getByText("OR", { exact: true }).first()).toBeVisible();

      // Auth type block (Add3DSConditionForThreeDsExemption — AdvancedRouting.res:48-93)
      await expect(
        page.getByText("Auth type", { exact: true }).first(),
      ).toBeVisible();
      await expect(
        page.getByText("= (is equal to)", { exact: true }).first(),
      ).toBeVisible();
      await expect(exemption.authTypeDropdown).toBeVisible();

      // Form actions
      await expect(exemption.saveButton).toBeVisible();
      await expect(exemption.cancelFormButton.first()).toBeVisible();

      // Rule actions: Add + Copy are always shown; Drag/Delete only render
      // when notFirstRule = true (i.e., a second rule has been added).
      await expect(exemption.addRuleButton).toBeVisible();
      await expect(exemption.copyRuleButton).toBeVisible();
      await expect(exemption.dragRuleHandle).toHaveCount(0);
      await expect(exemption.deleteRuleButton).toHaveCount(0);
    });

    test("should expose drag handle and delete once a second rule exists", async ({
      page,
    }) => {
      const exemption = new ThreeDSExemptionManager(page);

      await exemption.addRuleButton.click();

      await expect(exemption.ruleHeadingByIndex(2)).toBeVisible();
      await expect(exemption.dragRuleHandle).toBeVisible();
      await expect(exemption.deleteRuleButton).toBeVisible();
    });

    test("Add button appends a new rule row", async ({ page }) => {
      const exemption = new ThreeDSExemptionManager(page);

      await expect(exemption.ruleHeadingByIndex(1)).toBeVisible();
      await expect(exemption.ruleHeadingByIndex(2)).toHaveCount(0);

      await exemption.addRuleButton.click();

      await expect(exemption.ruleHeadingByIndex(2)).toBeVisible();
    });

    test("Delete button removes a rule row", async ({ page }) => {
      const exemption = new ThreeDSExemptionManager(page);

      await exemption.addRuleButton.click();
      await expect(exemption.ruleHeadingByIndex(2)).toBeVisible();

      await exemption.deleteRuleButton.click();

      await expect(exemption.ruleHeadingByIndex(2)).toHaveCount(0);
      await expect(exemption.ruleHeadingByIndex(1)).toBeVisible();
    });

    test("Copy button clones the rule into a new row", async ({ page }) => {
      const exemption = new ThreeDSExemptionManager(page);

      await expect(exemption.ruleHeadingByIndex(2)).toHaveCount(0);

      await page.getByRole("textbox", { name: "Enter value" }).fill("100");
      await exemption.copyRuleButton.click();
      await expect(exemption.ruleHeadingByIndex(2)).toBeVisible();
      await expect(page.getByPlaceholder("Enter value").nth(1)).toHaveValue(
        "100",
      );
    });

    test("Add Condition renders a row with Select Field, Operator and Value", async ({
      page,
    }) => {
      const exemption = new ThreeDSExemptionManager(page);

      // Default form seeds two conditions (amount, currency) with lhs/operator
      // pre-filled and one auth-type "Select Field" dropdown, so initially
      // there's exactly one Select Field button on the page.
      await expect(exemption.selectFieldButton).toHaveCount(1);

      await exemption.addConditionRowButton.click();

      await expect(exemption.selectFieldButton).toHaveCount(2);
      await expect(exemption.selectOperatorButton).toBeVisible();
      await expect(exemption.selectValueButton.last()).toBeVisible();
    });
  });

  test.describe("Auth type (override_3ds) selection", () => {
    // Source of truth: AdvancedRouting.res:48-93 options list.
    const authTypeOptions: { label: string; value: string }[] = [
      { label: "Request No-3DS", value: "no_three_ds" },
      { label: "Mandate 3DS Challenge", value: "challenge_requested" },
      { label: "Prefer 3DS Challenge", value: "challenge_preferred" },
      {
        label: "Request 3DS Exemption, Type: TRA",
        value: "three_ds_exemption_requested_tra",
      },
      {
        label: "Request 3DS Exemption, Type: Low Value Transaction",
        value: "three_ds_exemption_requested_low_value",
      },
      {
        label: "No challenge requested",
        value: "issuer_three_ds_exemption_requested",
      },
    ];

    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      await goToExemption(page, homePage);
      await exemption.createNewButton.click();
      await page.waitForLoadState("networkidle");
    });

    for (const { label, value } of authTypeOptions) {
      test(`Auth type "${label}" maps to ${value}`, async ({ page }) => {
        const exemption = new ThreeDSExemptionManager(page);

        await exemption.authTypeDropdown.click();
        await page.getByText(label, { exact: true }).first().click();

        // After selection the dropdown's button text swaps from
        // "Select Field" to the chosen option's label (selectInput renders
        // the matched option label when a value is set).
        await expect(
          page.getByRole("button", { name: label }).first(),
        ).toBeVisible();
      });
    }
  });

  test.describe("Save flow", () => {
    test("should fill the form, save the rule, and preview it on /3ds-exemption", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);
      const ruleName = "Playwright 3ds exemption config";

      await goToExemption(page, homePage);
      await exemption.createNewButton.click();
      await page.waitForLoadState("networkidle");

      // 1. Overwrite the auto-generated `3DS Rule-<date>` name.
      await exemption.ruleNameInput.clear();
      await exemption.ruleNameInput.fill(ruleName);

      // 2. Fill the first condition's numeric value (amount EQUAL TO 100).
      await page.getByPlaceholder("Enter value").first().fill("100");

      // 3. Pick a currency for the second condition (currency IS USD).
      await exemption.selectValueButton.first().click();
      await exemption.dropdownOption("USD", 4).click();

      // 4. Select the auth type so override_3ds is non-empty (the rule
      // wrapper's expand check requires it before save).
      await exemption.authTypeDropdown.click();
      await page
        .getByText("Request 3DS Exemption, Type: TRA", { exact: true })
        .first()
        .click();

      // 5. Save and wait for the activate POST to land before assertions.
      // onSubmit fires POST /routing then POST /routing/{id}/activate — the
      // activate call is the success signal.
      const activateRequest = page.waitForRequest(
        (req) =>
          /routing\/[^/]+\/activate(\?|$)/.test(req.url()) &&
          req.method() === "POST",
      );
      await exemption.saveButton.click();
      await activateRequest;

      // 6. Page redirects back to /3ds-exemption with the ActiveRulePreview card.
      await expect(
        page.getByText("Configuration saved successfully!"),
      ).toBeVisible();
      await expect(page).toHaveURL(/dashboard\/3ds-exemption$/);

      // ActiveRulePreview card metadata.
      await expect(exemption.activeBadge).toBeVisible();
      // capitalizeString only uppercases the first character, so a name that
      // already starts uppercase renders verbatim.
      await expect(page.getByText(ruleName, { exact: true })).toBeVisible();
      await expect(exemption.deleteIcon).toBeVisible();

      // RulePreviewer body — one rule with two statements rendered as
      // <field> <operator> <value> tokens, separated by the AND/OR logical.
      const previewer = page.locator('[data-component="rulePreviewer"]');
      await expect(previewer).toBeVisible();
      await expect(
        previewer.getByText("Rule 1", { exact: true }),
      ).toBeVisible();
      await expect(
        previewer.getByText("amount", { exact: true }),
      ).toBeVisible();
      // getOperatorFromComparisonType maps `equal` + number -> "EQUAL TO",
      // and `equal` + enum_variant -> "IS" (AdvancedRoutingUtils.res:340).
      await expect(
        previewer.getByText("EQUAL TO", { exact: true }),
      ).toBeVisible();
      await expect(previewer.getByText("100", { exact: true })).toBeVisible();
      await expect(previewer.getByText("AND", { exact: true })).toBeVisible();
      await expect(
        previewer.getByText("currency", { exact: true }),
      ).toBeVisible();
      await expect(previewer.getByText("IS", { exact: true })).toBeVisible();
      await expect(previewer.getByText("USD", { exact: true })).toBeVisible();

      // ThreedsTypeView renders the override_3ds value through capitalizeString
      // (RulePreviewer.res:51-60).
      await expect(
        previewer.getByText("Three_ds_exemption_requested_tra", {
          exact: true,
        }),
      ).toBeVisible();
    });
  });
});
