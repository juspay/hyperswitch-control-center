import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const enableFlags = async (page: Page) => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json && json.features) {
      Object.assign(json.features, {
        dev_recovery_v2_product: true,
        dev_recovery_external_trigger: true,
      });
    }
    await route.fulfill({ response, json });
  });
};

// The profile fields come from an unmerged backend change, so they are mocked here.
// Returns the bodies sent to the profile update API.
const mockProfileFields = async (page: Page) => {
  const updates: Record<string, unknown>[] = [];
  let savedFields: Record<string, unknown> = {};

  await page.route(/\/v2\/profiles\/[^/]+$/, async (route) => {
    const method = route.request().method();
    if (method === "PUT") {
      const body = route.request().postDataJSON();
      updates.push(body);
      savedFields = { ...savedFields, ...body };
      await route.fulfill({ json: savedFields });
    } else if (method === "GET") {
      const response = await route.fetch();
      const json = await response.json();
      await route.fulfill({ response, json: { ...json, ...savedFields } });
    } else {
      await route.continue();
    }
  });

  return updates;
};

const openModelPicker = async (page: Page) => {
  const homePage = new HomePage(page);
  await homePage.homeV2.click();
  await homePage
    .productCardName("Revenue Recovery")
    .locator("xpath=ancestor::div[contains(@class,'shadow-cardShadow')]")
    .getByRole("button", { name: "Learn More" })
    .click();
  await homePage.addMerchantButton.click();
  await page.getByRole("button", { name: "Explore Recovery" }).click();
};

test.describe("Revenue Recovery trigger model", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await enableFlags(page);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("Managed Recovery keeps the existing stepper and saves nothing", async ({
    page,
  }) => {
    const updates = await mockProfileFields(page);
    await openModelPicker(page);

    await page.getByText("Managed Recovery", { exact: true }).click();
    await page.getByRole("button", { name: "Continue" }).click();

    await expect(page).toHaveURL(/\/v2\/recovery\/onboarding$/);
    await expect(page.getByText("Setup Recovery")).toBeVisible();
    expect(updates).toHaveLength(0);
  });

  test("Scheduled Only Recovery saves mode and config, then shows profile settings", async ({
    page,
  }) => {
    const updates = await mockProfileFields(page);
    await openModelPicker(page);

    await page.getByText("Scheduled Only Recovery", { exact: true }).click();
    await page.getByRole("button", { name: "Continue" }).click();
    await expect(page).toHaveURL(/\/v2\/recovery\/onboarding\/configuration$/);

    await page.getByRole("button", { name: "Smart", exact: true }).click();
    await page.getByPlaceholder("ex 30").fill("20");
    await page.getByRole("button", { name: "Save and finish" }).click();

    await expect(page).toHaveURL(/\/v2\/recovery\/invoices/);
    await expect(page.getByText("Scheduled Only Recovery")).toBeVisible();
    await expect(page.getByText("Smart", { exact: true })).toHaveCount(0);
    expect(updates[0]).toMatchObject({
      revenue_recovery_trigger_model: "external_triggers",
      revenue_recovery_retry_algorithm_type: "smart",
      revenue_recovery_config: {
        grace_period_days: 20,
        max_retry_count: 15,
        billing_connector_retry_threshold: 3,
      },
    });

    await page.getByText("Configuration Details").click();
    await expect(page.getByText("Scheduled Only Recovery")).toBeVisible();
    await expect(page.getByText("Processor details")).toHaveCount(0);
    await expect(page.getByText("API Keys", { exact: true })).toBeVisible();

    await page.getByText("Retries Configuration").click();
    await expect(page.getByText("20 days")).toBeVisible();
    await expect(page.getByText("Smart", { exact: true })).toBeVisible();

    await page.getByText("Webhooks", { exact: true }).click();
    await expect(page.getByText("Webhooks are not enabled yet.")).toBeVisible();
  });
});
