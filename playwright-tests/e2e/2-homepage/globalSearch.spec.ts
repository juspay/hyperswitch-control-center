import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, mockPaymentFilters } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const MOCK_PAYMENT_SEARCH_RESPONSE = [
  {
    index: "payment_attempts",
    count: 1,
    hits: [
      {
        payment_id: "pay_mock_test_123",
        amount: 10000,
        currency: "USD",
        status: "succeeded",
        profile_id: "pro_mock",
        merchant_id: "mer_mock",
        organization_id: "org_mock",
      },
    ],
  },
];

const MOCK_MULTI_CATEGORY_SEARCH_RESPONSE = [
  {
    index: "payment_attempts",
    count: 1,
    hits: [
      {
        payment_id: "pay_multi_1",
        amount: 10000,
        currency: "USD",
        status: "succeeded",
        profile_id: "pro_mock",
        merchant_id: "mer_mock",
        organization_id: "org_mock",
      },
    ],
  },
  {
    index: "refunds",
    count: 1,
    hits: [
      {
        refund_id: "ref_multi_1",
        refund_amount: 5000,
        currency: "USD",
        refund_status: "succeeded",
        profile_id: "pro_mock",
        merchant_id: "mer_mock",
        organization_id: "org_mock",
      },
    ],
  },
];

const MOCK_REALISTIC_SEARCH_RESPONSE = [
  { index: "payment_attempts", count: 0, hits: [], status: "Success" },
  { index: "payment_intents", count: 0, hits: [], status: "Success" },
  { index: "refunds", count: 0, hits: [], status: "Success" },
  { index: "disputes", count: 0, hits: [], status: "Failure" },
  {
    index: "payouts",
    count: 1,
    hits: [{
      payout_id: "payout_01BNUwJSWD3sDQmbuqi7",
      amount: 4500,
      destination_currency: "USD",
      status: "requires_confirmation",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
    }],
    status: "Success",
  },
  {
    index: "sessionizer_payment_attempts",
    count: 1,
    hits: [{
      payment_id: "pay_0BxZy05aCo5K6X2IFf8y",
      amount: 100,
      currency: "USD",
      status: "authentication_pending",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
    }],
    status: "Success",
  },
  {
    index: "sessionizer_payment_intents",
    count: 1,
    hits: [{
      payment_id: "pay_0BxZy05aCo5K6X2IFf8y",
      amount: 100,
      currency: "USD",
      status: "requires_customer_action",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
    }],
    status: "Success",
  },
  {
    index: "sessionizer_refunds",
    count: 1,
    hits: [{
      refund_id: "ref_SKhG8QDYA27dUZseQE3t",
      refund_amount: 4000,
      currency: "USD",
      refund_status: "success",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
    }],
    status: "Success",
  },
  {
    index: "sessionizer_disputes",
    count: 1,
    hits: [{
      dispute_id: "dp_ijU3BPdgQ2nwBkZaR2Pr",
      dispute_amount: 1040,
      currency: "USD",
      dispute_status: "dispute_accepted",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
    }],
    status: "Success",
  },
];

const MOCK_FILTER_RESPONSE = {
  queryData: [
    { dimension: "status", values: ["succeeded", "failed", "processing"] },
    { dimension: "currency", values: ["USD", "EUR", "GBP"] },
    { dimension: "connector", values: ["stripe", "adyen"] },
  ],
};

test.describe("Global Search Bar", () => {
  let email = "";

  test.beforeEach(async ({ page }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = true;
      }
      await route.fulfill({ response, json });
    });
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should render global search bar when globalSearch feature flag is enabled", async ({ page }) => {
    const homePage = new HomePage(page);
    await expect(homePage.globalSearchInput).toBeVisible();
  });

  test("should open search modal with focused input when search bar is clicked and close it", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchModalInput).toBeVisible();
    await expect(homePage.globalSearchModalInput).toBeFocused();
    await homePage.globalSearchEscButton.click();
    await expect(homePage.globalSearchModalInput).not.toBeVisible();
  });

  test("should clear search results when search input is cleared", async ({ page }) => {
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify([]) });
    });
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("payment");
    await expect(homePage.globalSearchGoToHeader).toBeVisible();
    await expect(page.getByText('Show all results for>payment')).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^GO TO$/ }).first()).toBeVisible();
    await expect(page.getByText('Operations>Payments', { exact: true })).toBeVisible();
    await expect(page.getByText('Operations>Payments>View')).toBeVisible();
    await expect(page.getByText('Connectors>Payment Processors')).toBeVisible();
    await expect(page.getByText('Analytics>Payments')).toBeVisible();
    await expect(page.getByText('Developers>Payment Settings', { exact: true })).toBeVisible();
    await expect(page.getByText('Developers>Payment Settings>')).toBeVisible();
    await homePage.globalSearchModalInput.fill("");
    await expect(homePage.globalSearchGoToHeader).not.toBeVisible();
  });
});

