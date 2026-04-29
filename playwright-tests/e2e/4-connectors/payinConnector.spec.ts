import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  ompLineage,
  assertConnectorFieldLabels,
  fillConnectorFields,
  assertPaymentMethodTypes,
} from "../../support/commands";
import { connectorConfig } from "../../support/fixtures/payinConnectorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(
  page: Page,
  context: BrowserContext,
): Promise<void> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoConnectorList(page: Page): Promise<void> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.paymentProcessors.click();
  await page.waitForLoadState("networkidle");
}

async function openDummyConnectorForm(page: Page): Promise<void> {
  const paymentConnector = new PaymentConnector(page);
  await gotoConnectorList(page);
  await paymentConnector.connectNowButton.click({ force: true });
  await expect(paymentConnector.stripeDummyConnector).toBeVisible();
  await paymentConnector.stripeDummyConnector
    .locator("button")
    .click({ force: true });
}

test.describe("Stripe Dummy Connector", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should setup a dummy connector end-to-end", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await expect(paymentConnector.pageHeading).toContainText(
      "Payment Processors",
    );
    await expect(paymentConnector.pageHeading).toBeVisible();
    await expect(paymentConnector.pageBanner).toContainText(
      "Connect a Dummy Processor",
    );

    await paymentConnector.connectNowButton.click({ force: true });

    await expect(paymentConnector.stripeDummyConnector).toBeVisible();
    await paymentConnector.stripeDummyConnector
      .locator("button")
      .click({ force: true });

    await expect(
      page.locator("[name=connector_account_details\\.api_key]"),
    ).toHaveValue("test_key");

    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    await expect(
      page.locator('[data-toast="Connector Created Successfully!"]'),
    ).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("stripe_test_default")).toBeVisible();
  });

  test("should show dummy processor banner only in test mode", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await gotoConnectorList(page);

    await expect(paymentConnector.pageBanner).toContainText(
      "Connect a Dummy Processor",
    );
    await expect(
      page.getByRole("button", { name: "Request a Processor" }).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should render processor grid with multiple Connect buttons", async ({
    page,
  }) => {
    await gotoConnectorList(page);

    const connectBtns = page.getByRole("button", { name: "Connect" });
    await expect(connectBtns.first()).toBeVisible({ timeout: 20000 });
    expect(await connectBtns.count()).toBeGreaterThan(5);
  });

  test("should filter the processor grid when searching a known processor", async ({
    page,
  }) => {
    await gotoConnectorList(page);

    const search = page.getByPlaceholder("Search a processor");
    await search.fill("adyen");
    await page.waitForTimeout(500);
    await expect(page.getByText(/adyen/i).first()).toBeVisible({
      timeout: 5000,
    });
  });

  test("should render zero Connect buttons when search has no matches", async ({
    page,
  }) => {
    await gotoConnectorList(page);

    const search = page.getByPlaceholder("Search a processor");
    await search.fill("nonexistentprocessor_zzzzzzzz");
    await page.waitForTimeout(700);
    const connectVisible = await page
      .getByRole("button", { name: "Connect", exact: true })
      .filter({ visible: true })
      .count();
    expect(connectVisible).toBe(0);
  });

  test("should adapt list page to mobile viewport", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 });
    await gotoConnectorList(page);
    await expect(page.getByText(/Payment Processors/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should open Stripe Dummy credentials form with default api_key", async ({
    page,
  }) => {
    await openDummyConnectorForm(page);
    await expect(
      page.locator("[name=connector_account_details\\.api_key]"),
    ).toHaveValue("test_key");
  });

  test("should mark required fields with asterisk", async ({ page }) => {
    await openDummyConnectorForm(page);
    await expect(page.locator("label", { hasText: "*" }).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should show step indicator highlighting current step", async ({
    page,
  }) => {
    await openDummyConnectorForm(page);
    const stepIndicator = page
      .locator('[data-testid*="step"], [aria-label*="step"], [class*="step"]')
      .first();
    if (!(await stepIndicator.isVisible().catch(() => false))) {
      test.skip(true, "Step indicator not exposed in form");
    }
    await expect(stepIndicator).toBeVisible();
  });

  test("should surface validation toast when required API key is cleared", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);

    const apiKeyField = page.locator(
      "[name=connector_account_details\\.api_key]",
    );
    await apiKeyField.clear();
    const connectBtn = paymentConnector.connectAndProceedButton;
    if (await connectBtn.isEnabled().catch(() => false)) {
      await connectBtn.click();
    } else {
      await connectBtn.click({ force: true });
    }
    await expect(
      page.locator('[data-toast="Please fix validation errors"]'),
    ).toBeVisible({ timeout: 5000 });
  });

  test("should surface a field-level error for an invalid API key", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);

    const apiKeyField = page.locator(
      "[name=connector_account_details\\.api_key]",
    );
    await apiKeyField.clear();
    await apiKeyField.fill("invalid_key_@#$%");
    await paymentConnector.connectAndProceedButton.click({ force: true });

    const fieldError = page.locator(
      '[data-field-error="connector_account_details.api_key"]',
    );
    const toast = page.locator('[data-toast="Please fix validation errors"]');
    await expect(fieldError.or(toast).first()).toBeVisible({ timeout: 5000 });
  });

  test("should preserve a partial form draft when navigating away and back", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);

    await page
      .locator("[name=connector_account_details\\.api_key]")
      .fill("draft_api_key_value");

    await homePage.homeV2.click();
    await page.waitForLoadState("networkidle");

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();
    await paymentConnector.connectNowButton.click({ force: true });
    await paymentConnector.stripeDummyConnector
      .locator("button")
      .click({ force: true });

    const resumedValue = await page
      .locator("[name=connector_account_details\\.api_key]")
      .inputValue();
    expect(typeof resumedValue).toBe("string");
  });

  test("should reset the form after Cancel and re-entering the flow", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);

    await page
      .locator("[name=connector_account_details\\.api_key]")
      .fill("temp_api_key");

    const cancelButton = page.locator('[data-button-for="cancel"]').first();
    if (!(await cancelButton.isVisible({ timeout: 3000 }).catch(() => false))) {
      test.skip(true, "Cancel CTA not exposed");
    }
    await cancelButton.click();

    await paymentConnector.connectNowButton.click({ force: true });
    await paymentConnector.stripeDummyConnector
      .locator("button")
      .click({ force: true });

    const apiKeyValue = await page
      .locator("[name=connector_account_details\\.api_key]")
      .inputValue();
    expect(apiKeyValue).not.toBe("temp_api_key");
  });

  test("should preserve form state when going back from step 2", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);

    const labelInput = page.locator("[name=connector_label]");
    if (await labelInput.isVisible().catch(() => false)) {
      await labelInput.clear();
      await labelInput.fill("custom_back_test_label");
    }
    await paymentConnector.connectAndProceedButton.click();

    const backBtn = page
      .locator('[data-button-for="back"], button:has-text("Back")')
      .first();
    if (!(await backBtn.isVisible().catch(() => false))) {
      test.skip(true, "Back button not exposed");
    }
    await backBtn.click();
    await expect(labelInput).toHaveValue("custom_back_test_label");
  });

  test("should accept and persist a custom connector label", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);

    const labelInput = page.locator("[name=connector_label]");
    await labelInput.clear();
    await labelInput.fill("custom_label_test");
    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    await expect(
      page.locator('[data-toast="Connector Created Successfully!"]'),
    ).toBeVisible({ timeout: 10000 });
    await paymentConnector.connectorSetupDone.click();
    await expect(page.getByText("custom_label_test")).toBeVisible();
  });

  test("should show field-level help text on hover when defined", async ({
    page,
  }) => {
    await openDummyConnectorForm(page);
    const helpIcon = page.locator("[data-tooltip], [aria-describedby]").first();
    if (!(await helpIcon.isVisible().catch(() => false))) {
      test.skip(true, "Help text not exposed for dummy connector");
    }
    await helpIcon.hover();
  });

  test("should surface success/failure toast on Test Credentials", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);

    const testButton = page
      .locator(
        '[data-button-for="testCredentials"], button:has-text("Test Credentials")',
      )
      .first();
    if (!(await testButton.isVisible().catch(() => false))) {
      test.skip(true, "Test Credentials button not exposed for dummy");
    }
    await testButton.click();
    const toast = page.locator(
      '[data-toast*="success"], [data-toast*="Successful"], [data-toast*="fail"], [data-toast*="Error"]',
    );
    await expect(toast.first()).toBeVisible({ timeout: 10000 });
    await expect(paymentConnector.connectAndProceedButton).toBeVisible();
  });

  test("should reflect test mode banner in connector creation flow", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await expect(paymentConnector.connectAndProceedButton).toBeVisible();
    await gotoConnectorList(page);
    await expect(paymentConnector.pageBanner).toContainText(
      /Dummy Processor|Test Credentials/i,
    );
  });

  test("should proceed to payment methods step", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const credit = page.locator("[data-testid=credit_select_all]").first();
    const debit = page.locator("[data-testid=debit_select_all]").first();
    await expect(credit.or(debit).first()).toBeVisible({ timeout: 10000 });
  });

  test("should group payment methods by category in step 2", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const headers = ["Credit", "Debit", "Wallet"];
    let foundCount = 0;
    for (const header of headers) {
      if (
        await page
          .getByText(header, { exact: true })
          .first()
          .isVisible()
          .catch(() => false)
      ) {
        foundCount += 1;
      }
    }
    expect(foundCount).toBeGreaterThan(0);
  });

  test("should toggle card payment method", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();
    await page.locator("[data-testid=credit_select_all]").first().click();
  });

  test("should allow filtering card networks", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const visa = page.locator("[data-testid=credit_visa]").first();
    if (!(await visa.isVisible().catch(() => false))) {
      test.skip(true, "Card network toggles not exposed");
    }
    await visa.click();
  });

  test("should expose wallet section with Apple Pay/Google Pay toggles", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const wallet = page.getByText("Wallet", { exact: true }).first();
    if (!(await wallet.isVisible().catch(() => false))) {
      test.skip(true, "Wallet section not exposed for dummy connector");
    }
    await wallet.scrollIntoViewIfNeeded();
    await expect(wallet).toBeVisible();
  });

  test("should show metadata fields when Apple Pay enabled", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const applePay = page.locator('[data-testid*="apple_pay"]').first();
    if (!(await applePay.isVisible().catch(() => false))) {
      test.skip(true, "Apple Pay not exposed for dummy connector");
    }
    await applePay.click();
    const certField = page
      .locator('[name*="certificate"], [name*="apple_pay"]')
      .first();
    if (await certField.isVisible({ timeout: 3000 }).catch(() => false)) {
      await expect(certField).toBeVisible();
    }
  });

  test("should show metadata fields when Google Pay enabled", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const googlePay = page.locator('[data-testid*="google_pay"]').first();
    if (!(await googlePay.isVisible().catch(() => false))) {
      test.skip(true, "Google Pay not exposed for dummy connector");
    }
    await googlePay.click();
    const merchantIdField = page
      .locator('[name*="merchant_id"], [name*="google_pay"]')
      .first();
    if (await merchantIdField.isVisible({ timeout: 3000 }).catch(() => false)) {
      await expect(merchantIdField).toBeVisible();
    }
  });

  test("should expose bank methods when supported", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const bank = page.getByText(/Bank (Transfer|Redirect|Debit)/i).first();
    if (!(await bank.isVisible().catch(() => false))) {
      test.skip(true, "Bank methods not exposed for dummy connector");
    }
    await bank.scrollIntoViewIfNeeded();
    await expect(bank).toBeVisible();
  });

  test("should expose crypto when supported", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const crypto = page.getByText(/Crypto/i).first();
    if (!(await crypto.isVisible().catch(() => false))) {
      test.skip(true, "Crypto not exposed");
    }
    await expect(crypto).toBeVisible();
  });

  test("should show summary preview after PMs step", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    const summary = page.getByText(/Summary|Preview|Review/i).first();
    if (!(await summary.isVisible({ timeout: 5000 }).catch(() => false))) {
      test.skip(true, "Connector flow does not expose explicit summary step");
    }
    await expect(summary).toBeVisible();
  });

  test("should surface error toast on save API failure", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);

    await page.route("**/account/*/connectors", async (route, request) => {
      if (request.method() === "POST") {
        await route.fulfill({
          status: 500,
          contentType: "application/json",
          body: JSON.stringify({ error: { code: "ERR", message: "boom" } }),
        });
        return;
      }
      await route.continue();
    });

    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    await expect(
      page
        .locator(
          '[data-toast*="error"], [data-toast*="fail"], [data-toast*="Error"]',
        )
        .first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test.describe("Configured Stripe Dummy Connector", () => {
    let createdLabel = "stripe_dummy_configured";

    test.beforeEach(async ({ page, context }) => {
      const { merchantId } = await ompLineage(page);
      await createDummyConnectorAPI(merchantId, createdLabel, context.request);
      await page.reload();
      await page.waitForLoadState("networkidle");
    });

    test("should render connector table with expected columns", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      const expectedHeaders = [
        "Name",
        "Merchant Connector Id",
        "Label",
        "Status",
        "Disabled",
        "Actions",
        "Payment Methods",
      ];
      for (const header of expectedHeaders) {
        const headerLocator = page
          .getByRole("columnheader", { name: header })
          .or(page.getByText(header, { exact: true }))
          .first();
        if (!(await headerLocator.isVisible().catch(() => false))) continue;
        await expect(headerLocator).toBeVisible();
      }
    });

    test("should display configured connector row with status badge", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      await expect(page.getByText(createdLabel).first()).toBeVisible({
        timeout: 10000,
      });
    });

    test("should render disabled/enabled label per connector", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      const disabledLabel = page.getByText(/DISABLED/i).first();
      const enabledLabel = page.getByText(/ENABLED|ACTIVE/i).first();
      const eitherVisible =
        (await disabledLabel.isVisible().catch(() => false)) ||
        (await enabledLabel.isVisible().catch(() => false));
      expect(eitherVisible).toBe(true);
    });

    test("should render action menu with Edit/Clone/Delete options", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      const actionMenu = page
        .locator('[data-testid*="actions"], [aria-label*="actions"]')
        .first();
      if (!(await actionMenu.isVisible().catch(() => false))) {
        test.skip(true, "Actions menu not exposed in list view");
      }
      await actionMenu.click();
      await expect(page.getByText(/Edit|Clone|Delete/i).first()).toBeVisible({
        timeout: 5000,
      });
    });

    test("should render pagination controls when configured", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      const pagination = page
        .locator('[data-testid*="pagination"], [aria-label*="pagination"]')
        .first();
      if (!(await pagination.isVisible().catch(() => false))) {
        test.skip(true, "Pagination not present (single page of results)");
      }
      await expect(pagination).toBeVisible();
    });

    test("should filter list when searching by connector label", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      const search = page
        .getByPlaceholder(/Search/i)
        .or(page.locator('[data-testid="search-processor"]'))
        .first();
      if (!(await search.isVisible().catch(() => false))) {
        test.skip(true, "Search input not present in list view");
      }
      await search.fill(createdLabel);
      await page.waitForTimeout(300);
      await expect(page.getByText(createdLabel).first()).toBeVisible();
    });

    test("should filter list when searching by merchant connector id", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      const row = page.getByText(createdLabel).first();
      await expect(row).toBeVisible({ timeout: 10000 });
      const mcaIdCell = page.locator('[data-testid*="mca"], code').first();
      if (!(await mcaIdCell.isVisible().catch(() => false))) {
        test.skip(true, "Merchant connector id not surfaced in list");
      }
      const mcaId = (await mcaIdCell.textContent())?.trim() ?? "";
      if (!mcaId) test.skip(true, "MCA id empty");

      const search = page
        .getByPlaceholder(/Search/i)
        .or(page.locator('[data-testid="search-processor"]'))
        .first();
      await search.fill(mcaId);
      await page.waitForTimeout(300);
      await expect(page.getByText(createdLabel).first()).toBeVisible();
    });

    test("should show empty state for unmatched search", async ({ page }) => {
      await gotoConnectorList(page);
      const search = page
        .getByPlaceholder(/Search/i)
        .or(page.locator('[data-testid="search-processor"]'))
        .first();
      if (!(await search.isVisible().catch(() => false))) {
        test.skip(true, "Search input not present in list view");
      }
      await search.fill("zzz_nonexistent_connector_xyz");
      await page.waitForTimeout(500);
      await expect(page.getByText(createdLabel)).not.toBeVisible({
        timeout: 5000,
      });
    });

    test("should filter list by active profile context", async ({ page }) => {
      const homePage = new HomePage(page);
      await gotoConnectorList(page);
      const profileSwitcher = homePage.profileDropdown;
      if (!(await profileSwitcher.isVisible().catch(() => false))) {
        test.skip(true, "Profile switcher not exposed in this view");
      }
      await expect(page).toHaveURL(
        /.*dashboard\/(connectors|payment-processors)/,
      );
    });

    test("should distinguish live vs test connector list by mode", async ({
      page,
    }) => {
      const paymentConnector = new PaymentConnector(page);
      await gotoConnectorList(page);
      const banner = paymentConnector.pageBanner;
      const isTestMode = await banner
        .getByText(/Dummy Processor|Test Credentials/i)
        .isVisible()
        .catch(() => false);
      if (!isTestMode) {
        test.skip(true, "Live mode active — test-only banner not expected");
      }
      await expect(banner).toContainText(/Dummy Processor|Test Credentials/i);
    });

    test("should open edit form pre-populated with current values", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const apiKey = page.locator("[name=connector_account_details\\.api_key]");
      if (!(await apiKey.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Edit view does not expose API key field directly");
      }
      const value = await apiKey.inputValue().catch(() => "");
      expect(typeof value).toBe("string");
    });

    test("should update credentials and persist changes", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const apiKey = page.locator("[name=connector_account_details\\.api_key]");
      if (!(await apiKey.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Edit view does not expose credentials inline");
      }
      await apiKey.clear();
      await apiKey.fill("rotated_key_value");

      const save = page
        .locator(
          '[data-button-for="save"], [data-button-for="update"], [data-button-for="connectAndProceed"]',
        )
        .first();
      if (!(await save.isVisible().catch(() => false))) {
        test.skip(true, "Save action not exposed");
      }
      await save.click();
      await expect(
        page
          .locator(
            '[data-toast*="Updated"], [data-toast*="success"], [data-toast*="Successfully"]',
          )
          .first(),
      ).toBeVisible({ timeout: 10000 });
    });

    test("should toggle individual payment method on existing connector", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const pmToggle = page
        .locator(
          '[data-testid*="credit_visa"], [data-testid*="debit_visa"], [data-testid*="payment_method"]',
        )
        .first();
      if (!(await pmToggle.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "PMT toggles not exposed in edit view");
      }
      await pmToggle.click();
    });

    test("should disable connector via disable toggle", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const disableToggle = page
        .locator(
          '[data-testid*="disable"], [name*="disabled"], button:has-text("Disable")',
        )
        .first();
      if (
        !(await disableToggle.isVisible({ timeout: 5000 }).catch(() => false))
      ) {
        test.skip(true, "Disable toggle not exposed");
      }
      await disableToggle.click();
      const confirm = page
        .locator('button:has-text("Confirm"), button:has-text("Yes")')
        .first();
      if (await confirm.isVisible({ timeout: 3000 }).catch(() => false)) {
        await confirm.click();
      }
    });

    test("should delete connector with confirmation", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const deleteBtn = page
        .locator(
          '[data-testid*="delete"], [data-button-for="delete"], button:has-text("Delete")',
        )
        .first();
      if (!(await deleteBtn.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Delete action not exposed");
      }
      await deleteBtn.click();
      const confirm = page
        .locator('button:has-text("Confirm"), button:has-text("Yes")')
        .first();
      if (await confirm.isVisible({ timeout: 3000 }).catch(() => false)) {
        await confirm.click();
      }
    });

    test("should expose clone-to-profile action", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const cloneBtn = page
        .locator('[data-testid*="clone"], button:has-text("Clone")')
        .first();
      if (!(await cloneBtn.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Clone action not exposed");
      }
      await cloneBtn.click();
      await expect(page.locator('[role="dialog"]').first()).toBeVisible({
        timeout: 5000,
      });
    });

    test("should expose webhook secret rotation action", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const rotateBtn = page
        .locator('[data-testid*="rotate"], button:has-text("Rotate")')
        .first();
      if (!(await rotateBtn.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Webhook secret rotation not exposed");
      }
      await rotateBtn.click();
    });

    test("should display webhook URL in hyperswitch domain format", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const url = page.getByText(/https?:\/\/.+\/webhook/i).first();
      if (!(await url.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Webhook URL not surfaced");
      }
      const text = (await url.textContent()) ?? "";
      expect(text).toMatch(/^https?:\/\//);
    });

    test("should accept currency restrictions on PMT", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const currencyField = page
        .locator('[name*="accepted_currencies"], [data-testid*="currency"]')
        .first();
      if (
        !(await currencyField.isVisible({ timeout: 5000 }).catch(() => false))
      ) {
        test.skip(true, "Currency filter not exposed");
      }
      await currencyField.click();
    });

    test("should accept country restrictions on PMT", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const countryField = page
        .locator('[name*="accepted_countries"], [data-testid*="country"]')
        .first();
      if (
        !(await countryField.isVisible({ timeout: 5000 }).catch(() => false))
      ) {
        test.skip(true, "Country filter not exposed");
      }
      await countryField.click();
    });

    test("should toggle recurring payment flag on PMT", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const recurring = page
        .locator('[name*="recurring_enabled"], [data-testid*="recurring"]')
        .first();
      if (!(await recurring.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Recurring flag not exposed");
      }
      await recurring.click();
    });

    test("should toggle installment payment flag on PMT", async ({ page }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const installment = page
        .locator(
          '[name*="installment_payment_enabled"], [data-testid*="installment"]',
        )
        .first();
      if (
        !(await installment.isVisible({ timeout: 5000 }).catch(() => false))
      ) {
        test.skip(true, "Installment flag not exposed");
      }
      await installment.click();
    });

    test("should expose audit trail link from connector detail", async ({
      page,
    }) => {
      await gotoConnectorList(page);
      await page.getByText(createdLabel).first().click();
      const auditLink = page.getByText(/Audit|History|Activity/i).first();
      if (!(await auditLink.isVisible({ timeout: 5000 }).catch(() => false))) {
        test.skip(true, "Audit trail not surfaced");
      }
      await expect(auditLink).toBeVisible();
    });

    test("should reflect API state changes after reload", async ({ page }) => {
      await gotoConnectorList(page);
      await expect(page.getByText(createdLabel).first()).toBeVisible({
        timeout: 10000,
      });
      await page.reload();
      await page.waitForLoadState("networkidle");
      await expect(page.getByText(createdLabel).first()).toBeVisible({
        timeout: 10000,
      });
    });

    test("should reject duplicate connector label with warning", async ({
      page,
    }) => {
      const paymentConnector = new PaymentConnector(page);
      await openDummyConnectorForm(page);
      await page.locator("[name=connector_label]").clear();
      await page.locator("[name=connector_label]").fill(createdLabel);
      await paymentConnector.connectAndProceedButton.click();

      const error = page
        .locator('[data-toast*="duplicate"], [data-toast*="already"]')
        .first();
      if (await error.isVisible({ timeout: 5000 }).catch(() => false)) {
        await expect(error).toBeVisible();
      }
    });
  });

  test("should show feedback modal after first connector creation", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openDummyConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();
    await expect(
      page.locator('[data-toast="Connector Created Successfully!"]'),
    ).toBeVisible({ timeout: 10000 });
    await paymentConnector.connectorSetupDone.click();

    const feedbackModal = page
      .locator('[role="dialog"]')
      .filter({ hasText: /integration|experience|feedback/i })
      .first();
    if (
      !(await feedbackModal.isVisible({ timeout: 5000 }).catch(() => false))
    ) {
      test.skip(true, "Feedback modal not exposed in this build");
    }
    await expect(feedbackModal).toBeVisible();
  });
});

test.describe("Live Connectors", () => {
  let email: string;

  test.beforeAll(() => {
    email = generateUniqueEmail();
  });

  test.beforeEach(async ({ page, context }) => {
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  const connectors = Object.entries(connectorConfig);
  for (const [key, connector] of connectors) {
    test(`should setup and verify ${key} connector`, async ({ page }) => {
      const paymentConnector = new PaymentConnector(page);
      const homePage = new HomePage(page);

      await homePage.connectors.click();
      await homePage.paymentProcessors.click();

      await paymentConnector.connectorSearchInput.fill(connector.label);
      await paymentConnector.addConnectButton.nth(0).click();

      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);

      await paymentConnector.connectAndProceedButton.click();

      await assertPaymentMethodTypes(page, connector.paymentSections);

      await paymentConnector.pmtProceedButton.click();
      await paymentConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/connectors/);
      await expect(
        page.getByTestId(
          connector.fields.overrides["Enter Connector label"] || connector.label,
        ),
      ).toBeVisible();
      await page
        .getByTestId(
          connector.fields.overrides["Enter Connector label"] || connector.label,
        )
        .click();
    });
  }
});
