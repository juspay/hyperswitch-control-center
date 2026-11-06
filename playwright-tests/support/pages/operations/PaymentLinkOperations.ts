import { Page, Locator } from "@playwright/test";

export class PaymentLinkOperations {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get sidebarLink(): Locator {
    return this.page.getByTestId("paymentlink");
  }

  get pageHeading(): Locator {
    return this.subtitle
      .locator("..")
      .getByText("Payment Link", { exact: true });
  }

  get subtitle(): Locator {
    return this.page.getByText("Create and manage payment links", {
      exact: true,
    });
  }

  get createButton(): Locator {
    return this.page.getByRole("button", {
      name: "Create Payment Link",
      exact: true,
    });
  }

  get dateSelector(): Locator {
    return this.page.getByRole("button", { name: "Date range picker" });
  }

  get emptyState(): Locator {
    return this.page.getByText("No results found", { exact: true });
  }

  get expandSearchButton(): Locator {
    return this.page.locator(
      '[data-button-for="expandTheSearchToThePrevious90Days"]',
    );
  }

  get tableRows(): Locator {
    return this.page.locator(
      'tr:has([data-table-location^="Payment Links_tr"])',
    );
  }

  get createModal(): Locator {
    return this.page.locator('[data-component="modal:Create Payment Link"]');
  }

  get modalHeading(): Locator {
    return this.createModal.locator(
      '[data-modal-header-text="Create Payment Link"]',
    );
  }

  get modalDescription(): Locator {
    return this.createModal.getByText(
      "Generate a hosted payment page to share with the customer.",
      { exact: true },
    );
  }

  fieldWrapper(name: string): Locator {
    return this.createModal.locator(
      `[data-component-field-wrapper="field-${name}"]`,
    );
  }

  fieldLabel(name: string, label: string): Locator {
    return this.fieldWrapper(name).locator(`[data-form-label="${label}"]`);
  }

  get amountInput(): Locator {
    return this.createModal.getByPlaceholder("Enter amount", { exact: true });
  }

  get currencySelect(): Locator {
    return this.fieldWrapper("currency").locator(
      '[data-element="single-select-button"]',
    );
  }

  get profileSelect(): Locator {
    return this.fieldWrapper("profile_id").locator(
      '[data-element="single-select-button"]',
    );
  }

  get returnUrlInput(): Locator {
    return this.createModal.getByPlaceholder("https://example.com/redirect", {
      exact: true,
    });
  }

  get customerEmailInput(): Locator {
    return this.createModal.getByPlaceholder("Enter customer email", {
      exact: true,
    });
  }

  get customerPhoneInput(): Locator {
    return this.createModal.getByPlaceholder("Enter customer phone number", {
      exact: true,
    });
  }

  get descriptionInput(): Locator {
    return this.createModal.getByPlaceholder("Enter a description", {
      exact: true,
    });
  }

  get setupFutureUsageSelect(): Locator {
    return this.fieldWrapper("setup_future_usage").locator(
      '[data-element="single-select-button"]',
    );
  }

  get authenticationTypeSelect(): Locator {
    return this.fieldWrapper("authentication_type").locator(
      '[data-element="single-select-button"]',
    );
  }

  option(label: string): Locator {
    // Blend portals its options outside the form field wrapper.
    return this.page.getByRole("menuitem", { name: label, exact: true });
  }

  get submitButton(): Locator {
    return this.createModal.getByRole("button", {
      name: "Create Payment Link",
      exact: true,
    });
  }

  get cancelButton(): Locator {
    return this.createModal.getByRole("button", {
      name: "Cancel",
      exact: true,
    });
  }

  get successToast(): Locator {
    return this.page.getByText("Payment link created successfully.", {
      exact: true,
    });
  }

  tableHeading(heading: string): Locator {
    return this.page.locator(`[data-table-heading="${heading}"]`);
  }

  paymentLinkRow(id: string): Locator {
    return this.tableRows.filter({
      has: this.page.getByText(id, { exact: true }),
    });
  }

  paymentLinkCell(id: string, column: number): Locator {
    return this.paymentLinkRow(id).locator(
      `[data-table-location$="_td${column}"]`,
    );
  }

  amountCell(id: string, amount: string): Locator {
    return this.paymentLinkCell(id, 6).locator(`[data-money-cell="${amount}"]`);
  }

  get unauthorizedMessage(): Locator {
    return this.page.getByText("don't have access to this module").first();
  }

  get paginationInfo(): Locator {
    return this.page.getByText("Showing", { exact: false });
  }

  // Paginator renders "Showing <n> [page-size dropdown] of <total>" in sibling spans.
  get paginationSummary(): Locator {
    return this.paginationInfo.locator("..");
  }

  paginationPageButton(pageNumber: number): Locator {
    return this.page.getByRole("button", {
      name: `${pageNumber}`,
      exact: true,
    });
  }

  paymentLinkUrl(id: string): Locator {
    return this.paymentLinkCell(id, 7).getByRole("link");
  }
}

export default PaymentLinkOperations;
