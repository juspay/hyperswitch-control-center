import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentSettings } from "../../support/pages/developers/PaymentSettings";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

/** Accordion sections, one per blockable payment method. */
const SECTIONS = ["Card", "Apple Pay", "Google Pay"] as const;

/** The multi-select filters added by the payment-method-blocking change. */
const SELECT_FIELDS = [
  { label: "Issuing Country", buttonText: "Select Countries" },
  { label: "Card Types", buttonText: "Select Card Types" },
  { label: "Card Networks", buttonText: "Select Card Networks" },
  { label: "Funding Sources", buttonText: "Select Funding Sources" },
  { label: "Card Segment Types", buttonText: "Select Segment Types" },
  { label: "Card Subtypes", buttonText: "Select Card Subtypes" },
] as const;

const TOGGLE_FIELDS = [
  "Block virtual cards",
  "Block non-reloadable prepaid cards",
  "Block gambling BINs",
  "Block if BIN info unavailable",
] as const;

let paymentSettings: PaymentSettings;

const captureProfileUpdate = (page: Page) =>
  page.waitForRequest(
    (request) =>
      request.method() === "POST" &&
      request.url().includes("/business_profile/"),
  );

test.describe("Payment Method Blocking — additional fields", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);

    await paymentSettings.blockListTab.click();
    await expect(paymentSettings.paymentMethodBlocking).toBeVisible();
  });

  test.describe("Section layout", () => {
    test("should show a blocking accordion for card and both wallets", async () => {
      await expect(paymentSettings.cardPaymentMethodBlocking).toBeVisible();
      await expect(paymentSettings.applePayPaymentMethodBlocking).toBeVisible();
      await expect(
        paymentSettings.googlePayPaymentMethodBlocking,
      ).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();
    });

    test("should render a searchable country filter for every payment method", async () => {
      for (const section of SECTIONS) {
        await paymentSettings.paymentMethodBlockingAccordion(section).click();
        await expect(
          paymentSettings.paymentMethodBlockingDropdown(
            section,
            "Select Countries",
          ),
        ).toBeVisible();
        // Collapse again so the next section's locators stay unambiguous.
        await paymentSettings.paymentMethodBlockingAccordion(section).click();
      }
    });
  });

  test.describe("Card accordion", () => {
    test.beforeEach(async () => {
      await paymentSettings.paymentMethodBlockingAccordion("Card").click();
    });

    // ---------------- Positive cases ----------------

    test("should expose every filter and toggle inside an expanded accordion", async ({
      page,
    }) => {
      for (const field of SELECT_FIELDS) {
        await expect(
          page.getByText(field.label, { exact: true }).first(),
        ).toBeVisible();
        await expect(
          paymentSettings.paymentMethodBlockingDropdown(
            "Card",
            field.buttonText,
          ),
        ).toBeVisible();
      }

      for (const toggleLabel of TOGGLE_FIELDS) {
        await expect(
          page.getByText(toggleLabel, { exact: true }).first(),
        ).toBeVisible();
      }

      // The non-obvious default for unrecognised BINs is explained in a tooltip.
      await paymentSettings.openPaymentMethodBlockingTooltip(
        "Card",
        "Block if BIN info unavailable",
      );
      await expect(
        page
          .getByText(
            /Off by default, so unrecognised BINs are allowed through\./,
          )
          .first(),
      ).toBeVisible();
    });

    test("should submit the new card filters under payment_method_blocking.card", async ({
      page,
    }) => {
      await paymentSettings
        .paymentMethodBlockingDropdown("Card", "Select Card Networks")
        .click();
      await paymentSettings.dropdownValueByText("Visa").click();
      await page.keyboard.press("Escape");

      await paymentSettings
        .paymentMethodBlockingDropdown("Card", "Select Funding Sources")
        .click();
      await paymentSettings.dropdownValueByText("Credit").first().click();
      await page.keyboard.press("Escape");

      const updateRequest = captureProfileUpdate(page);
      await paymentSettings.clickUpdate();

      const cardBlocking = (await updateRequest).postDataJSON()
        .payment_method_blocking.card;

      expect(cardBlocking.card_networks).toEqual(["Visa"]);
      expect(cardBlocking.funding_sources).toEqual(["CREDIT"]);
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
    });

    test("should submit blocking toggles as booleans for the selected payment method", async ({
      page,
    }) => {
      await paymentSettings
        .paymentMethodBlockingToggle("Card", "Block virtual cards")
        .click();
      await paymentSettings
        .paymentMethodBlockingToggle("Card", "Block gambling BINs")
        .click();

      const updateRequest = captureProfileUpdate(page);
      await paymentSettings.clickUpdate();

      const cardBlocking = (await updateRequest).postDataJSON()
        .payment_method_blocking.card;

      expect(cardBlocking.block_virtual_cards).toBe(true);
      expect(cardBlocking.gambling_blocked).toBe(true);
      // Untouched toggles must not be silently switched on.
      expect(cardBlocking.block_if_bin_info_unavailable).toBeFalsy();
    });

    test("should persist blocking selections across a page reload", async ({
      page,
    }) => {
      await paymentSettings
        .paymentMethodBlockingToggle("Card", "Block virtual cards")
        .click();
      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();
      await paymentSettings.blockListTab.click();
      await paymentSettings.paymentMethodBlockingAccordion("Card").click();

      await expect(
        paymentSettings.paymentMethodBlockingToggle(
          "Card",
          "Block virtual cards",
        ),
      ).toHaveAttribute("data-bool-value", "on");
    });

    // ---------------- Negative cases ----------------

    test("should show an error toast and stay on the tab when the update fails", async ({
      page,
    }) => {
      await paymentSettings
        .paymentMethodBlockingToggle("Card", "Block virtual cards")
        .click();

      await page.route("**/business_profile/**", async (route) => {
        if (route.request().method() === "POST") {
          await route.fulfill({
            status: 500,
            contentType: "application/json",
            body: JSON.stringify({ error: { message: "Update rejected" } }),
          });
          return;
        }
        await route.fallback();
      });

      await paymentSettings.clickUpdate();

      await expect(page.getByText("Failed to update")).toBeVisible({
        timeout: 10000,
      });
      await expect(paymentSettings.paymentMethodBlocking).toBeVisible();
    });

    // ---------------- Edge cases ----------------

    test("should allow selecting several values in one filter and clearing them again", async ({
      page,
    }) => {
      await paymentSettings
        .paymentMethodBlockingDropdown("Card", "Select Card Types")
        .click();
      await paymentSettings.dropdownValueByText("Credit").first().click();
      await paymentSettings.dropdownValueByText("Debit").first().click();
      await page.keyboard.press("Escape");

      let updateRequest = captureProfileUpdate(page);
      await paymentSettings.clickUpdate();
      let cardBlocking = (await updateRequest).postDataJSON()
        .payment_method_blocking.card;
      expect(cardBlocking.card_types).toEqual(["credit", "debit"]);

      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      // Saving remounts the form, which collapses the accordion again.
      await paymentSettings.paymentMethodBlockingAccordion("Card").click();

      // Deselecting both must clear the filter rather than leave a stale value.
      await paymentSettings
        .paymentMethodBlockingDropdown("Card", "Select Card Types")
        .click();
      await paymentSettings.dropdownValueByText("Credit").first().click();
      await paymentSettings.dropdownValueByText("Debit").first().click();
      await page.keyboard.press("Escape");

      updateRequest = captureProfileUpdate(page);
      await paymentSettings.clickUpdate();
      cardBlocking = (await updateRequest).postDataJSON()
        .payment_method_blocking.card;
      expect(cardBlocking.card_types ?? []).toEqual([]);
    });
  });

  test.describe("Wallet accordions", () => {
    test("should not send blocking config for payment methods left untouched", async ({
      page,
    }) => {
      await paymentSettings.paymentMethodBlockingAccordion("Apple Pay").click();
      await paymentSettings
        .paymentMethodBlockingDropdown("Apple Pay", "Select Card Types")
        .click();
      await paymentSettings.dropdownValueByText("Credit").first().click();
      await page.keyboard.press("Escape");

      const updateRequest = captureProfileUpdate(page);
      await paymentSettings.clickUpdate();

      const blocking = (await updateRequest).postDataJSON()
        .payment_method_blocking;

      expect(blocking.wallet.apple_pay.card_types).toEqual(["credit"]);
      // Google Pay was never opened, so it must not inherit Apple Pay's choice.
      expect(blocking.wallet.google_pay?.card_types).toBeUndefined();
    });

    test("should keep card and wallet filters independent of one another", async ({
      page,
    }) => {
      await paymentSettings.paymentMethodBlockingAccordion("Card").click();
      await paymentSettings
        .paymentMethodBlockingDropdown("Card", "Select Card Types")
        .click();
      await paymentSettings.dropdownValueByText("Credit").first().click();
      await page.keyboard.press("Escape");

      await paymentSettings
        .paymentMethodBlockingAccordion("Google Pay")
        .click();
      await paymentSettings
        .paymentMethodBlockingDropdown("Google Pay", "Select Card Types")
        .click();
      await paymentSettings.dropdownValueByText("Debit").first().click();
      await page.keyboard.press("Escape");

      const updateRequest = captureProfileUpdate(page);
      await paymentSettings.clickUpdate();

      const blocking = (await updateRequest).postDataJSON()
        .payment_method_blocking;

      expect(blocking.card.card_types).toEqual(["credit"]);
      expect(blocking.wallet.google_pay.card_types).toEqual(["debit"]);
      // The wallet grouping must not collapse into a shared card_types key.
      expect(blocking.wallet.card_types).toBeUndefined();
    });
  });
});
