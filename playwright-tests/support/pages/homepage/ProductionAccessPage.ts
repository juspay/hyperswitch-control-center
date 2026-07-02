import { Page, Locator } from "@playwright/test";

export class ProductionAccessPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get header(): Locator {
    return this.page.getByText("Get access to Live environment");
  }

  get submitButton(): Locator {
    return this.page.getByRole("button", { name: "Get Production Access" });
  }

  get legalBusinessNameInput(): Locator {
    return this.page.getByRole("textbox", { name: "Eg: HyperSwitch Pvt Ltd" });
  }

  get selectCountryButton(): Locator {
    return this.page.getByRole("button", { name: "Select Country" });
  }

  get websiteInput(): Locator {
    return this.page.getByRole("textbox", { name: "Enter a website" });
  }

  get contactNameInput(): Locator {
    return this.page.getByRole("textbox", { name: "Eg: Jack Ryan" });
  }

  get contactEmailInput(): Locator {
    return this.page.getByRole("textbox", {
      name: "Eg: jackryan@hyperswitch.io",
    });
  }

  get successMessage(): Locator {
    return this.page.getByText("Successfully sent for verification!");
  }

  get legalBusinessNameLabel(): Locator {
    return this.page.getByText("Legal Business Name *");
  }

  get businessCountryLabel(): Locator {
    return this.page.getByText("Business country *");
  }

  get businessWebsiteLabel(): Locator {
    return this.page.getByText("Business Website *");
  }

  get contactNameLabel(): Locator {
    return this.page.getByText("Contact Name *");
  }

  get contactEmailLabel(): Locator {
    return this.page.getByText("Contact Email *");
  }

  get invalidUrlError(): Locator {
    return this.page.getByText("Please enter a valid URL");
  }

  get invalidEmailError(): Locator {
    return this.page.getByText("Please enter a valid email address");
  }

  get countryOption(): Locator {
    return this.page.getByRole('menuitem', { name: 'Aland Islands' });
  }
}

export default ProductionAccessPage;
