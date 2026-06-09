import { Page, Locator, expect } from "@playwright/test";

export class HomePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get enterMerchantName(): Locator {
    return this.page.getByRole('textbox', { name: 'Eg: HyperSwitch Pvt Ltd' });
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

  // Org name revealed in the tooltip when hovering the org icon
  get orgNameOnHover(): Locator {
    return this.orgIcon.locator(".truncate.max-w-40");
  }

  get orgTypeLabel(): Locator {
    return this.orgIcon.getByText("Organization", { exact: true });
  }

  // Search box inside the opened merchant dropdown
  get merchantDropdownSearchInput(): Locator {
    return this.page.getByPlaceholder("Search Merchant Account or ID");
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
    ).first();
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

  get insightsAnalytics(): Locator {
    return this.page.locator('[data-testid="insights"]');
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
    return this.page.getByRole('button', { name: 'Profile' });
  }

  get signOut(): Locator {
    return this.page.getByText("Sign out");
  }

  get welcomeText(): Locator {
    return this.page.getByText(
      "Welcome to the home of your Payments Control Center. It aims to provide your team with a 360-degree view of payments.",
    );
  }

  get connectProcessorsButton(): Locator {
    return this.page.locator('[data-button-for="connectProcessors"]');
  }

  get tryItOutButton(): Locator {
    return this.page.locator('[data-button-for="tryItOut"]');
  }

  get goToApiKeysButton(): Locator {
    return this.page.locator('[data-button-text="Go to API keys"]');
  }

  get overview(): Locator {
    return this.page.locator('[data-testid="overview"]');
  }

  get myModulesHeader(): Locator {
    return this.page.getByText("MY MODULES");
  }

  get setupCheckoutHeader(): Locator {
    return this.page.locator(
      '[class="text-fs-24 leading-32 font-semibold font-inter-style "]',
    );
  }

  get showPreviewButton(): Locator {
    return this.page.locator('[data-button-for="showPreview"]');
  }

  get payButton(): Locator {
    return this.page.locator('[data-button-for="payUSD100"]');
  }

  get paymentSuccessfulText(): Locator {
    return this.page.getByText("Payment Successful");
  }

  get sdkCheckoutDetailsTab(): Locator {
    return this.page.getByText("Checkout Details", { exact: true });
  }

  get sdkThemeCustomizationTab(): Locator {
    return this.page.getByText("Theme Customization", { exact: true });
  }

  get sdkPreviewHeading(): Locator {
    return this.page.getByText("Preview", { exact: true });
  }

  get sdkCustomerIdInput(): Locator {
    return this.page.locator('[name="customer_id"]');
  }

  get sdkAmountInput(): Locator {
    return this.page.locator('[name="amount"]');
  }

  get sdkCurrencySelectButton(): Locator {
    return this.page.locator('[name="country_currency"]');
  }

  get sdkEditCheckoutDetailsLink(): Locator {
    return this.page.getByText("Edit Checkout Details", { exact: true });
  }

  get sdkTestCredentialsCardNumber(): Locator {
    return this.page.getByText("4242 4242 4242 4242");
  }

  get sdkErrorToast(): Locator {
    return this.page.getByText("Something went wrong. Please try again");
  }

  get sdkIframe(): Locator {
    return this.page.locator('iframe[name="orca-payment-element-iframeRef-orca-elements-payment-element-payment-element"]');
  }

  get sdkCardButton(): Locator {
    return this.sdkIframe.contentFrame().getByRole('button', { name: 'Card' });
  }

  get sdkCardNoInput(): Locator {
    return this.sdkIframe.contentFrame().locator("[data-testid=cardNoInput]");
  }

  get sdkExpiryInput(): Locator {
    return this.sdkIframe.contentFrame().locator("[data-testid=expiryInput]");
  }

  get sdkCvvInput(): Locator {
    return this.sdkIframe.contentFrame().locator("[data-testid=cvvInput]");
  }

  get paymentFailedText(): Locator {
    return this.page.getByText("Payment Failed");
  }

  get paymentPendingText(): Locator {
    return this.page.getByText("Payment Pending");
  }

  get goToPaymentOperationsButton(): Locator {
    return this.page.getByRole('button', { name: 'Go to Payment Operations' });
  }

  payButtonByCurrency(currency: string): Locator {
    return this.page.getByRole('button', { name: `Pay ${currency}` });
  }

  async waitForSdkCardForm(): Promise<void> {
    await this.sdkCardButton.waitFor({ state: "visible", timeout: 10000 });
    await this.sdkCardNoInput.waitFor({ state: "visible", timeout: 15000 });
  }

