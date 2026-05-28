import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

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

  test("should open search modal with focused input when search bar is clicked", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchModalInput).toBeVisible();
    await expect(homePage.globalSearchModalInput).toBeFocused();
  });

  test("should close search modal when Esc button is clicked", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchModalInput).toBeVisible();
    await homePage.globalSearchEscButton.click();
    await expect(homePage.globalSearchModalInput).not.toBeVisible();
  });

  test("should clear search results when search input is cleared", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("payment");
    await expect(homePage.globalSearchGoToHeader).toBeVisible();
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

test.describe("Global Search Results", () => {
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

  test("should show local navigation results under GO TO section when typing in search bar", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("payment");
    await expect(homePage.globalSearchGoToHeader).toBeVisible();
    await expect(homePage.globalSearchShowAllResults).toBeVisible();
  });

  test("should show remote payment results from API when user has OperationsView access", async ({ page }) => {
    await page.route("**/analytics/v1/search", async (route) => {
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify(MOCK_PAYMENT_SEARCH_RESPONSE) });
    });
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("pay_mock");
    await expect(homePage.globalSearchSectionHeader("PAYMENT ATTEMPTS")).toBeVisible({ timeout: 10000 });
    await expect(page.getByText("pay_mock_test_123").first()).toBeVisible();
  });

  test("should redirect to payments page when a local navigation result is clicked", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("payment");
    await expect(homePage.globalSearchGoToHeader).toBeVisible();
    await page.getByText("Payments").first().click();
    await expect(page).toHaveURL(/.*dashboard\/payments/);
  });

  test("should display loading indicator while fetching remote search results", async ({ page }) => {
    let resolveSearch: () => void = () => {};
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
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify(MOCK_MULTI_CATEGORY_SEARCH_RESPONSE) });
    });
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("multi");
    await expect(homePage.globalSearchSectionHeader("PAYMENT ATTEMPTS")).toBeVisible({ timeout: 10000 });
    await expect(homePage.globalSearchSectionHeader("REFUNDS")).toBeVisible({ timeout: 10000 });
  });
});

test.describe("Global Search Filters", () => {
  test("should show filter controls when globalSearchFilters feature flag is enabled", async ({ page }) => {
    const filterEmail = generateUniqueEmail();
    await signupUser(filterEmail, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = true;
        json.features.global_search_filters = true;
      }
      await route.fulfill({ response, json });
    });
    await page.route("**/analytics/v1/**/filters/payments", async (route) => {
      await route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify(MOCK_FILTER_RESPONSE) });
    });
    await loginUI(page, filterEmail, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchSuggestedFiltersHeader).toBeVisible({ timeout: 10000 });
  });

  test("should not show filter controls when globalSearchFilters feature flag is disabled", async ({ page }) => {
    const noFilterEmail = generateUniqueEmail();
    await signupUser(noFilterEmail, PLAYWRIGHT_PASSWORD);
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = true;
        json.features.global_search_filters = false;
      }
      await route.fulfill({ response, json });
    });
    await loginUI(page, noFilterEmail, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await expect(homePage.globalSearchSuggestedFiltersHeader).not.toBeAttached();
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
      }
      await route.fulfill({ response, json });
    });
    await loginUI(page, validEmail, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.globalSearchInput.click();
    await homePage.globalSearchModalInput.fill("foo bar baz");
    await expect(homePage.globalSearchValidationError).toBeVisible();
  });
});
