import { test, expect, type Page } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createSurchargeAPI,
  createThreeDsExemptionAPI,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { Surcharge } from "../support/pages/workflow/Surcharge";
import { ThreeDSExemptionManager } from "../support/pages/workflow/ThreeDSExemptionManager";
import { PaymentRouting } from "../support/pages/workflow/paymentRouting/PaymentRouting";
import { PayoutRouting } from "../support/pages/workflow/payoutRouting/PayoutRouting";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// FeatureFlagUtils.res reads `threeds_exemption` off the dashboard config.
// The 3DS Exemption menu is gated behind it, so the flag must be flipped ON
// BEFORE loginUI navigates (the initial `/dashboard/config/feature` fetch).
const enableThreeDsExemptionFlag = async (page: Page): Promise<void> => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features = { ...(json.features ?? {}), threeds_exemption: true };
    await route.fulfill({ response, json });
  });
};

test.describe("Visual Testing - Workflow", () => {
  test.describe("Routing", () => {
    test("routing landing with no configuration should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.routing.click();

      // Routing landing renders the configuration option cards regardless of
      // whether any connector or rule exists.
      await expect(
        page.getByText("Volume Based Configuration", { exact: true }),
      ).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-routing-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("routing volume setup with no connectors should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentRouting = new PaymentRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.routing.click();
      await paymentRouting.volumeBasedRoutingSetupButton.click();

      // Fresh signup → no connectors, so the setup CTA lands on the
      // "configure at least 1 connector" guard screen.
      await expect(paymentRouting.noConnectorsMessage).toContainText(
        "Please configure at least 1 connector",
      );

      await expect(page).toHaveScreenshot(
        "workflow-routing-setup-no-connectors.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("Surcharge", () => {
    test("surcharge empty state should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.surchargeRouting.click();
      await page.waitForURL(/dashboard\/surcharge/, { timeout: 15000 });

      // Fresh signup → no active surcharge rule on this merchant.
      await expect(surcharge.pageHeading).toBeVisible();
      await expect(surcharge.emptyStateHeading).toBeVisible();
      await expect(surcharge.createNewButton).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-surcharge-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("surcharge with active rule should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed an active surcharge rule via the routing API (reads the JWT from
      // localStorage, so it must run after loginUI).
      await createSurchargeAPI(page, context.request, {
        name: "playwright_surcharge",
      });

      await homePage.workflow.click();
      await homePage.surchargeRouting.click();
      await page.waitForURL(/dashboard\/surcharge/, { timeout: 15000 });

      // ActiveRulePreview card with the seeded rule.
      await expect(surcharge.activeBadge).toBeVisible();
      await expect(surcharge.editIcon).toBeVisible();
      await expect(surcharge.deleteIcon).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-surcharge-with-rule.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });
  });

  test.describe("Payout Routing", () => {
    test("payout routing landing with no configuration should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.payoutRouting.click();

      await expect(
        page.getByText("Volume Based Configuration", { exact: true }),
      ).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-payout-routing-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("payout routing volume setup with no connectors should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const payoutRouting = new PayoutRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.payoutRouting.click();
      await payoutRouting.volumeBasedRoutingSetupButton.click();

      await expect(payoutRouting.noConnectorsMessage).toContainText(
        "Please configure at least 1 connector",
      );

      await expect(page).toHaveScreenshot(
        "workflow-payout-routing-setup-no-connectors.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("3DS Exemption Manager", () => {
    test("3ds exemption empty state should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      // Register the FF mock before loginUI navigates so the menu is exposed.
      await enableThreeDsExemptionFlag(page);

      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.threeDSExemptionManager.click();
      await page.waitForURL(/dashboard\/3ds-exemption/, { timeout: 15000 });

      // Fresh signup → no active 3DS exemption rule on this merchant.
      await expect(exemption.pageHeading).toBeVisible();
      await expect(exemption.configureSectionHeading).toBeVisible();
      await expect(exemption.createNewButton).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-3ds-exemption-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("3ds exemption with active rule should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);
      await enableThreeDsExemptionFlag(page);

      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed an active 3DS exemption rule via the routing API (reads the JWT
      // from localStorage, so it must run after loginUI).
      await createThreeDsExemptionAPI(page, context.request, {
        name: "playwright_3ds_exemption",
      });

      await homePage.workflow.click();
      await homePage.threeDSExemptionManager.click();
      await page.waitForURL(/dashboard\/3ds-exemption/, { timeout: 15000 });

      // ActiveRulePreview card with the seeded rule.
      await expect(exemption.activeBadge).toBeVisible();
      await expect(exemption.deleteIcon).toBeVisible();

      await expect(page).toHaveScreenshot(
        "workflow-3ds-exemption-with-rule.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });
});
