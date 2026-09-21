import { test, expect } from "../../support/test";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentSettings } from "../../support/pages/developers/PaymentSettings";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const SLACK_URL = "https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect";

/**
 * Account Updater is an informational, opt-in-by-request section on the
 * Payment Behaviour tab: merchants cannot self-enable it, so the toggle is
 * rendered permanently off and disabled with a pointer to Slack.
 */
test.describe("Payment Settings — Account Updater", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);
  });

  // ---------------- Positive cases ----------------

  test("should show the Account Updater section with its explanation and supported networks", async ({
    page,
  }) => {
    const paymentSettings = new PaymentSettings(page);

    await expect(paymentSettings.accountUpdaterHeading).toBeVisible();
    await expect(paymentSettings.accountUpdaterDescription).toBeVisible();

    await expect(
      page.getByText(
        /keeps stored cards current .*when a card is reissued, expired or replaced/i,
      ),
    ).toBeVisible();

    // Visa and Mastercard are called out in the copy and as network logos.
    await expect(paymentSettings.accountUpdaterVisaIcon).toBeVisible();
    await expect(paymentSettings.accountUpdaterMastercardIcon).toBeVisible();
  });

  test("should link out to Slack in a new tab for enabling the feature", async ({
    page,
  }) => {
    const paymentSettings = new PaymentSettings(page);

    await expect(paymentSettings.accountUpdaterSlackLink).toBeVisible();
    await expect(paymentSettings.accountUpdaterSlackLink).toHaveAttribute(
      "href",
      SLACK_URL,
    );
    await expect(paymentSettings.accountUpdaterSlackLink).toHaveAttribute(
      "target",
      "_blank",
    );
  });

  // ---------------- Negative cases ----------------

  test("should render the toggle off and refuse to turn it on", async ({
    page,
  }) => {
    const paymentSettings = new PaymentSettings(page);

    const toggle = paymentSettings.accountUpdaterToggle;
    await expect(toggle).toBeVisible();
    await expect(toggle).toHaveAttribute("data-bool-value", "off");

    // Merchants must go through support; the control must not be operable.
    await toggle.click({ force: true });
    await expect(toggle).toHaveAttribute("data-bool-value", "off");
  });

  // ---------------- Edge cases ----------------

  test("should not send any account updater field when the profile is updated", async ({
    page,
  }) => {
    const paymentSettings = new PaymentSettings(page);

    await expect(paymentSettings.accountUpdaterHeading).toBeVisible();
    await paymentSettings.fillReturnUrl("https://example.com/return");

    const updateRequestPromise = page.waitForRequest(
      (request) =>
        request.method() === "POST" &&
        request.url().includes("/business_profile/"),
    );
    await paymentSettings.clickUpdate();

    const payload = (await updateRequestPromise).postDataJSON();
    const serialized = JSON.stringify(payload);

    // The section is display-only; it must not leak a field into the profile.
    expect(serialized).not.toContain("account_updater");
    expect(payload.return_url).toBe("https://example.com/return");
  });

  test("should keep the section visible and still disabled after saving and reloading", async ({
    page,
  }) => {
    const paymentSettings = new PaymentSettings(page);

    await paymentSettings.fillReturnUrl("https://example.com/return");
    await paymentSettings.clickUpdate();
    await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
      timeout: 10000,
    });

    await page.reload();

    await expect(paymentSettings.accountUpdaterHeading).toBeVisible();
    await expect(paymentSettings.accountUpdaterToggle).toHaveAttribute(
      "data-bool-value",
      "off",
    );
    await expect(paymentSettings.accountUpdaterVisaIcon).toBeVisible();
    await expect(paymentSettings.accountUpdaterMastercardIcon).toBeVisible();
  });
});