test.describe("Global Search Bar - Feature Flag OFF", () => {
  test("should not render global search bar when globalSearch feature flag is disabled", async ({ page }) => {
    const flagOffEmail = generateUniqueEmail();
    await signupUser(flagOffEmail, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = false;
      }
      await route.fulfill({ response, json });
    });
    await loginUI(page, flagOffEmail, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await expect(homePage.globalSearchInput).not.toBeAttached();
  });
});

test.describe("Global Search Bar - Global search filters ON", () => {
  test("should not render global search bar when globalSearch feature flag is disabled", async ({ page }) => {
    const flagOffEmail = generateUniqueEmail();
    await signupUser(flagOffEmail, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = true;
        json.features.global_search_filters = true;
      }
      await route.fulfill({ response, json });
    });
    await loginUI(page, flagOffEmail, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchModalInput).toBeVisible();
    await expect(page.getByText('SUGGESTED FILTERS')).toBeVisible();
    await expect(page.getByText('payment_method_type : payment_method_type:credit')).toBeVisible();
    await expect(page.getByText('currency : currency:USD')).toBeVisible();
    await expect(page.getByText('connector : connector:stripe')).toBeVisible();
    await expect(page.getByText('customer_email : customer_email:abc@abc.com')).toBeVisible();
    await expect(page.getByText('card_network : card_network:visa')).toBeVisible();
    await expect(page.getByText('card_last_4 : card_last_4:2326')).toBeVisible();
    await expect(page.getByText('status : status:charged')).toBeVisible();
    await expect(page.getByText('payment_id : payment_id:pay_xxxxxxxxx')).toBeVisible();
    await expect(page.getByText('amount : amount:100')).toBeVisible();
  });
});

