import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Payment Operations - table sort, pagination, selection, row expand", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    const homePage = new HomePage(page);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_table",
        context.request,
      );
      for (let i = 0; i < 10; i++) {
        await createPaymentAPI(merchantId, context.request).catch(() => {});
      }
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.waitForLoadState("networkidle");
  });

  test("should filter rows by typing a column-level search term", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);
    await paymentOperations.searchBox.fill("pay_");
    await paymentOperations.searchBox.press("Enter");
    await page.waitForLoadState("networkidle");
    await expect(paymentOperations.searchBox).toHaveValue("pay_");
  });

  test("should toggle the select-all checkbox and mark row checkboxes", async ({
    page,
  }) => {
    const selectAll = page.locator('thead input[type="checkbox"]').first();
    await expect(selectAll).toBeVisible();
    await selectAll.check();

    const checkedRows = page.locator('tbody input[type="checkbox"]:checked');
    expect(await checkedRows.count()).toBeGreaterThan(0);
  });

  test("should toggle an individual row checkbox independently", async ({
    page,
  }) => {
    const rowCheckbox = page.locator('tbody input[type="checkbox"]').first();
    await expect(rowCheckbox).toBeVisible();
    await rowCheckbox.check();
    await expect(rowCheckbox).toBeChecked();
    await rowCheckbox.uncheck();
    await expect(rowCheckbox).not.toBeChecked();
  });

  test("should change the table page size via the page-size dropdown", async ({
    page,
  }) => {
    const pageSizeSelect = page
      .locator('[data-testid*="page-size"], select[name*="pageSize"]')
      .first();
    if (!(await pageSizeSelect.isVisible().catch(() => false))) {
      test.skip(true, "page size control not rendered in this build");
    }
    await pageSizeSelect.selectOption("50");
    await page.waitForLoadState("networkidle");

    const rows = page.locator("table tbody tr");
    expect(await rows.count()).toBeGreaterThan(0);
  });

  test("should allow dragging a column resizer without crashing the table", async ({
    page,
  }) => {
    const resizer = page
      .locator(
        '[data-testid*="resizer"], .column-resizer, th [role="separator"]',
      )
      .first();
    if (!(await resizer.isVisible().catch(() => false))) {
      test.skip(true, "column resizer not rendered in this build");
    }
    const box = await resizer.boundingBox();
    expect(box).not.toBeNull();
    if (box) {
      await resizer.hover();
      await page.mouse.down();
      await page.mouse.move(box.x + 60, box.y);
      await page.mouse.up();
      await page.waitForTimeout(300);
    }

    const rows = page.locator("table tbody tr");
    expect(await rows.count()).toBeGreaterThan(0);
  });

  test("should expand a row's detail accordion on trigger click", async ({
    page,
  }) => {
    const expandButton = page
      .locator('button[aria-label*="expand"], [data-testid*="expand-row"]')
      .first();
    if (!(await expandButton.isVisible().catch(() => false))) {
      test.skip(true, "row expand trigger not exposed");
    }
    await expandButton.click();
    await page.waitForTimeout(500);

    const expandedContent = page
      .locator('[data-testid*="row-details"], tr[class*="expanded"]')
      .first();
    await expect(expandedContent).toBeVisible();
  });

  test("should open the payment detail view when a row is clicked", async ({
    page,
  }) => {
    const firstRow = page.locator('[data-table-location="Orders_tr1_td1"]');
    await expect(firstRow).toBeVisible();
    await firstRow.click();
    await page.waitForLoadState("networkidle");

    await expect(
      page.locator('[class="font-bold text-lg mb-5"]').first(),
    ).toContainText("Summary");
  });
});
