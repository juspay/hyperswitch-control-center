import { test, expect } from "../../support/test";
import type { BrowserContext, Page, Request } from "@playwright/test";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Offers } from "../../support/pages/developers/Offers";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

type CredentialSource = "merchant" | "application" | "none";

const OFFER_LIST_COLUMNS = [
  "Offer Code",
  "Offer Title",
  "Status",
  "Benefit",
  "Start and End Time",
  "Created",
  "Actions",
];

const mockOffer = {
  offer_id: "offer_playwright_001",
  offer_code: "PLAYWRIGHT10",
  status: "ACTIVE",
  offer_description: {
    title: "Get 10% off with Playwright",
    display_title: "10% off",
  },
  start_time: "2026-10-01T00:00:00Z",
  end_time: "2026-12-31T23:59:59Z",
  created_at: "2026-10-01T00:00:00Z",
  rule_dsl: {
    benefits: [{ type: "DISCOUNT", calculation_rule: "PERCENTAGE", value: 10 }],
  },
};

const isUserInfoUrl = (url: URL) => url.pathname.endsWith("/user");

const isOffersListUrl = (url: URL) =>
  url.pathname.endsWith("/offers/dashboard/dashboard-list");

function isOffersList(request: Request): boolean {
  return request.method() === "POST" && isOffersListUrl(new URL(request.url()));
}

// Overrides only offer_engine_credential_source on the real /user response,
// which decides between the real Offers pages and the demo landing.
async function setCredentialSource(page: Page, source: CredentialSource) {
  await page.route(isUserInfoUrl, async (route) => {
    if (route.request().method() !== "GET") return route.fallback();
    const response = await route.fetch();
    const json = await response.json();
    json.offer_engine_credential_source = source;
    await route.fulfill({ response, json });
  });
}

// The local backend has no offer engine, so the list is always mocked.
async function mockOffersList(page: Page, list = [mockOffer]) {
  await page.route(isOffersListUrl, (route) =>
    route.fulfill({
      json: { summary: { total_count: list.length }, list },
    }),
  );
}