test.describe("Global Search Results navigation", () => {
  let email = "";

  test.beforeEach(async ({ page }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = true;
      }
      await route.fulfill({ response, json });
    });
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to desired page from search results", async ({ page }) => {
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify([]) });
    });
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("payment");
    await expect(homePage.globalSearchGoToHeader).toBeVisible();
    await page.getByText('Operations>Payments', { exact: true }).click();
    await expect(page).toHaveURL(/.*dashboard\/payments/);

  });

  test("should display loading indicator while fetching remote search results", async ({ page }) => {
    let resolveSearch: () => void = () => { };
    const searchPending = new Promise<void>((resolve) => { resolveSearch = resolve; });
    await page.route("**/analytics/v1/search", async (route) => {
      await searchPending;
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify(MOCK_PAYMENT_SEARCH_RESPONSE) });
    });
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("pay_mock");
    await expect(homePage.globalSearchLoader).toBeVisible({ timeout: 5000 });
    resolveSearch();
  });

  test("should display no results message when search query returns empty response", async ({ page }) => {
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify([]) });
    });
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("xyznonexistentquery");
    await expect(homePage.globalSearchEmptyResult).toBeVisible({ timeout: 10000 });
  });

  test("should display results in separate sections for multiple result categories", async ({ page }) => {
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify(MOCK_REALISTIC_SEARCH_RESPONSE) });
    });
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("USD");
    await expect(homePage.globalSearchSectionHeader("PAYMENT INTENTS")).toBeVisible({ timeout: 10000 });
    await expect(page.getByText('pay_0BxZy05aCo5K6X2IFf8y>1 USD>requires_customer_action')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("PAYMENT ATTEMPTS")).toBeVisible();
    await expect(page.getByText('pay_0BxZy05aCo5K6X2IFf8y>1 USD>authentication_pending')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("REFUNDS")).toBeVisible();
    await expect(page.getByText('ref_SKhG8QDYA27dUZseQE3t>40')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("DISPUTES")).toBeVisible();
    await expect(page.getByText('dp_ijU3BPdgQ2nwBkZaR2Pr>10.4')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("PAYOUTS")).toBeVisible();
    await expect(page.getByText('payout_01BNUwJSWD3sDQmbuqi7>')).toBeVisible();
  });

  test("should navigate to correct details page when clicking different result types in sequence", async ({ page }) => {
    const searchMock = { response: MOCK_MULTI_CATEGORY_SEARCH_RESPONSE as unknown[] };
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify(searchMock.response) });
    });
    const homePage = new HomePage(page);

    // Step 1: click payment result → land on payment details page
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("pay_multi_1");
    await expect(homePage.globalSearchSectionHeader("PAYMENT ATTEMPTS")).toBeVisible({ timeout: 10000 });
    await page.getByText('pay_multi_1>100 USD>succeeded').click();
    await expect(page).toHaveURL(/.*\/payments\/pay_multi_1\/pro_mock\/mer_mock\/org_mock/);

    // Step 2: from payment page, click refund result → land on refund details page
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("ref_multi_1");
    await expect(homePage.globalSearchSectionHeader("REFUNDS")).toBeVisible({ timeout: 10000 });
    await page.getByText('ref_multi_1>50').click();
    await expect(page).toHaveURL(/.*\/refunds\/ref_multi_1\/pro_mock\/mer_mock\/org_mock/);

    // Step 3: from refund page, click dispute result → land on dispute details page
    searchMock.response = MOCK_REALISTIC_SEARCH_RESPONSE;
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("dp_ijU3BPdgQ2nwBkZaR2Pr");
    await expect(homePage.globalSearchSectionHeader("DISPUTES")).toBeVisible({ timeout: 10000 });
    await page.getByText('dp_ijU3BPdgQ2nwBkZaR2Pr>10.4').click();
    await expect(page).toHaveURL(/.*\/disputes\/dp_ijU3BPdgQ2nwBkZaR2Pr\/pro_E6k4XxWE3fVzTIYDMzJa\/Allconnector123\/org_D5BSnrtTuxmW0WrsCXKZH/);

    // Step 4: from dispute page, click payout result → land on payout details page
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("payout_01BNUwJSWD3sDQmbuqi7");
    await expect(homePage.globalSearchSectionHeader("PAYOUTS")).toBeVisible({ timeout: 10000 });
    await page.getByText('payout_01BNUwJSWD3sDQmbuqi7>').click();
    await expect(page).toHaveURL(/.*\/payouts\/payout_01BNUwJSWD3sDQmbuqi7\/pro_E6k4XxWE3fVzTIYDMzJa\/Allconnector123\/org_D5BSnrtTuxmW0WrsCXKZH/);
  });
});

test.describe("Global Search Validation", () => {
  test("should show validation error when multiple free-text search terms are entered", async ({ page }) => {
    const validEmail = generateUniqueEmail();
    await signupUser(validEmail, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = true;
        json.features.global_search_filters = true;
      }
      await route.fulfill({ response, json });
    });
    await loginUI(page, validEmail, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.type("foo bar baz");
    await expect(homePage.globalSearchValidationError).toBeVisible();
    await expect(homePage.globalSearchValidationError).toBeAttached();
  });
});

