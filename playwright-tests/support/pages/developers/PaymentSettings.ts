import { Page, Locator } from "@playwright/test";

export class PaymentSettings {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Page Header
  get pageHeader(): Locator {
    return this.page.getByText("Payment settings", { exact: true });
  }

  // Information Cards
  get profileName(): Locator {
    return this.page.getByText("Profile Name");
  }

  get profileId(): Locator {
    return this.page.getByText("Profile ID");
  }

  get merchantId(): Locator {
    return this.page.getByText("Merchant ID");
  }

  get paymentResponseHashKey(): Locator {
    return this.page.getByText("Payment Response Hash Key");
  }

  // Tabs
  get paymentBehaviourTab(): Locator {
    return this.page.locator("text=Payment Behaviour");
  }

  get threeDSTab(): Locator {
    return this.page.locator("text=3DS");
  }

  get customHeadersTab(): Locator {
    return this.page.locator("text=Custom Headers");
  }

  get metadataHeadersTab(): Locator {
    return this.page.locator("text=Metadata Headers");
  }

  get paymentLinkTab(): Locator {
    return this.page.locator("text=Payment Link");
  }

  // Payment Behaviour Tab Elements
  get collectBillingDetailsToggle(): Locator {
    return this.page.getByText("Collect billing details from wallets");
  }

  get collectShippingDetailsToggle(): Locator {
    return this.page.getByText("Collect shipping details from wallets");
  }

  get autoRetriesToggle(): Locator {
    return this.page.getByText("Auto Retries", { exact: true });
  }

  get manualRetriesToggle(): Locator {
    return this.page.getByText("Manual Retries", { exact: true });
  }

  get extendedAuthorizationToggle(): Locator {
    return this.page.getByText("Extended Authorization", { exact: true });
  }

  get alwaysEnableOvercaptureToggle(): Locator {
    return this.page.getByText("Always Enable Overcapture", { exact: true });
  }

  get networkTokenizationToggle(): Locator {
    return this.page.getByText("Network Tokenization", { exact: true });
  }

  get clickToPayToggle(): Locator {
    return this.page.getByText("Click to Pay", { exact: true });
  }

  get returnUrlInput(): Locator {
    return this.page.getByPlaceholder("Enter Return URL");
  }

  get webhookUrlInput(): Locator {
    return this.page.getByPlaceholder("Enter Webhook URL");
  }

  get merchantCategoryCodeDropdown(): Locator {
    return this.page.getByRole("button", { name: "Select Option" });
  }

  get paymentMethodBlocking(): Locator {
    return this.page.getByText("Payment Method Blocking");
  }

  get maxAutoRetriesInput(): Locator {
    return this.page.getByPlaceholder("Enter number of max auto retries");
  }

  get clickToPayConnectorDropdown(): Locator {
    return this.page.getByRole("button", {
      name: "Select Click to Pay - Connector ID",
    });
  }

  radioOption(label: string): Locator {
    return this.page.locator("div.cursor-pointer", { hasText: label }).first();
  }

  isRadioSelected(label: string): Locator {
    return this.radioOption(label).locator("svg, [class*='RadioIcon']").first();
  }

  // 3DS Tab Elements
  get force3DSChallengeToggle(): Locator {
    return this.page.getByText("Force 3DS Challenge");
  }

  get acquirerConfigSettings(): Locator {
    return this.page.getByText("Acquirer Config Settings");
  }

  get authenticationConnectorsLabel(): Locator {
    return this.page.getByText("Authentication Connectors", { exact: true });
  }

  get threeDsRequestorUrlInput(): Locator {
    return this.page.getByPlaceholder("Enter 3DS Requestor URL");
  }

  get threeDsRequestorAppUrlInput(): Locator {
    return this.page.getByPlaceholder("Enter 3DS Requestor App URL");
  }

  // Acquirer Config Settings
  get acquirerMerchantNameInput(): Locator {
    return this.page.getByPlaceholder("Enter Merchant Name");
  }

