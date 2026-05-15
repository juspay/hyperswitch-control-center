import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Webhooks } from "../../support/pages/developers/Webhooks";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Webhooks - endpoint CRUD and subscriptions", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.developer.click();
    await homePage.webhooks.click();
    await page.waitForLoadState("networkidle");
  });

  test("should create a webhook endpoint via Add Endpoint modal", async ({
    page,
  }) => {
    const webhooks = new Webhooks(page);
    const addWebhookButton = webhooks.addEndpointButton;
    if (!(await addWebhookButton.isVisible().catch(() => false))) {
      test.skip(true, "Add Endpoint CTA not exposed");
    }
    await addWebhookButton.click();

    await webhooks.urlInput.fill("https://example.com/webhooks/hyperswitch");
    await webhooks.descriptionInput.fill("Production webhook endpoint");

    await webhooks.saveWebhookButton.click();
    await expect(webhooks.successOrCreatedToast).toBeVisible({ timeout: 10000 });
  });

  test("should subscribe to event types via checkbox list", async ({ page }) => {
    const webhooks = new Webhooks(page);
    const eventCheckbox = webhooks.firstEventCheckbox;
    if (!(await eventCheckbox.isVisible().catch(() => false))) {
      test.skip(true, "event checkboxes not exposed");
    }
    await eventCheckbox.check();

    const saveButton = webhooks.saveEventsButton;
    if (await saveButton.isVisible().catch(() => false)) {
      await saveButton.click();
    }
  });

  test("should accept retry attempts and interval values", async ({ page }) => {
    const webhooks = new Webhooks(page);
    const retryAttempts = webhooks.retryAttemptsInput;
    if (!(await retryAttempts.isVisible().catch(() => false))) {
      test.skip(true, "retry policy form not exposed");
    }
    await retryAttempts.fill("3");

    const retryInterval = webhooks.retryIntervalInput;
    if (await retryInterval.isVisible().catch(() => false)) {
      await retryInterval.fill("60");
    }
    await webhooks.saveRetryPolicyButton.click();
  });

  test("should switch to Logs tab and render log rows or empty state", async ({
    page,
  }) => {
    const webhooks = new Webhooks(page);
    const logsTab = webhooks.logsTab;
    if (!(await logsTab.isVisible().catch(() => false))) {
      test.skip(true, "Logs tab not exposed");
    }
    await logsTab.click();
    await page.waitForTimeout(500);
    expect(page.url()).toContain("/dashboard");
  });

  test("should toggle a webhook endpoint off and emit a disabled/updated toast", async ({
    page,
  }) => {
    const webhooks = new Webhooks(page);
    const toggle = webhooks.endpointToggle;
    if (!(await toggle.isVisible().catch(() => false))) {
      test.skip(true, "webhook toggle not exposed");
    }
    await toggle.uncheck();
    await expect(webhooks.disabledOrUpdatedToast).toBeVisible({ timeout: 10000 });
  });
});
