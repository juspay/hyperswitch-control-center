import { Page, Locator } from "@playwright/test";

export class Offers {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async visit() {
    await this.page.goto("/dashboard/offers");
  }

  async visitCreate() {
    await this.page.goto("/dashboard/offers/new");
  }

  get sidebarLink(): Locator {
    return this.page.getByTestId("offers");
  }

  // Landing page (shared by the demo landing and the real list)

  // The title also appears as the sidebar link, so the subtitle anchors it.
  get subtitle(): Locator {
    return this.page.getByText("View and manage offers for this merchant", {
      exact: true,
    });
  }

  get pageHeading(): Locator {
    return this.subtitle.locator("..").getByText("Offers", { exact: true });
  }

  get createNewOfferButton(): Locator {
    return this.page.getByRole("button", {
      name: "Create New Offer",
      exact: true,
    });
  }

  get demoBanner(): Locator {
    return this.page.getByText(
      "You are viewing Offers in demo mode. To enable this feature for your merchant account, please reach out to us on",
    );
  }

  // The banner's alert hides its slotted content from the accessibility
  // tree, so the link isn't reachable by role.
  get demoBannerSlackLink(): Locator {
    return this.page.locator('a[href*="hyperswitch-io.slack.com"]');
  }

  // Real list page

  get searchOfferCodeInput(): Locator {
    return this.page.getByPlaceholder("Search Offer Code");
  }

  get tableRows(): Locator {
    return this.page.locator('tr:has([data-table-location^="Offers_tr"])');
  }

  get noOffersFound(): Locator {
    return this.page.getByText("No offers found", { exact: true });
  }

  tableHeading(heading: string): Locator {
    return this.page.locator(`[data-table-heading="${heading}"]`);
  }

  // Create offer form

  get createPageHeading(): Locator {
    return this.page.getByText("Create a New Offer", { exact: true }).first();
  }

  get breadcrumbOffersLink(): Locator {
    return this.page
      .getByText("Offers", { exact: true })
      .locator("visible=true");
  }

  sectionTitle(title: string): Locator {
    return this.page.getByText(title, { exact: true });
  }

  // Required field labels end with " *".
  fieldLabel(label: string): Locator {
    const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    return this.page.getByText(new RegExp(`^${escaped}( \\*)?$`));
  }

  // Numeric inputs carry no name attribute, so every input is located by its
  // placeholder.
  input(placeholder: string): Locator {
    return this.page.getByPlaceholder(placeholder, { exact: true });
  }

  get offerCodeInput(): Locator {
    return this.input("Eg. PAYTM50, ICICI10, SWIGGYIT");
  }

  get titleInput(): Locator {
    return this.input("Eg. Get 4% cashback, Get 10x rewards");
  }

  get displayTitleInput(): Locator {
    return this.input("Eg. Get 5% cashback, 10x rewards");
  }

  get descriptionInput(): Locator {
    return this.input(
      "Eg. Get 5% discount upto Rs.200 for transaction of Rs.1000 and above",
    );
  }

  get benefitValueInput(): Locator {
    return this.input("Eg. 10");
  }

  get maxAmountInput(): Locator {
    return this.input("Eg. 200 - Maximum discount given per transaction");
  }

  get campaignAmountInput(): Locator {
    return this.input("Eg. 10000 - Maximum budget is capped for this offer");
  }

  get campaignCountInput(): Locator {
    return this.input(
      "Eg. 1000 - Maximum number of times the offer can be availed",
    );
  }

  get minOrderAmountInput(): Locator {
    return this.input(
      "Eg. 1000 - Minimum cart value to make the offer eligible",
    );
  }

  get maxOrderAmountInput(): Locator {
    return this.input(
      "Eg. 10000 - Maximum cart value for the offer to be eligible",
    );
  }

  get amountPerCardInput(): Locator {
    return this.input("Eg. 500 - Maximum discount amount per unique card");
  }

  get countPerCardInput(): Locator {
    return this.input(
      "Eg. 2 - Maximum times a unique card can avail the offer",
    );
  }

  // Language and Discount Type are pre-filled, so their buttons show the value.
  get languageSelect(): Locator {
    return this.page.getByRole("button", { name: "English", exact: true });
  }

  get discountTypeSelect(): Locator {
    return this.page.getByRole("button", { name: "Percentage", exact: true });
  }

  get currencySelect(): Locator {
    return this.page.getByRole("button", {
      name: "Choose Currency",
      exact: true,
    });
  }

  get validitySelect(): Locator {
    return this.page.getByRole("button", {
      name: "Date range picker, Select date range",
      exact: true,
    });
  }

  get validityPresetSelect(): Locator {
    return this.page.getByRole("button", { name: "Custom", exact: true });
  }

  validityPreset(name: string): Locator {
    return this.page.getByRole("menuitem", { name, exact: true });
  }

  get currencySearchInput(): Locator {
    return this.page.getByRole("searchbox", { name: "Search options..." });
  }

  currencyOption(code: string): Locator {
    return this.page.getByRole("menuitem", { name: code, exact: true });
  }

  uploadedBinFile(fileName: string, binCount: number): Locator {
    return this.page.getByText(`${fileName} - ${binCount} BINs`, {
      exact: true,
    });
  }

  get binListDescription(): Locator {
    return this.page.getByText(
      "Upload a CSV with a CARD_BIN header and one 6 to 9 digit BIN per row (up to 10000). Only the listed BINs will be eligible for this offer.",
      { exact: true },
    );
  }

  get binFileInput(): Locator {
    return this.page.locator('input[type="file"][accept=".csv"]');
  }

  get chooseFileButton(): Locator {
    return this.page.getByRole("button", { name: "Choose File", exact: true });
  }

  get downloadSampleButton(): Locator {
    return this.page.getByRole("button", {
      name: "Download Sample",
      exact: true,
    });
  }

  get removeFileButton(): Locator {
    return this.page.getByRole("button", { name: "Remove", exact: true });
  }

  get createOfferButton(): Locator {
    return this.page.getByRole("button", { name: "Create Offer", exact: true });
  }
}