test.describe("Global Search - Payment Filter Subfilters", () => {
  let email = "";

  test.beforeEach(async ({ page }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json?.features) {
        json.features.global_search = true;
        json.features.global_search_filters = true;
      }
      await route.fulfill({ response, json });
    });
    await mockPaymentFilters(page);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  // Helper: open the search modal, wait for SUGGESTED FILTERS, click a chip,
  // then assert every expected subfilter label is visible.
  async function verifySubfilters(
    page: Page,
    chip: string,
    dimension: string,
    values: string[],
  ): Promise<void> {
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchModalInput).toBeVisible();
    await expect(page.getByText("SUGGESTED FILTERS")).toBeVisible({ timeout: 10000 });
    // Chip text = "{dimension} : {dimension}:{first_value}" (label + placeholder combined)
    await page.getByText(chip).click();
    await expect(page.getByText("SUGGESTED FILTERS")).toBeVisible();
    for (const value of values) {
      await expect(
        page.getByText(`${dimension} : ${value}`, { exact: true }).first(),
      ).toBeVisible({ timeout: 5000 });
    }
  }

  test("should display all connector subfilters", async ({ page }) => {
    await verifySubfilters(
      page,
      "connector : connector:stripe",
      "connector",
      ["stripe", "paypal", "adyen"],
    );
  });

  test("should display all payment_method subfilters", async ({ page }) => {
    await verifySubfilters(
      page,
      "payment_method : payment_method:card",
      "payment_method",
      [
        "card",
        "wallet",
        "bank_redirect",
        "voucher",
        "bank_debit",
        "bank_transfer",
        "card_redirect",
        "pay_later",
        "gift_card",
        "open_banking",
        "real_time_payment",
        "reward",
        "upi",
        "crypto",
        "network_token",
      ],
    );
  });

  test("should display all payment_method_type subfilters", async ({ page }) => {
    await verifySubfilters(
      page,
      "payment_method_type : payment_method_type:debit",
      "payment_method_type",
      [
        "debit",
        "paypal",
        "bancontact_card",
        "credit",
        "klarna",
        "benefit",
        "open_banking_pis",
        "duit_now",
        "classic",
        "blik",
        "pay_safe_card",
        "sepa",
        "upi_collect",
        "pix",
        "boleto",
        "crypto_currency",
        "network_token",
      ],
    );
  });

  test("should display all currency subfilters", async ({ page }) => {
    await verifySubfilters(
      page,
      "currency : currency:USD",
      "currency",
      ["USD", "INR", "EUR", "GBP", "CAD"],
    );
  });

  test("should display all status subfilters", async ({ page }) => {
    await verifySubfilters(
      page,
      "status : status:succeeded",
      "status",
      [
        "succeeded",
        "failed",
        "cancelled",
        "cancelled_post_capture",
        "processing",
        "requires_customer_action",
        "requires_merchant_action",
        "requires_payment_method",
        "requires_confirmation",
        "requires_capture",
        "partially_captured",
        "partially_captured_and_capturable",
        "partially_authorized_and_requires_capture",
        "partially_captured_and_processing",
        "conflicted",
        "expired",
        "review",
      ],
    );
  });

  test("should display all card_network subfilters", async ({ page }) => {
    await verifySubfilters(
      page,
      "card_network : card_network:Visa",
      "card_network",
      [
        "Visa",
        "Mastercard",
        "AmericanExpress",
        "JCB",
        "DinersClub",
        "Discover",
        "CartesBancaires",
        "UnionPay",
        "Interac",
        "RuPay",
        "Maestro",
        "Star",
        "Pulse",
        "Accel",
        "Nyce",
      ],
    );
  });

  test("should apply currency subfilter to search input when a currency value is clicked", async ({ page }) => {
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify(MOCK_REALISTIC_SEARCH_RESPONSE),
      });
    });

    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchModalInput).toBeVisible();
    await expect(page.getByText("SUGGESTED FILTERS")).toBeVisible({ timeout: 10000 });

    // Expand currency subfilters
    await page.getByText("currency : currency:USD").click();
    await expect(page.getByText("currency : USD", { exact: true }).first()).toBeVisible({ timeout: 5000 });

    // Click the "USD" subfilter
    await page.getByText("currency : USD", { exact: true }).first().click();

    // onSuggestionClicked writes "<searchText>USD" into the input (searchText already ends with ":")
    await expect(homePage.globalSearchModalInput).toHaveValue(/currency:USD/, { timeout: 5000 });

    //await expect(page.getByText('Show all results for> currency:USD')).toBeVisible();

    // Verify USD appears in search results for each section
    await expect(homePage.globalSearchSectionHeader("PAYMENT INTENTS")).toBeVisible({ timeout: 10000 });
    await expect(page.getByText('pay_0BxZy05aCo5K6X2IFf8y>1 USD>requires_customer_action')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("PAYMENT ATTEMPTS")).toBeVisible();
    await expect(page.getByText('pay_0BxZy05aCo5K6X2IFf8y>1 USD>authentication_pending')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("REFUNDS")).toBeVisible();
    await expect(page.getByText('ref_SKhG8QDYA27dUZseQE3t>40 USD>success')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("DISPUTES")).toBeVisible();
    await expect(page.getByText('dp_ijU3BPdgQ2nwBkZaR2Pr>10.4 USD>dispute_accepted')).toBeVisible();
    await expect(homePage.globalSearchSectionHeader("PAYOUTS")).toBeVisible();
    await expect(page.getByText('payout_01BNUwJSWD3sDQmbuqi7>45 USD>requires_confirmation')).toBeVisible();
  });
});