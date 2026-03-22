import { Page, Locator } from "@playwright/test";

export class HomePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get enterMerchantName(): Locator {
    return this.page.locator('[name="merchant_name"]');
  }

  get onboardingSubmitButton(): Locator {
    return this.page.locator('[data-button-for="startExploring"]');
  }

  get subHeaderText(): Locator {
    return this.page.locator(
      '[class="opacity-50 mt-2 text-fs-16 text-nd_gray-400 !opacity-100 font-medium !mt-1"]',
    );
  }

  get orgIcon(): Locator {
    return this.page.locator(
      '[class="w-10 h-10 rounded-lg flex items-center justify-center relative cursor-pointer group/parent"]',
    );
  }

  get merchantDropdown(): Locator {
    return this.page.locator('[class="w-fit flex flex-col gap-4"]');
  }

  get profileDropdown(): Locator {
    return this.page.locator('[class="md:max-w-40 max-w-16"]');
  }

  get profileDropdownList(): Locator {
    return this.page.locator(
      '[class="max-h-72 overflow-scroll px-1 pt-1 selectbox-scrollbar"]',
    );
  }

  get orgChartIcon(): Locator {
    return this.page.locator('[data-icon="github-fork"]');
  }

  get merchantID(): Locator {
    return this.page.locator('[style="overflow-wrap: anywhere;"]');
  }

  get globalSearchInput(): Locator {
    return this.page.locator('[class="w-max"]');
  }

  get productionAccessBanner(): Locator {
    return this.page.locator(
      '[class="absolute w-fit max-w-fixedPageWidth bg-white flex flex-col items-center -top-11"]',
    );
  }

  get integrateConnectorCard(): Locator {
    return this.page.locator(
      '[class="relative bg-white  border p-6 rounded flex flex-col justify-between flex-1 rounded-xl p-6 gap-4"]',
    );
  }

  get demoCheckoutCard(): Locator {
    return this.page
      .locator(
        '[class="relative bg-white  border p-6 rounded flex flex-col justify-between flex-1 rounded-xl p-6 gap-4"]',
      )
      .nth(1);
  }

  get operations(): Locator {
    return this.page.locator("[data-testid=operations]");
  }

  get paymentOperations(): Locator {
    return this.page.locator("[data-testid=payments]");
  }

  get connectors(): Locator {
    return this.page.locator("[data-testid=connectors]");
  }

  get paymentProcessors(): Locator {
    return this.page.locator("[data-testid=paymentprocessors]");
  }

  get workflow(): Locator {
    return this.page.locator('[data-testid="workflow"]');
  }

  get routing(): Locator {
    return this.page.locator('[data-testid="routing"]');
  }

  get userAccount(): Locator {
    return this.page.locator('[data-icon="nd-dropdown-menu"]');
  }

  get userProfile(): Locator {
    return this.page.locator('[id="neglectTopbarTheme"]').first().locator(">>");
  }

  get signOut(): Locator {
    return this.page.getByText("Sign out");
  }
}

export default HomePage;
