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

  // 3DS Tab Elements
  get force3DSChallengeToggle(): Locator {
    return this.page.getByText("Force 3DS Challenge");
  }

  get acquirerConfigSettings(): Locator {
    return this.page.getByText("Acquirer Config Settings");
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

  async clickCancel(): Promise<void> {
    await this.cancelButton.click();
  }
}

export default PaymentSettings;