  async fillSdkTestCard(): Promise<void> {
    await this.sdkCardNoInput.fill("4242424242424242");
    await this.sdkExpiryInput.fill("0127");
    await this.sdkCvvInput.fill("492");
  }

  get visitButton(): Locator {
    return this.page.getByRole("button", { name: "Visit" });
  }

  get exploreComposableServicesText(): Locator {
    return this.page.getByText("Explore composable services");
  }

  get learnMoreButtons(): Locator {
    return this.page.getByRole("button", { name: "Learn More" });
  }

  productCardName(name: string | RegExp): Locator {
    return this.page.locator("span").filter({ hasText: name });
  }

  productCard(name: string): Locator {
    return this.page
      .locator("div")
      .filter({ has: this.page.getByText(name, { exact: true }) })
      .filter({ has: this.learnMoreButtons })
      .last();
  }

  get orchestratorDescription(): Locator {
    return this.page.getByText(
      "Unifies diverse abstractions to connect with payment processors, payout processors, fraud management solutions, tax automation solutions, identity solutions, and reporting systems.",
    );
  }

  get vaultDescription(): Locator {
    return this.page.getByText(
      "A standalone, PCI-compliant vault that securely tokenizes and stores your customers’ card data — without requiring the use of our payment solutions. Supports card tokenization at PSPs and networks as well.",
    );
  }

  get reconDescription(): Locator {
    return this.page.getByText(
      "A robust tool for efficient reconciliation, providing real-time matching and error detection across transactions, ensuring data consistency and accuracy in financial operations.",
    );
  }

  get revenueRecoveryDescription(): Locator {
    return this.page.getByText(
      "A resilient recovery system that ensures seamless restoration of critical data and transactions, safeguarding against unexpected disruptions and minimizing downtime.",
    );
  }

  get costObservabilityDescription(): Locator {
    return this.page.getByText(
      "Unified view of payment processing costs across acquirers, payment methods, and regions. Track every cent, detect anomalies, audit against contracted rates, and forecast the impact of card network changes.",
    );
  }

  get liveModeBadge(): Locator {
    return this.page.locator("div").filter({ hasText: /^Live Mode$/ });
  }

  get testModeBannerText(): Locator {
    return this.page.getByText("You're in Test Mode");
  }

  get navbar(): Locator {
    return this.page.locator("#navbar");
  }

  get navbarGetProductionAccess(): Locator {
    return this.navbar.getByText("Get Production Access");
  }

  get navbarTestMode(): Locator {
    return this.navbar.getByText("You're in Test Mode");
  }

  get navbarProductionAccessRequested(): Locator {
    return this.navbar.getByText("Production Access Requested");
  }

  get addNewMerchantHeader(): Locator {
    return this.page.getByText("Add a new merchant");
  }

  get merchantNameInput(): Locator {
    return this.page.getByRole("textbox", { name: "Eg: My New Merchant" });
  }

  get addMerchantButton(): Locator {
    return this.page.getByRole("button", { name: "Add Merchant" });
  }

  /**
   * Creates a merchant via the top-bar merchant dropdown, waiting on the
   * `create_merchant` API response and retrying the whole flow when it returns
   * a non-2xx.
   *
   * The backend derives the new `merchant_id` from the current Unix timestamp at
   * second resolution (`merchant_<epoch_seconds>`), so two creations that land
   * in the same second collide and the loser gets a 500 (`UR_15`,
   * "Merchant ... already exists"). This happens routinely when tests run in
   * parallel. On failure the modal closes itself (showing a "Merchant Creation
   * Failed" toast), so each retry re-opens the dropdown and the create modal
   * from scratch, and waits long enough to cross into a new second (with jitter
   * to desync parallel workers) so the next attempt gets a fresh id. Resolves
   * once the API responds 2xx; throws if every attempt fails.
   */
  async createMerchant(
    name: string,
    { retries = 8 }: { retries?: number } = {},
  ): Promise<void> {
    for (let attempt = 1; attempt <= retries; attempt++) {
      // Ensure the merchant dropdown is open, then open the create modal
      if (!(await this.merchantDropdownSearchInput.isVisible())) {
        await this.merchantDropdown.click();
      }
      await expect(this.merchantDropdownSearchInput).toBeVisible();
      await this.clickCreateNewOption();

      await expect(this.addNewMerchantHeader).toBeVisible();
      await this.newMerchantNameInput.fill(name);
      await expect(this.addMerchantButton).toBeEnabled();

      // Covers both the v1 (`user/create_merchant`) and v2
      // (`v2/user/create_merchant`) endpoints.
      const responsePromise = this.page.waitForResponse(
        (response) =>
          response.url().includes("user/create_merchant") &&
          response.request().method() === "POST",
      );
      await this.addMerchantButton.click();
      const response = await responsePromise;

      if (response.ok()) {
        return;
      }

      if (attempt === retries) {
        throw new Error(
          `create_merchant failed after ${retries} attempt(s); last response status ${response.status()}`,
        );
      }

      // Wait past the current second so the backend mints a new
      // timestamp-based merchant_id on the next attempt instead of colliding.
      // The jitter spans a multi-second window so that parallel workers that
      // collided in the same second don't retry in lockstep and re-collide.
      await this.page.waitForTimeout(1000 + Math.floor(Math.random() * 3000));
    }
  }

