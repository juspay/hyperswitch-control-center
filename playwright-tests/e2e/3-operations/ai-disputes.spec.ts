import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { DisputesOperations } from "../../support/pages/operations/DisputesOperations";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Disputes list page", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await page.waitForURL(/dashboard\/disputes/, { timeout: 15000 });
    await page.waitForLoadState("networkidle");
  });

  test("should display disputes heading, subtitle, search, and empty state", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);
    const paymentOperations = new PaymentOperations(page);

    await expect(page.getByText("Disputes").first()).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByText(/View and manage all disputes/i),
    ).toBeVisible({ timeout: 10000 });
    await expect(disputesOperations.searchInput).toBeVisible({ timeout: 10000 });
    await expect(page.getByText("No results found")).toBeVisible({
      timeout: 10000,
    });
    await expect(paymentOperations.expandSearch90Days).toBeVisible({
      timeout: 10000,
    });
  });

  test("should display date range selector, filter button, and 4-column transaction grid", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);
    const disputesOperations = new DisputesOperations(page);

    await expect(paymentOperations.dateSelector).toBeVisible({ timeout: 10000 });
    await expect(paymentOperations.addFilters).toBeVisible({
      timeout: 10000,
    });

    await expect(disputesOperations.fourColumnGrid).toBeVisible({
      timeout: 10000,
    });
  });

  test("should open filter dropdown and show filter options", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);
    const disputesOperations = new DisputesOperations(page);

    await paymentOperations.addFilters.click();
    await expect(disputesOperations.filterDropdown).toBeVisible({
      timeout: 10000,
    });
  });

  test("should keep URL /dashboard/disputes after reload and search non-matching id", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);

    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/disputes/);

    await disputesOperations.searchInput.fill("dp_nonexistent_zzz");
    await disputesOperations.searchInput.press("Enter");
    await expect(page.getByText("No results found")).toBeVisible({
      timeout: 10000,
    });
    await expect(page).toHaveURL(/.*dashboard\/disputes/);
  });
});