async function signupAndLogin(
  page: Page,
  context: BrowserContext,
  source: CredentialSource,
) {
  await setCredentialSource(page, source);
  await mockOffersList(page);
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function openOffersFromSidebar(page: Page) {
  const homePage = new HomePage(page);
  const offers = new Offers(page);
  await homePage.developer.click();
  await expect(offers.sidebarLink).toBeVisible();
  await offers.sidebarLink.click();
  await expect(page).toHaveURL(/.*dashboard\/offers$/);
  await expect(offers.subtitle).toBeVisible();
  return offers;
}

async function expectCreateFormElements(offers: Offers) {
  await expect(offers.createPageHeading).toBeVisible();
  await expect(offers.breadcrumbOffersLink.first()).toBeVisible();

  for (const section of [
    "Offer Details",
    "Transaction Level Details",
    "Payment Details",
  ]) {
    await expect(offers.sectionTitle(section)).toBeVisible();
  }

  for (const label of [
    "Offer Code",
    "Offer Title",
    "Offer Display Title",
    "Language",
    "Offer Description",
    "Terms and Conditions",
    "Offer Validity",
    "Discount Type",
    "Discount Value",
    "Maximum Discount Amount",
    "Offer Campaign Amount",
    "Offer Campaign Count",
    "Currencies",
    "Amount Per Unique Card",
    "Offer Count Per Unique Card",
    "Card BIN List",
  ]) {
    await expect(offers.fieldLabel(label)).toBeVisible();
  }

  for (const input of [
    offers.offerCodeInput,
    offers.titleInput,
    offers.displayTitleInput,
    offers.descriptionInput,
    offers.tncInput,
    offers.benefitValueInput,
    offers.maxAmountInput,
    offers.campaignAmountInput,
    offers.campaignCountInput,
    offers.amountPerCardInput,
    offers.countPerCardInput,
  ]) {
    await expect(input).toBeVisible();
    await expect(input).toBeEditable();
    await expect(input).toHaveValue("");
  }

  // Transaction amounts are per currency, so none render until one is picked.
  await expect(offers.minOrderAmountInput).toHaveCount(0);
  await expect(offers.maxOrderAmountInput).toHaveCount(0);

  // Language, Discount Type and the per card period are pre-filled;
  // Currencies starts empty.
  await expect(offers.languageSelect).toBeVisible();
  await expect(offers.discountTypeSelect).toBeVisible();
  await expect(offers.currencySelect).toBeVisible();
  await expect(offers.cardResetPeriodSelect).toBeVisible();
  await expect(offers.validitySelect).toBeVisible();

  await expect(offers.binListDescription).toBeVisible();
  await expect(offers.chooseFileButton).toBeVisible();
  await expect(offers.downloadSampleButton).toBeVisible();
  await expect(offers.binFileInput).toBeHidden();
  await expect(offers.removeFileButton).toHaveCount(0);

  await expect(offers.createOfferButton).toBeVisible();
}

async function fillCreateOfferForm(page: Page, offers: Offers) {
  await offers.offerCodeInput.fill("PLAYWRIGHT10");
  await offers.titleInput.fill("Get 10% off with Playwright");
  await offers.displayTitleInput.fill("10% off");
  await offers.descriptionInput.fill(
    "Get 10% discount upto 200 for transactions of 1000 and above",
  );

  await offers.validityPresetSelect.click();
  await offers.validityPreset("Next month").click();
  // Once a range is picked the button no longer shows its placeholder.
  await expect(
    page.getByText("Select date range", { exact: true }),
  ).toHaveCount(0);

  await offers.benefitValueInput.fill("10");
  await offers.maxAmountInput.fill("200");
  await offers.campaignAmountInput.fill("10000");
  await offers.campaignCountInput.fill("1000");

  await offers.currencySelect.click();
  await offers.currencySearchInput.fill("USD");
  await offers.currencyOption("USD").click();
  await page.keyboard.press("Escape");
  await expect(offers.currencySelect).toHaveCount(0);

  // Picking a currency renders its own transaction amount fields.
  await expect(
    offers.fieldLabel("Minimum Transaction Amount (USD)"),
  ).toBeVisible();
  await expect(
    offers.fieldLabel("Maximum Transaction Amount (USD)"),
  ).toBeVisible();

  await offers.minOrderAmountInput.fill("1000");
  await offers.maxOrderAmountInput.fill("10000");
  await offers.amountPerCardInput.fill("500");
  await offers.countPerCardInput.fill("2");

  await offers.binFileInput.setInputFiles({
    name: "card_bins.csv",
    mimeType: "text/csv",
    buffer: Buffer.from("CARD_BIN\n411111\n555555"),
  });
  await expect(offers.uploadedBinFile("card_bins.csv", 2)).toBeVisible();
  await expect(offers.removeFileButton).toBeVisible();
}

test.describe("Offers", () => {
  test.describe("Sidebar and credential source", () => {
    for (const source of ["merchant", "application"] as const) {
      test(`should show Offers in the sidebar and open the real offers list when offer_engine_credential_source is "${source}"`, async ({
        page,
        context,
      }) => {
        await signupAndLogin(page, context, source);
        const [listRequest] = await Promise.all([
          page.waitForRequest(isOffersList),
          openOffersFromSidebar(page),
        ]);
        const offers = new Offers(page);

        expect(listRequest.postDataJSON()).toMatchObject({
          limit: 10,
          offset: 0,
        });
        await expect(offers.searchOfferCodeInput).toBeVisible();
        await expect(offers.tableRows).toHaveCount(1);
        await expect(offers.tableRows.first()).toContainText(
          mockOffer.offer_code,
        );
        await expect(offers.demoBanner).toHaveCount(0);
      });
    }

    test('should show Offers in the sidebar and open the demo landing when offer_engine_credential_source is "none"', async ({
      page,
      context,
    }) => {
      await signupAndLogin(page, context, "none");
      let listRequested = false;
      page.on("request", (request) => {
        if (isOffersList(request)) listRequested = true;
      });
      const offers = await openOffersFromSidebar(page);

      await expect(offers.demoBanner).toBeVisible();
      await expect(offers.searchOfferCodeInput).toHaveCount(0);
      await expect(offers.tableRows).toHaveCount(0);
      expect(listRequested).toBe(false);
    });
  });

  test.describe("Demo mode", () => {
    test.beforeEach(async ({ page, context }) => {
      await signupAndLogin(page, context, "none");
      await openOffersFromSidebar(page);
    });

    test("should display all elements of the demo landing page", async ({
      page,
    }) => {
      const offers = new Offers(page);

      await expect(offers.pageHeading).toBeVisible();
      await expect(offers.subtitle).toBeVisible();
      await expect(offers.createNewOfferButton).toBeVisible();
      await expect(offers.createNewOfferButton).toBeEnabled();
      await expect(offers.demoBanner).toBeVisible();
      await expect(offers.demoBannerSlackLink).toBeVisible();
      await expect(offers.demoBannerSlackLink).toHaveAttribute(
        "href",
        "https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect",
      );
      await expect(offers.demoBannerSlackLink).toHaveAttribute(
        "target",
        "_blank",
      );

      // The real list's search, filters and table are not rendered.
      await expect(offers.searchOfferCodeInput).toHaveCount(0);
      for (const column of OFFER_LIST_COLUMNS) {
        await expect(offers.tableHeading(column)).toHaveCount(0);
      }
      await expect(offers.noOffersFound).toHaveCount(0);
    });

    test("should open the create offer form from the demo landing and display all its elements", async ({
      page,
    }) => {
      const offers = new Offers(page);

      await offers.createNewOfferButton.click();
      await expect(page).toHaveURL(/.*dashboard\/offers\/new$/);

      await expect(offers.demoBanner).toBeVisible();
      await expectCreateFormElements(offers);
      // Demo mode cannot create offers.
      await expect(offers.createOfferButton).toBeDisabled();
    });
  });

  test.describe("Offer engine enabled", () => {
    test("should open the create offer form from the offers list, display all its elements and enable Create Offer once every field is filled", async ({
      page,
      context,
    }) => {
      await signupAndLogin(page, context, "merchant");
      const offers = await openOffersFromSidebar(page);
      await expect(offers.tableRows).toHaveCount(1);
      for (const column of OFFER_LIST_COLUMNS) {
        await expect(offers.tableHeading(column)).toBeVisible();
      }

      await expect(offers.createNewOfferButton).toBeVisible();
      await offers.createNewOfferButton.click();
      await expect(page).toHaveURL(/.*dashboard\/offers\/new$/);

      await expect(offers.demoBanner).toHaveCount(0);
      await expectCreateFormElements(offers);
      // Required fields are empty, so the form has validation errors.
      await expect(offers.createOfferButton).toBeDisabled();

      await fillCreateOfferForm(page, offers);
      await expect(offers.createOfferButton).toBeEnabled();
    });
  });
});
