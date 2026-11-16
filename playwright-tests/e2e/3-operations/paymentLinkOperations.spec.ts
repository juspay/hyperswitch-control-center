import { test, expect } from "../../support/test";
import type { Page, Response } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentLinkOperations } from "../../support/pages/operations/PaymentLinkOperations";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const API_TIMEOUT = 15000;

type Profile = { profile_id: string; profile_name?: string };
type PaymentLink = {
  payment_link_id: string;
  payment_id: string;
  profile_id: string;
  description: string;
  amount: number;
  currency: string;
  status: string;
  link_to_pay: string;
  created_at: string;
};
type PaymentLinkList = { total_count: number; data: PaymentLink[] };

function isPaginatedList(response: Response): boolean {
  const request = response.request();
  if (
    request.method() !== "POST" ||
    !/\/payment_link\/(?:profile\/)?list$/.test(
      new URL(response.url()).pathname,
    )
  ) {
    return false;
  }
  // RemoteTableFilters posts to this endpoint too, but without pagination.
  const body = request.postDataJSON();
  return body?.offset === 0 && body?.limit === 20;
}

async function setPaymentLinkFlag(page: Page, enabled: boolean) {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features = {
      ...(json.features ?? {}),
      payment_link_operations: enabled,
      dev_blend_enabled: true,
    };
    await route.fulfill({ response, json });
  });
}

function buildPaymentLinks(total: number): PaymentLink[] {
  return Array.from({ length: total }, (_, i) => ({
    payment_link_id: `plink_pw_${String(i + 1).padStart(2, "0")}`,
    payment_id: `pay_pw_${String(i + 1).padStart(2, "0")}`,
    profile_id: "pro_pw",
    description: `PW payment link ${i + 1}`,
    amount: 1000 + i,
    currency: "USD",
    status: "active",
    link_to_pay: `https://example.com/pay/plink_pw_${i + 1}`,
    created_at: "2026-10-01T10:00:00.000Z",
  }));
}

// Serves the paginated list from a fixed set, sliced by the request's
// offset/limit. RemoteTableFilters' unpaginated POST falls through.
async function mockPaymentLinksList(page: Page, links: PaymentLink[]) {
  await page.route(/\/payment_link\/(?:profile\/)?list$/, async (route) => {
    const body = route.request().postDataJSON();
    if (route.request().method() !== "POST" || body?.limit === undefined) {
      return route.fallback();
    }
    const offset: number = body.offset ?? 0;
    const list: PaymentLinkList = {
      total_count: links.length,
      data: links.slice(offset, offset + body.limit),
    };
    await route.fulfill({ json: list });
  });
}

