import { Page, Locator } from "@playwright/test";

/**
 * The Google Pay wallet configuration flow inside a payment connector setup.
 *
 * Landing step offers up to three configuration methods (Payment Gateway,
 * Direct, Pre Decrypted Token); the Direct step additionally lets the user
 * choose between merchant-supplied certificates (DIRECT) and Hyperswitch
 * managed certificates (INTERNAL_GATEWAY).
 */
export class GooglePayFlow {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Entry point — the wallet row in the payment methods step
  get googlePayPaymentMethod(): Locator {
    return this.page.getByText("Google Pay").locator("visible=true").first();
  }

  get googlePayHeading(): Locator {
    return this.page.getByRole("heading", { name: "Google Pay" });
  }

  // ---- Landing step ----
  get chooseConfigurationMethodHeading(): Locator {
    return this.page.getByText("Choose Configuration Method", { exact: true });
  }

  get paymentGatewayCard(): Locator {
    return this.page
      .getByText("Payment Gateway")
      .locator("visible=true")
      .first();
  }

  get directCard(): Locator {
    return this.page
      .getByText("Direct", { exact: true })
      .locator("visible=true")
      .first();
  }

  get preDecryptedTokenCard(): Locator {
    return this.page
      .getByText("Pre Decrypted Token", { exact: true })
      .locator("visible=true")
      .first();
  }

  get directCardDescription(): Locator {
    return this.page.getByText(
      "Google Pay Decryption at Hyperswitch: Unlock from PSP dependency.",
    );
  }

  get paymentGatewayCardDescription(): Locator {
    return this.page.getByText(
      "Integrate Google Pay with your payment gateway.",
    );
  }

  get preDecryptedCardDescription(): Locator {
    return this.page.getByText(
      "Enable Google Pay by securely decrypting the Google Pay payment token on your end.",
    );
  }

  get continueButton(): Locator {
    return this.page.getByRole("button", { name: "Continue" });
  }

  // ---- Direct / Internal gateway step ----
  get decryptionKeyQuestion(): Locator {
    return this.page.getByText("How would you like to handle decryption keys?");
  }

  get customCertificatesRadio(): Locator {
    return this.page.getByText("Provide custom certificates", { exact: true });
  }

  get managedCertificatesRadio(): Locator {
    return this.page.getByText("Use Hyperswitch managed certificates", {
      exact: true,
    });
  }

  get merchantNameInput(): Locator {
    return this.page.getByPlaceholder("Enter Google Pay Merchant Name");
  }

  /** Optional field, shown only for the Hyperswitch managed certificates mode. */
  get merchantIdInput(): Locator {
    return this.page.getByPlaceholder("Enter Google Pay Merchant ID");
  }

  /** Rendered without a trailing asterisk because the field is optional. */
  get merchantIdLabel(): Locator {
    return this.page.getByText("Google Pay Merchant ID", { exact: true });
  }

  get merchantIdSubText(): Locator {
    return this.page.getByText(
      "If merchant ID is not provided, we will use Hyperswitch's internal merchant ID",
    );
  }

  get publicKeyInput(): Locator {
    return this.page.getByPlaceholder("Enter Google Pay Public Key");
  }

  get privateKeyInput(): Locator {
    return this.page.getByPlaceholder("Enter Google Pay Private Key");
  }

  get recipientIdInput(): Locator {
    return this.page.getByPlaceholder("Enter Recipient Id");
  }

  get allowedAuthMethodsDropdown(): Locator {
    return this.page.getByRole("button", { name: "Select Value" });
  }

  authMethodOption(name: string): Locator {
    return this.page.getByText(name, { exact: true });
  }

  /** Required field labels render with a trailing asterisk. */
  fieldLabel(label: string): Locator {
    return this.page.getByText(`${label} *`, { exact: true });
  }

  get proceedButton(): Locator {
    return this.page.getByRole("button", { name: "Proceed" }).nth(1);
  }

  /**
   * Only one Cancel button is rendered, unlike Proceed which also appears in
   * the connector step footer.
   */
  get cancelButton(): Locator {
    return this.page.getByRole("button", { name: "Cancel" }).first();
  }

  get preDecryptedTokenToggle(): Locator {
    return this.page
      .locator("div", {
        has: this.page.getByText("Enable pre decrypted token", { exact: true }),
      })
      .filter({ has: this.page.locator("[data-bool-value]") })
      .last()
      .locator("[data-bool-value]")
      .first();
  }
}