  // "Create new" entry inside whichever OMP dropdown is currently open
  get createNewOption(): Locator {
    return this.page
      .locator('[data-dropdown="dropdown"]')
      .getByText("Create new", { exact: true });
  }

  /**
   * Opens the "Create new" entry inside whichever OMP dropdown is currently
   * open.
   *
   * When the dropdown lists only a few items its panel renders right under the
   * OMP trigger, whose truncated display-name <span> (the "…" ellipsis) can
   * overlap the "Create new" option and persistently intercept pointer events.
   * A normal click then times out with "<span>…</span> intercepts pointer
   * events", and `force: true` doesn't help because the real DOM event would
   * still land on the overlapping span. Dispatching the click directly on the
   * option fires its handler regardless of the overlay, while the visibility
   * assertion keeps the action honest if the option is genuinely missing.
   */
  async clickCreateNewOption(): Promise<void> {
    await expect(this.createNewOption).toBeVisible();
    await this.createNewOption.dispatchEvent("click");
  }

  // Merchant Name field in the "Add a new merchant" modal
  get newMerchantNameInput(): Locator {
    return this.page.locator('input[name="company_name"]');
  }

  get addNewProfileHeader(): Locator {
    return this.page.getByText("Add a new profile");
  }

  // Profile Name field in the "Add a new profile" modal
  get newProfileNameInput(): Locator {
    return this.page.locator('input[name="profile_name"]');
  }

  get addProfileButton(): Locator {
    return this.page.getByRole("button", { name: "Add Profile" });
  }

  // An entry (merchant or profile) shown in the currently open OMP dropdown
  ompDropdownItem(name: string): Locator {
    return this.page
      .locator('[data-dropdown="dropdown"]')
      .getByText(name, { exact: true });
  }

  // Inline validation error shown under an OMP name field in the create modal.
  // The message text is mirrored onto the `data-form-error` attribute.
  ompNameValidationError(message: string): Locator {
    return this.page.locator(`[data-form-error="${message}"]`);
  }

  // Visual-testing masks (dynamic content excluded from snapshots)
  get navHeaderMask(): Locator {
    return this.page.locator(".text-left.flex.gap-2.justify-between");
  }

  get homeGreetingMask(): Locator {
    return this.page
      .locator(".flex.flex-col.gap-7 ")
      .locator(".flex.items-center.gap-2");
  }

  get merchantDropdownItemsMask(): Locator {
    return this.page
      .locator('[data-dropdown="dropdown"]')
      .locator(".flex.justify-between.items-center.w-full");
  }

  get merchantNameButton(): Locator {
    return this.page.getByRole("button", { name: "playwright-" });
  }

  get globalSearchModalInput(): Locator {
    return this.page.locator('input[name="global_search"]');
  }

  get globalSearchLoader(): Locator {
    return this.page.locator('[class="w-14 overflow-hidden mr-1"]');
  }

  get globalSearchEmptyResult(): Locator {
    return this.page.getByText(/No Results for/);
  }

  get globalSearchGoToHeader(): Locator {
    return this.page.getByText("GO TO", { exact: true });
  }

  get globalSearchSuggestedFiltersHeader(): Locator {
    return this.page.getByText("SUGGESTED FILTERS", { exact: true });
  }

  get globalSearchValidationError(): Locator {
    return this.page.getByText("Only one free-text search is allowed and additional text will be ignored.");
  }

  get globalSearchShowAllResults(): Locator {
    return this.page.getByText("Show all results for");
  }

  get globalSearchEscButton(): Locator {
    return this.page.getByText("Esc", { exact: true });
  }

  globalSearchSectionHeader(name: string): Locator {
    return this.page.getByText(name, { exact: true });
  }
}

export default HomePage;
