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

  alwaysOption(position: "first" | "last" = "first"): Locator {
    const option = this.page.getByText("Always", { exact: true });
    return position === "first" ? option.first() : option.last();
  }

  buttonByName(name: string | RegExp): Locator {
    return this.page.getByRole("button", { name });
  }

  dropdownValue(value: string): Locator {
    return this.page.locator(`[data-dropdown-value="${value}"]`).first();
  }

  dropdownValueByText(text: string): Locator {
    return this.page
      .locator("[data-dropdown-value]")
      .filter({ hasText: text })
      .first();
  }

  selectFieldDropdown(): Locator {
    return this.page.getByRole("button", { name: "Select Field" }).first();
  }

  // 3DS Tab Elements
  get force3DSChallengeToggle(): Locator {
    return this.page.getByText("Force 3DS Challenge");
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

  // Acquirer Config Settings (MerchantAcquirerDetails — new flow)
  get acquirerConfigSettingsHeading(): Locator {
    return this.page.getByText("Acquirer Config Settings", { exact: true });
  }

  get noAcquirerConfigsText(): Locator {
    return this.page.getByText("No acquirer configurations yet", {
      exact: true,
    });
  }

  get acquirerConfigGroupButton(): Locator {
    return this.page.getByRole("button", { name: "Acquirer config group" });
  }

  get addNewNetworkButton(): Locator {
    return this.page.getByRole("button", { name: "Add New Network" });
  }

  get changeDefaultButton(): Locator {
    return this.page.getByRole("button", { name: "Change Default" });
  }

  get saveAsDefaultButton(): Locator {
    return this.page.getByRole("button", { name: "Save as Default" });
  }

  // Modal scoping helpers
  acquirerModal(heading: string): Locator {
    return this.page.locator(`[data-component="modal:${heading}"]`);
  }

  get addAcquirerModal(): Locator {
    return this.acquirerModal("Add Acquirer Configuration");
  }

  get addNetworkModal(): Locator {
    return this.acquirerModal("Add Network Configuration");
  }

  get editNetworkModal(): Locator {
    return this.acquirerModal("Edit Network Configuration");
  }

  acquirerModalScrollRegion(modal: Locator): Locator {
    return modal.locator('[data-component="acquirerFormScrollRegion"]');
  }

  // Modal field locators (scoped to the currently-open modal)
  acquirerModalSaveButton(modal: Locator): Locator {
    return modal.getByRole("button", { name: "Save", exact: true });
  }

  acquirerModalUpdateButton(modal: Locator): Locator {
    return modal.getByRole("button", { name: "Update", exact: true });
  }

  acquirerModalCancelButton(modal: Locator): Locator {
    return modal.getByRole("button", { name: "Cancel", exact: true });
  }

  // TextInput / NumericTextInput wrap each field in a div that carries
  // data-input-name="<form field name>", so we can target inputs by their
  // form key. This is more stable than placeholder lookup (placeholders are
  // shared between BIN/ICA and Blend's floating-label rendering can hide
  // them when a value is bound in the Edit modal).
  inputByName(modal: Locator, name: string): Locator {
    return modal.locator(`[data-input-name="${name}"] input`);
  }

  acquirerMerchantNameInput(modal: Locator): Locator {
    return this.inputByName(modal, "merchant_name");
  }

  acquirerMerchantIdInput(modal: Locator): Locator {
    return this.inputByName(modal, "acquirer_assigned_merchant_id");
  }

  acquirerBinInput(modal: Locator): Locator {
    return this.inputByName(modal, "acquirer_bin");
  }

  acquirerIcaInput(modal: Locator): Locator {
    return this.inputByName(modal, "acquirer_ica");
  }

  acquirerFraudRateInput(modal: Locator): Locator {
    return this.inputByName(modal, "acquirer_fraud_rate");
  }

  acquirerNetworkDropdownInModal(modal: Locator): Locator {
    return modal.getByRole("button", { name: "Select Network" });
  }

  acquirerCountryDropdownInModal(modal: Locator): Locator {
    return modal.getByRole("button", { name: "Select Acquirer Country" });
  }

  // Toasts
  get acquirerCreatedToast(): Locator {
    return this.page.locator('[data-toast="Acquirer created"]');
  }

  get networkAddedToast(): Locator {
    return this.page.locator('[data-toast="Network added"]');
  }

  get networkUpdatedToast(): Locator {
    return this.page.locator('[data-toast="Network updated"]');
  }

  get defaultAcquirerUpdatedToast(): Locator {
    return this.page.locator('[data-toast="Default acquirer updated"]');
  }

  // Validation errors
  get acquirerBinError(): Locator {
    return this.page.getByText("Acquirer BIN must be between 4 and 20 digits");
  }

  get fraudRateError(): Locator {
    return this.page.getByText("Fraud rate should be between 0 and 100");
  }

  requiredFieldError(index: number = 0): Locator {
    return this.page.getByText("This field is required").nth(index);
  }

  // Accordion / table helpers
  defaultTag(): Locator {
    return this.page.getByText("Default", { exact: true });
  }

  acquirerNetworkRow(network: string): Locator {
    // Table cell tagged with the network name (TagBinding)
    return this.page.getByText(network, { exact: true });
  }

  editIconForRow(rowText: string): Locator {
    // Edit pencil icon lives in the trailing Update column of the row
    return this.page.locator("tr", { hasText: rowText }).locator("svg").last();
  }

  // Custom Headers Tab Elements
  get customHeadersKeyInput(): Locator {
    return this.page.getByPlaceholder("Enter key").first();
  }

  get customHeadersValueInput(): Locator {
    return this.page.getByPlaceholder("Enter value").first();
  }

  get editButton(): Locator {
    return this.page.getByText("Edit", { exact: true });
  }

  get proceedButton(): Locator {
    return this.page.getByRole("button", { name: "Proceed" });
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

  get validUrlError(): Locator {
    return this.page.getByText("Please enter valid URL");
  }

  get allowedDomainsError(): Locator {
    return this.page.getByText("Please enter allowed domains");
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
    const firstOption = this.page
      .locator("div")
      .filter({ hasText: /^Wine producers$/ })
      .nth(4);
    const optionText = (await firstOption.getAttribute("data-value")) ?? "";
    await firstOption.click();
    return optionText;
  }

  async clickCancel(): Promise<void> {
    await this.cancelButton.click();
  }
}

export default PaymentSettings;