test.describe("Payment Link Operations", () => {
  test.describe("Feature flag", () => {
    test("should hide Payment Link from Operations and block its route when payment_link_operations is OFF", async ({
      page,
      context,
    }) => {
      await setPaymentLinkFlag(page, false);
      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);
      const homePage = new HomePage(page);
      const paymentLinks = new PaymentLinkOperations(page);

      await homePage.operations.click();
      // Sibling links render, so the Operations section is expanded.
      await expect(homePage.paymentOperations).toBeVisible();
      await expect(paymentLinks.sidebarLink).toHaveCount(0);

      await page.goto("/dashboard/payment-links");
      await expect(paymentLinks.unauthorizedMessage).toBeVisible();
      await expect(paymentLinks.subtitle).toHaveCount(0);
      await expect(paymentLinks.createButton).toHaveCount(0);
    });
  });

  test.describe("Payment Link list page", () => {
    let loadedEndTime: string;

    test.beforeEach(async ({ page, context }) => {
      await setPaymentLinkFlag(page, true);
      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);
      const homePage = new HomePage(page);
      const paymentLinks = new PaymentLinkOperations(page);
      await homePage.operations.click();
      const [response] = await Promise.all([
        page.waitForResponse(isPaginatedList, { timeout: API_TIMEOUT }),
        paymentLinks.sidebarLink.click(),
      ]);
      expect(response.ok()).toBeTruthy();
      const list: PaymentLinkList = await response.json();
      expect(list.total_count).toBe(0);
      expect(list.data).toEqual([]);
      loadedEndTime = response.request().postDataJSON().end_time;
    });

    test("should navigate from Operations to an empty Payment Link list and display all its elements", async ({
      page,
    }) => {
      const paymentLinks = new PaymentLinkOperations(page);
      await expect(paymentLinks.sidebarLink).toHaveText("Payment Link");
      await expect(page).toHaveURL(/\/dashboard\/payment-links(?:[?#].*)?$/);
      await expect(paymentLinks.pageHeading).toBeVisible();
      await expect(paymentLinks.subtitle).toBeVisible();
      await expect(paymentLinks.createButton).toBeVisible();
      await expect(paymentLinks.dateSelector).toBeVisible();
      await expect(paymentLinks.emptyState).toBeVisible();
      await expect(paymentLinks.expandSearchButton).toBeVisible();
      await expect(paymentLinks.tableRows).toHaveCount(0);
    });

    test("should display the create-link form fields and cancel without creating a link", async ({
      page,
    }) => {
      const paymentLinks = new PaymentLinkOperations(page);
      const createRequests: string[] = [];
      page.on("request", (request) => {
        if (
          request.method() === "POST" &&
          new URL(request.url()).pathname.endsWith("/payments/payment_link")
        ) {
          createRequests.push(request.url());
        }
      });
      await paymentLinks.createButton.click();
      await expect(paymentLinks.createModal).toBeVisible();
      await expect(paymentLinks.modalHeading).toHaveText("Create Payment Link");
      await expect(paymentLinks.modalDescription).toBeVisible();

      for (const [name, label] of [
        ["amount", "Amount"],
        ["currency", "Currency"],
        ["customer_id", "Customer ID"],
        ["customer_email", "Customer Email ID"],
        ["customer_phone", "Customer Phone Number"],
        ["profile_id", "Profile ID"],
        ["return_url", "Return URL"],
        ["description", "Payment Description"],
        ["setup_future_usage", "Setup Future Usage"],
        ["authentication_type", "Authentication Type"],
      ]) {
        await expect(paymentLinks.fieldWrapper(name)).toBeVisible();
        await expect(paymentLinks.fieldLabel(name, label)).toBeVisible();
      }
      for (const [name, label] of [
        ["amount", "Amount"],
        ["currency", "Currency"],
        ["profile_id", "Profile ID"],
        ["return_url", "Return URL"],
      ]) {
        await expect(paymentLinks.fieldLabel(name, label)).toContainText("*");
      }
      await paymentLinks.currencySelect.click();
      await paymentLinks.option("USD").click();
      await expect(paymentLinks.currencySelect).toContainText("USD");
      await expect(paymentLinks.submitButton).toBeVisible();
      await paymentLinks.cancelButton.click();
      await expect(paymentLinks.createModal).toHaveCount(0);
      await expect(paymentLinks.emptyState).toBeVisible();
      await expect(paymentLinks.tableRows).toHaveCount(0);
      expect(createRequests).toEqual([]);
    });

    test("should create a payment link through the UI and display its table row", async ({
      page,
    }) => {
      const paymentLinks = new PaymentLinkOperations(page);
      const [profilesResponse] = await Promise.all([
        page.waitForResponse(
          (response) =>
            response.request().method() === "GET" &&
            /\/(?:v2\/)?user\/list\/profile$/.test(
              new URL(response.url()).pathname,
            ),
          { timeout: API_TIMEOUT },
        ),
        paymentLinks.createButton.click(),
      ]);
      expect(profilesResponse.ok()).toBeTruthy();
      const profiles: Profile[] = await profilesResponse.json();
      expect(profiles).toHaveLength(1);
      const profile = profiles[0];
      await expect(paymentLinks.createModal).toBeVisible();
      const customerEmail = generateUniqueEmail();
      const description = `PW-5548-${customerEmail}`;
      await paymentLinks.amountInput.fill("12.34");
      await paymentLinks.currencySelect.click();
      await paymentLinks.option("USD").click();
      // The form defaults to the signed-in profile; reselecting it can deselect it.
      await expect(paymentLinks.profileSelect).toContainText(
        profile.profile_name || profile.profile_id,
      );
      await paymentLinks.returnUrlInput.fill("https://example.com/redirect");
      await paymentLinks.customerEmailInput.fill(customerEmail);
      await paymentLinks.customerPhoneInput.fill("9876543210");
      await paymentLinks.descriptionInput.fill(description);
      await paymentLinks.setupFutureUsageSelect.click();
      await paymentLinks.option("on_session").click();
      await paymentLinks.authenticationTypeSelect.click();
      await paymentLinks.option("no_three_ds").click();

      // The post-create refetch bumps end_time to now (rounded up to the
      // second); within the second the list loaded it is unchanged and no
      // refetch fires, so move past the loaded end_time before submitting.
      await expect
        .poll(() => Date.now(), { timeout: 2000 })
        .toBeGreaterThan(Date.parse(loadedEndTime));

      // Match the new record, not an earlier list/filter response racing submission.
      const [created, refreshed] = await Promise.all([
        page.waitForResponse(
          (response) =>
            response.request().method() === "POST" &&
            new URL(response.url()).pathname.endsWith(
              "/payments/payment_link",
            ) &&
            response.request().postDataJSON()?.description === description,
          { timeout: API_TIMEOUT },
        ),
        page.waitForResponse(
          async (response) => {
            if (!isPaginatedList(response) || !response.ok()) return false;
            const list: PaymentLinkList = await response.json();
            return list.data.some((link) => link.description === description);
          },
          { timeout: API_TIMEOUT },
        ),
        expect(paymentLinks.successToast).toBeVisible({ timeout: API_TIMEOUT }),
        paymentLinks.submitButton.click(),
      ]);
      expect(created.ok()).toBeTruthy();
      expect(created.request().postDataJSON()).toEqual({
        amount: 1234,
        currency: "USD",
        profile_id: profile.profile_id,
        return_url: "https://example.com/redirect",
        description,
        setup_future_usage: "on_session",
        authentication_type: "no_three_ds",
        customer: { email: customerEmail, phone: "9876543210" },
      });
      await expect(paymentLinks.createModal).toHaveCount(0);

      const list: PaymentLinkList = await refreshed.json();
      expect(list.total_count).toBe(1);
      const matches = list.data.filter(
        (link) => link.description === description,
      );
      expect(matches).toHaveLength(1);
      const link = matches[0];
      expect(link).toMatchObject({
        profile_id: profile.profile_id,
        amount: 1234,
        currency: "USD",
      });
      for (const value of [
        link.payment_link_id,
        link.payment_id,
        link.status,
        link.link_to_pay,
        link.created_at,
      ]) {
        expect(value).toBeTruthy();
      }

      for (const heading of [
        "S.No",
        "Payment Link ID",
        "Payment ID",
        "Profile ID",
        "Status",
        "Amount",
        "Payment Link URL",
        "Created At",
      ]) {
        await expect(paymentLinks.tableHeading(heading)).toBeVisible();
      }
      await expect(
        paymentLinks.paymentLinkRow(link.payment_link_id),
      ).toHaveCount(1);
      await expect(
        paymentLinks.paymentLinkCell(link.payment_link_id, 1),
      ).toHaveText("1");
      await expect(
        paymentLinks.paymentLinkCell(link.payment_link_id, 2),
      ).toContainText(link.payment_link_id);
      await expect(
        paymentLinks.paymentLinkCell(link.payment_link_id, 3),
      ).toContainText(link.payment_id);
      await expect(
        paymentLinks.paymentLinkCell(link.payment_link_id, 4),
      ).toHaveText(link.profile_id);
      await expect(
        paymentLinks.paymentLinkCell(link.payment_link_id, 5),
      ).toHaveText(link.status.toUpperCase());
      await expect(
        paymentLinks.amountCell(link.payment_link_id, "12.34 USD"),
      ).toBeVisible();
      await expect(
        paymentLinks.paymentLinkUrl(link.payment_link_id),
      ).toHaveAttribute("href", link.link_to_pay);
      await expect(
        paymentLinks.paymentLinkCell(link.payment_link_id, 8),
      ).not.toHaveText("");
      await expect(paymentLinks.emptyState).toHaveCount(0);
    });

    test("should paginate through payment links 20 per page", async ({
      page,
    }) => {
      const paymentLinks = new PaymentLinkOperations(page);
      const links = buildPaymentLinks(25);
      await mockPaymentLinksList(page, links);
      await Promise.all([
        page.waitForResponse(isPaginatedList, { timeout: API_TIMEOUT }),
        page.reload(),
      ]);

      await expect(paymentLinks.tableRows).toHaveCount(20);
      await expect(paymentLinks.paginationInfo).toHaveText("Showing 20");
      await expect(paymentLinks.paginationSummary).toContainText("of 25");
      await expect(
        paymentLinks.paymentLinkRow(links[0].payment_link_id),
      ).toHaveCount(1);
      await expect(
        paymentLinks.paymentLinkCell(links[0].payment_link_id, 1),
      ).toHaveText("1");
      await expect(
        paymentLinks.paymentLinkRow(links[19].payment_link_id),
      ).toHaveCount(1);
      await expect(
        paymentLinks.paymentLinkRow(links[20].payment_link_id),
      ).toHaveCount(0);

      const [secondPage] = await Promise.all([
        page.waitForResponse(
          (response) =>
            /\/payment_link\/(?:profile\/)?list$/.test(
              new URL(response.url()).pathname,
            ) && response.request().postDataJSON()?.offset === 20,
          { timeout: API_TIMEOUT },
        ),
        paymentLinks.paginationPageButton(2).click(),
      ]);
      expect(secondPage.request().postDataJSON()).toMatchObject({
        offset: 20,
        limit: 20,
      });
      await expect(paymentLinks.tableRows).toHaveCount(5);
      await expect(
        paymentLinks.paymentLinkRow(links[20].payment_link_id),
      ).toHaveCount(1);
      await expect(
        paymentLinks.paymentLinkCell(links[20].payment_link_id, 1),
      ).toHaveText("21");
      await expect(
        paymentLinks.paymentLinkRow(links[24].payment_link_id),
      ).toHaveCount(1);
      await expect(
        paymentLinks.paymentLinkRow(links[0].payment_link_id),
      ).toHaveCount(0);

      await paymentLinks.paginationPageButton(1).click();
      await expect(paymentLinks.tableRows).toHaveCount(20);
      await expect(
        paymentLinks.paymentLinkRow(links[0].payment_link_id),
      ).toHaveCount(1);
    });
  });
});
