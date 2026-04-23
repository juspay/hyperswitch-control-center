import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

const GATED_PROCESSORS: ReadonlyArray<{
  featureFlag: string;
  sidebar: keyof HomePage;
  url: RegExp;
  label: string;
  fields: Record<string, string>;
}> = [
  {
    featureFlag: "tax_processor",
    sidebar: "taxConnectors",
    url: /.*dashboard\/tax-processor/,
    label: "TaxJar",
    fields: { api_key: "taxjar_test_api_key", connector_label: "taxjar_test" },
  },
  {
    featureFlag: "billing_processor",
    sidebar: "billingConnectors",
    url: /.*dashboard\/billing-processor/,
    label: "Chargebee",
    fields: { api_key: "chargebee_test_api_key" },
  },
  {
    featureFlag: "vault_processor",
    sidebar: "vaultConnectors",
    url: /.*dashboard\/vault-processor/,
    label: "Spreedly",
    fields: {
      environment_key: "spreedly_test_env_key",
      access_secret: "spreedly_test_secret",
    },
  },
  {
    featureFlag: "pm_authentication_processor",
    sidebar: "pmAuthConnectors",
    url: /.*dashboard\/pm-authentication-processor/,
    label: "PM Auth",
    fields: { api_key: "pm_auth_test_key" },
  },
];

for (const proc of GATED_PROCESSORS) {
  test.describe(`${proc.label} processor - connect flow`, () => {
    test.beforeEach(async ({ page, context }) => {
      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await page.route("**/dashboard/config/feature*", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json.features) {
          json.features[proc.featureFlag] = true;
        }
        await route.fulfill({ response, json });
      });
    });

    test(`should open ${proc.label} config, fill fields, and reach success toast if exposed`, async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const link = homePage[proc.sidebar] as unknown as ReturnType<
        (typeof homePage)["connectors"]["locator" extends never ? never : never]
      >;

      await homePage.connectors.click();
      // @ts-expect-error HomePage POM members are Locators at runtime
      await homePage[proc.sidebar].click();

      await expect(page).toHaveURL(proc.url);

      const connectButton = page
        .locator('[data-button-for="connectNow"], button:has-text("Connect")')
        .first();
      if (!(await connectButton.isVisible().catch(() => false))) {
        test.skip(true, `${proc.label} connect CTA not exposed`);
      }
      await connectButton.click();

      for (const [name, value] of Object.entries(proc.fields)) {
        const input = page.locator(`[name*="${name}"]`).first();
        if (await input.isVisible().catch(() => false)) {
          await input.fill(value);
        }
      }

      const proceed = page
        .locator(
          '[data-button-for="connectAndProceed"], button:has-text("Connect")',
        )
        .last();
      if (await proceed.isEnabled().catch(() => false)) {
        await proceed.click();
        const toast = page.locator(
          '[data-toast*="success"], [data-toast*="Successfully"], [data-toast*="Connected"]',
        );
        await expect(toast).toBeVisible({ timeout: 10000 });
      }
    });
  });
}