  get acquirerBinInput(): Locator {
    return this.page.getByPlaceholder("Enter Acquirer Bin");
  }

  get acquirerAssignedMerchantIdInput(): Locator {
    return this.page.getByPlaceholder("Enter Acquirer Assigned Merchant Id");
  }

  get acquirerFraudRateInput(): Locator {
    return this.page.getByPlaceholder("Enter Acquirer Fraud Rate");
  }

  get acquirerNetworkDropdown(): Locator {
    return this.page.getByRole("button", { name: "Select Network" });
  }

  get acquirerSaveButton(): Locator {
    return this.page.getByRole("button", { name: "Save", exact: true });
  }

  get acquirerConfigCreatedToast(): Locator {
    return this.page.locator('[data-toast="Acquirer config created"]');
  }

  // Custom Headers Tab Elements
  get customHeadersKeyInput(): Locator {
    return this.page.getByPlaceholder("Enter key").first();
  }

  get customHeadersValueInput(): Locator {
    return this.page.getByPlaceholder("Enter value").first();
  }

  // Metadata Headers Tab Elements
  get customMetadataHeadersHeading(): Locator {
    return this.page.getByText("Custom Metadata Headers");
  }

  // Payment Link Tab Elements
  get paymentLinkDomainHeading(): Locator {
    return this.page.getByText("Payment Link Domain");
  }

  get domainNameInput(): Locator {
    return this.page.getByPlaceholder("Enter Domain Name");
  }

  get allowedDomainInput(): Locator {
    return this.page.getByPlaceholder("Enter Allowed Domain");
  }

  // Common Buttons
  get updateButton(): Locator {
    return this.page.getByRole("button", { name: "Update" });
  }

  get cancelButton(): Locator {
    return this.page.getByRole("button", { name: "Cancel" });
  }

  get detailsUpdatedToast(): Locator {
    return this.page.locator('[data-toast="Details updated"]');
  }

  toggleSwitchByLabel(label: string): Locator {
    return this.page
      .locator("div", {
        has: this.page.getByText(label, { exact: true }),
      })
      .filter({ has: this.page.locator("[data-bool-value]") })
      .last()
      .locator("[data-bool-value]")
      .first();
  }

  // Helper Methods
  async navigateToPaymentSettings(): Promise<void> {
    await this.page.goto("/dashboard/payment-settings");
  }

  async clickTab(
    tabName:
      | "paymentBehaviour"
      | "3ds"
      | "customHeaders"
      | "metadataHeaders"
      | "paymentLink",
  ): Promise<void> {
    const tabs: Record<string, Locator> = {
      paymentBehaviour: this.paymentBehaviourTab,
      "3ds": this.threeDSTab,
      customHeaders: this.customHeadersTab,
      metadataHeaders: this.metadataHeadersTab,
      paymentLink: this.paymentLinkTab,
    };
    await tabs[tabName].click();
  }

  async fillReturnUrl(url: string): Promise<void> {
    await this.returnUrlInput.fill(url);
  }

  async fillWebhookUrl(url: string): Promise<void> {
    await this.webhookUrlInput.fill(url);
  }

  async fillCustomHeader(key: string, value: string): Promise<void> {
    await this.customHeadersKeyInput.fill(key);
    await this.customHeadersValueInput.fill(value);
  }

  async fillPaymentLinkDomain(
    domain: string,
    allowedDomain: string,
  ): Promise<void> {
    await this.domainNameInput.fill(domain);
    await this.allowedDomainInput.fill(allowedDomain);
  }

  async clickUpdate(): Promise<void> {
    await this.updateButton.click();
  }

  async selectFirstMerchantCategoryCode(): Promise<string> {
    await this.merchantCategoryCodeDropdown.click();
    const firstOption = this.page.locator('div').filter({ hasText: /^Wine producers$/ }).nth(4);
    const optionText = (await firstOption.getAttribute("data-value")) ?? "";
    await firstOption.click();
    return optionText;
  }

  async clickCancel(): Promise<void> {
    await this.cancelButton.click();
  }
}

export default PaymentSettings;
