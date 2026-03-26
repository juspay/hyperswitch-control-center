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

  get homeV2(): Locator {
    return this.page.locator('[href="/dashboard/v2/home"]');
  }

  get users(): Locator {
    return this.page.locator('[href="/dashboard/users"]');
  }

  get operations(): Locator {
    return this.page.locator("[data-testid=operations]");
  }

  get paymentOperations(): Locator {
    return this.page.locator("[data-testid=payments]");
  }

  get refundOperations(): Locator {
    return this.page.locator('[data-testid="refunds"]');
  }

  get disputesOperations(): Locator {
    return this.page.locator('[data-testid="disputes"]');
  }

  get payoutsOperations(): Locator {
    return this.page.locator('[data-testid="payouts"]');
  }

  get customers(): Locator {
    return this.page.locator('[data-testid="customers"]');
  }

  get connectors(): Locator {
    return this.page.locator("[data-testid=connectors]");
  }

  get paymentProcessors(): Locator {
    return this.page.locator("[data-testid=paymentprocessors]");
  }

  get payoutConnectors(): Locator {
    return this.page.locator('[data-testid="payoutprocessors"]');
  }

  get threeDSConnectors(): Locator {
    return this.page.locator('[data-testid="3dsauthenticators"]');
  }

  get frmConnectors(): Locator {
    return this.page.locator('[data-testid="fraud&risk"]');
  }

  get pmAuthConnectors(): Locator {
    return this.page.locator('[data-testid="pmauthprocessor"]');
  }

  get taxConnectors(): Locator {
    return this.page.locator('[data-testid="taxprocessor"]');
  }

  get billingConnectors(): Locator {
    return this.page.locator('[data-testid="billingprocessor"]');
  }

  get vaultConnectors(): Locator {
    return this.page.locator('[data-testid="vaultprocessor"]');
  }

  get analytics(): Locator {
    return this.page.locator('[data-testid="analytics"]');
  }

  get paymentsAnalytics(): Locator {
    return this.page.locator('[data-testid="payments"]');
  }

  get refundAnalytics(): Locator {
    return this.page.locator('[data-testid="refunds"]');
  }

  get workflow(): Locator {
    return this.page.locator('[data-testid="workflow"]');
  }

  get routing(): Locator {
    return this.page.locator('[data-testid="routing"]');
  }

  get surchargeRouting(): Locator {
    return this.page.locator('[data-testid="surcharge"]');
  }

  get threeDSRouting(): Locator {
    return this.page.locator('[data-testid="3dsdecisionmanager"]');
  }

  get payoutRouting(): Locator {
    return this.page.locator('[data-testid="payoutrouting"]');
  }

  get threeDSExemptionManager(): Locator {
    return this.page.locator('[data-testid="3dsexemptionmanager"]');
  }

  get vault(): Locator {
    return this.page.locator('[data-testid="vault"]');
  }

  get vaultConfiguration(): Locator {
    return this.page.locator('[data-testid="configuration"]');
  }

  get vaultCustomersAndTokens(): Locator {
    return this.page.locator('[data-testid="customers&tokens"]');
  }

  get developer(): Locator {
    return this.page.locator('[data-testid="developers"]');
  }

  get paymentSettings(): Locator {
    return this.page.locator('[data-testid="paymentsettings"]');
  }

  get apiKeys(): Locator {
    return this.page.locator('[data-testid="apikeys"]');
  }

  get webhooks(): Locator {
    return this.page.locator('[data-testid="webhooks"]');
  }

  get settings(): Locator {
    return this.page.locator('[data-testid="settings"]');
  }

  get configurePMT(): Locator {
    return this.page.locator('[data-testid="configurepmts"]');
  }

  get organizationSettings(): Locator {
    return this.page.locator('[data-testid="organizationsettings"]');
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
