import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, mockPaymentFilters, ompLineage } from "../../support/commands";

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
  { index: "disputes", count: 0, hits: [], status: "Success" },
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

const MOCK_SEARCH_PAGE_RESPONSE = [
  { index: "payment_attempts", count: 0, hits: [], status: "Success" },
  { index: "payment_intents", count: 0, hits: [], status: "Success" },
  { index: "refunds", count: 0, hits: [], status: "Success" },
  { index: "disputes", count: 0, hits: [], status: "Success" },
  {
    index: "payouts",
    count: 1,
    hits: [{
      payout_id: "payout_01BNUwJSWD3sD",
      payout_attempt_id: "payout_01BNUwJSWD3sDQmbuqi7_1",
      amount: 4500,
      destination_currency: "USD",
      status: "requires_confirmation",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      created_at: 1774863532,
    }],
    status: "Success",
  },
  {
    index: "sessionizer_payment_attempts",
    count: 1,
    hits: [{
      payment_id: "pay_0BxZy05aCo5K6X2I",
      amount: 100,
      currency: "USD",
      status: "authentication_pending",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      connector: "adyen",
      payment_method: "wallet",
      payment_method_type: "paypal",
      created_at: 1774863532,
    }],
    status: "Success",
  },
  {
    index: "sessionizer_payment_intents",
    count: 1,
    hits: [{
      payment_id: "pay_0BxZy05aCo5K6X2I",
      amount: 100,
      currency: "USD",
      status: "requires_customer_action",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      active_attempt_id: "pay_0BxZy05aCo5K6X2IFf8y_1",
      business_country: null,
      business_label: null,
      attempt_count: 1,
      created_at: 1774863532,
    }],
    status: "Success",
  },
  {
    index: "sessionizer_refunds",
    count: 1,
    hits: [{
      refund_id: "ref_SKhG8QDYA27dUZse",
      payment_id: "pay_aHbu98KulzfsPGGQ9qcv",
      refund_status: "success",
      total_amount: 6500,
      currency: "USD",
      connector: "fiservcommercehub",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      created_at: 1774863532,
    }],
    status: "Success",
  },
  {
    index: "sessionizer_disputes",
    count: 1,
    hits: [{
      dispute_id: "dp_ijU3BPdgQ2nwBkZaR",
      payment_id: "pay_jPCuCQ9UUmVZxYVpwXM5",
      dispute_status: "dispute_accepted",
      dispute_amount: 1040,
      currency: "USD",
      connector: "checkout",
      merchant_id: "Allconnector123",
      organization_id: "org_D5BSnrtTuxmW0WrsCXKZH",
      profile_id: "pro_E6k4XxWE3fVzTIYDMzJa",
      created_at: 1774863532,
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
    await expect(homePage.globalSearchModalInput).toHaveValue(/currency:/, { timeout: 5000 });
    await page.waitForTimeout(500);

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

  test("should display categorized search results on search page when Show all results is clicked for currency filter", async ({ page }) => {
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify(MOCK_SEARCH_PAGE_RESPONSE),
      });
    });

    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchModalInput).toBeVisible();

    await homePage.globalSearchModalInput.fill("USD");

    await expect(page.getByText('Show all results for>USD')).toBeVisible();

    await page.getByText('Show all results for>USD').click();

    // Search results page heading and all 5 Download buttons visible
    await expect(page.getByText("Search results")).toBeVisible({ timeout: 10000 });
    await expect(page.getByText("Download (1 records)", { exact: true })).toHaveCount(5, { timeout: 10000 });

    // Payment Intents — columns then row values in order (table[id="table"] nth(0))
    const piTable = page.locator('table[id="table"]').nth(0);
    await expect(piTable.locator('thead th').nth(0)).toContainText('Payment ID');
    await expect(piTable.locator('thead th').nth(1)).toContainText('Merchant ID');
    await expect(piTable.locator('thead th').nth(2)).toContainText('Status');
    await expect(piTable.locator('thead th').nth(3)).toContainText('Amount');
    await expect(piTable.locator('thead th').nth(4)).toContainText('Currency');
    await expect(piTable.locator('thead th').nth(5)).toContainText('Active Attempt ID');
    await expect(piTable.locator('thead th').nth(6)).toContainText('Business Country');
    await expect(piTable.locator('thead th').nth(7)).toContainText('Business Label');
    await expect(piTable.locator('thead th').nth(8)).toContainText('Attempt Count');
    await expect(piTable.locator('thead th').nth(9)).toContainText('Created At');
    const piRow = piTable.locator('tbody tr').first();
    await expect(piRow.locator('td').nth(0)).toContainText('pay_0BxZy05aCo5K6X2I');
    await expect(piRow.locator('td').nth(1)).toContainText('Allconnector123');
    await expect(piRow.locator('td').nth(2)).toContainText('REQUIRES_CUSTOMER_ACTION');
    await expect(piRow.locator('td').nth(3)).toContainText('1 USD');
    await expect(piRow.locator('td').nth(4)).toContainText('USD');
    await expect(piRow.locator('td').nth(6)).toContainText('NA');
    await expect(piRow.locator('td').nth(7)).toContainText('NA');
    await expect(piRow.locator('td').nth(8)).toContainText('1');
    await expect(piRow.locator('td').nth(9)).toContainText('Mar 30, 2026 03:08:52 PM IST');

    // Payment Attempts — columns then row values in order (table[id="table"] nth(1))
    const paTable = page.locator('table[id="table"]').nth(1);
    await expect(paTable.locator('thead th').nth(0)).toContainText('Payment ID');
    await expect(paTable.locator('thead th').nth(1)).toContainText('Merchant ID');
    await expect(paTable.locator('thead th').nth(2)).toContainText('Status');
    await expect(paTable.locator('thead th').nth(3)).toContainText('Amount');
    await expect(paTable.locator('thead th').nth(4)).toContainText('Currency');
    await expect(paTable.locator('thead th').nth(5)).toContainText('Connector');
    await expect(paTable.locator('thead th').nth(6)).toContainText('Payment Method');
    await expect(paTable.locator('thead th').nth(7)).toContainText('Payment Method Type');
    await expect(paTable.locator('thead th').nth(8)).toContainText('Created At');
    const paRow = paTable.locator('tbody tr').first();
    await expect(paRow.locator('td').nth(0)).toContainText('pay_0BxZy05aCo5K6X2I');
    await expect(paRow.locator('td').nth(1)).toContainText('Allconnector123');
    await expect(paRow.locator('td').nth(2)).toContainText('AUTHENTICATION_PENDING');
    await expect(paRow.locator('td').nth(3)).toContainText('1 USD');
    await expect(paRow.locator('td').nth(4)).toContainText('USD');
    await expect(paRow.locator('td').nth(5)).toContainText('adyen');
    await expect(paRow.locator('td').nth(6)).toContainText('wallet');
    await expect(paRow.locator('td').nth(7)).toContainText('paypal');
    await expect(paRow.locator('td').nth(8)).toContainText('Mar 30, 2026 03:08:52 PM IST');

    // Payouts — columns then row values in order (table[id="table"] nth(2))
    const poTable = page.locator('table[id="table"]').nth(2);
    await expect(poTable.locator('thead th').nth(0)).toContainText('Payout ID');
    await expect(poTable.locator('thead th').nth(1)).toContainText('Payout Attempt ID');
    await expect(poTable.locator('thead th').nth(2)).toContainText('Amount');
    await expect(poTable.locator('thead th').nth(3)).toContainText('Destination Currency');
    await expect(poTable.locator('thead th').nth(4)).toContainText('Status');
    await expect(poTable.locator('thead th').nth(5)).toContainText('Connector');
    await expect(poTable.locator('thead th').nth(6)).toContainText('Created At');
    const poRow = poTable.locator('tbody tr').first();
    await expect(poRow.locator('td').nth(0)).toContainText('payout_01BNUwJSWD3sD');
    await expect(poRow.locator('td').nth(1)).toContainText('payout_01BNUwJSWD3sDQmbuqi7_1');
    await expect(poRow.locator('td').nth(2)).toContainText('45 USD');
    await expect(poRow.locator('td').nth(3)).toContainText('USD');
    await expect(poRow.locator('td').nth(4)).toContainText('REQUIRES_CONFIRMATION');
    await expect(poRow.locator('td').nth(5)).toContainText('NA');
    await expect(poRow.locator('td').nth(6)).toContainText('Mar 30, 2026 03:08:52 PM IST');

    // Refunds — columns then row values in order (table[id="table"] nth(3))
    const rfTable = page.locator('table[id="table"]').nth(3);
    await expect(rfTable.locator('thead th').nth(0)).toContainText('Refund ID');
    await expect(rfTable.locator('thead th').nth(1)).toContainText('Payment ID');
    await expect(rfTable.locator('thead th').nth(2)).toContainText('Refund Status');
    await expect(rfTable.locator('thead th').nth(3)).toContainText('Total Amount');
    await expect(rfTable.locator('thead th').nth(4)).toContainText('Currency');
    await expect(rfTable.locator('thead th').nth(5)).toContainText('Connector');
    await expect(rfTable.locator('thead th').nth(6)).toContainText('Created At');
    const rfRow = rfTable.locator('tbody tr').first();
    await expect(rfRow.locator('td').nth(0)).toContainText('ref_SKhG8QDYA27dUZse');
    await expect(rfRow.locator('td').nth(1)).toContainText('pay_aHbu98KulzfsPGGQ9qcv');
    await expect(rfRow.locator('td').nth(2)).toContainText('SUCCESS');
    await expect(rfRow.locator('td').nth(3)).toContainText('65 USD');
    await expect(rfRow.locator('td').nth(4)).toContainText('USD');
    await expect(rfRow.locator('td').nth(5)).toContainText('fiservcommercehub');
    await expect(rfRow.locator('td').nth(6)).toContainText('Mar 30, 2026 03:08:52 PM IST');

    // Disputes — columns then row values in order (table[id="table"] nth(4))
    const dpTable = page.locator('table[id="table"]').nth(4);
    await expect(dpTable.locator('thead th').nth(0)).toContainText('Dispute ID');
    await expect(dpTable.locator('thead th').nth(1)).toContainText('Payment ID');
    await expect(dpTable.locator('thead th').nth(2)).toContainText('Dispute Status');
    await expect(dpTable.locator('thead th').nth(3)).toContainText('Dispute Amount');
    await expect(dpTable.locator('thead th').nth(4)).toContainText('Currency');
    await expect(dpTable.locator('thead th').nth(5)).toContainText('Connector');
    await expect(dpTable.locator('thead th').nth(6)).toContainText('Created At');
    const dpRow = dpTable.locator('tbody tr').first();
    await expect(dpRow.locator('td').nth(0)).toContainText('dp_ijU3BPdgQ2nwBkZaR');
    await expect(dpRow.locator('td').nth(1)).toContainText('pay_jPCuCQ9UUmVZxYVpwXM5');
    await expect(dpRow.locator('td').nth(2)).toContainText('DISPUTE_ACCEPTED');
    await expect(dpRow.locator('td').nth(3)).toContainText('10.4 USD');
    await expect(dpRow.locator('td').nth(4)).toContainText('USD');
    await expect(dpRow.locator('td').nth(5)).toContainText('checkout');
    await expect(dpRow.locator('td').nth(6)).toContainText('Mar 30, 2026 03:08:52 PM IST');
  });
});