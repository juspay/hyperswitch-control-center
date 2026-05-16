import { Page, Locator } from "@playwright/test";

export class PaymentOperations {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get transactionView(): Locator {
    return this.page.locator(
      '[class="grid lg:grid-cols-5 md:grid-cols-4 sm:grid-cols-3 grid-cols-2 gap-6 mb-8"]',
    );
  }

  get searchBox(): Locator {
    return this.page.locator('[name="name"]');
  }

  get dateSelector(): Locator {
    return this.page.locator('[data-testid="date-range-selector"]');
  }

  get viewDropdown(): Locator {
    return this.page.locator(
      '[class="flex h-fit rounded-lg hover:bg-opacity-80"]',
    );
  }

  get addFilters(): Locator {
    return this.page.locator('[data-icon="plus"]');
  }

  get generateReports(): Locator {
    return this.page.locator('[data-button-for="generateReports"]');
  }

  get columnButton(): Locator {
    return this.page.locator('[data-button-for="CustomIcon"]');
  }

  get paymentIdCopyButton(): Locator {
    return this.page.locator(
      '[class="fill-current cursor-pointer opacity-70 h-7 py-1"]',
    );
  }

  // Page header / empty state
  get pageHeader(): Locator {
    return this.page.locator('[class="flex justify-between items-center"]');
  }

  get pageTitle(): Locator {
    return this.pageHeader;
  }

  get noResultsHeader(): Locator {
    return this.page.locator(
      '[class="items-center text-2xl text-black font-bold mb-4"]',
    );
  }

  get noResultsHeading(): Locator {
    return this.noResultsHeader;
  }

  get emptyStateContainer(): Locator {
    return this.searchHelpText;
  }

  get expandSearch90Days(): Locator {
    return this.page.locator(
      '[data-button-for="expandTheSearchToThePrevious90Days"]',
    );
  }

  get searchHelpText(): Locator {
    return this.page.locator('[class="flex justify-center"]');
  }

  // Common buttons / icons
  get saveButton(): Locator {
    return this.page.locator('[data-button-text="Save"]');
  }

  get applyButton(): Locator {
    return this.page.locator('[data-button-text="Apply"]');
  }

  get modalCloseIcon(): Locator {
    return this.page.locator('.border.border-jp-gray-500.dark\\:border-jp-gray-900.bg-white.dark\\:bg-jp-gray-lightgray_background.shadow.rounded-lg.dark\\:text-opacity-75.dark\\:bg-jp-gray-darkgray_background.animate-slideUp > .\\!p-4 > .flex.items-center > .flex.flex-col > .fill-current.cursor-pointer');
  }

  get crossOutlineIcon(): Locator {
    return this.page.locator('[data-icon="cross-outline"]');
  }

  get searchExitIcon(): Locator {
    return this.page.locator('[data-icon="searchExit"]');
  }

  get externalLinkIcon(): Locator {
    return this.page.locator('[data-icon="external-link-alt"]');
  }

  // Table columns modal
  get tableColumnsModal(): Locator {
    return this.page.locator('[data-component="modal:Table Columns"]');
  }

  get columnsModal(): Locator {
    return this.tableColumnsModal;
  }

  get columnsModalBody(): Locator {
    return this.page.locator(
      '[class="overflow-hidden p-6 pb-12 border-b border-solid  border-slate-300 dark:border-slate-500"]',
    );
  }

  get tableColumnsDropdownItems(): Locator {
    return this.tableColumnsModal.locator("[data-dropdown-numeric]");
  }

  get columnsModalDropdownItems(): Locator {
    return this.tableColumnsDropdownItems;
  }

  get tableColumnsModalCloseIcon(): Locator {
    return this.tableColumnsModal.locator('[data-icon="modal-close-icon"]');
  }

  dropdownValue(value: string): Locator {
    return this.page.locator(`[data-dropdown-value="${value}"]`);
  }

  columnDropdownValue(value: string): Locator {
    return this.dropdownValue(value);
  }

  visibleDropdownValue(value: string): Locator {
    return this.page.locator(`[data-dropdown-value="${value}"]:visible`);
  }

  tableHeading(column: string): Locator {
    return this.page.locator(`[data-table-heading="${column}"]`);
  }

  // Date picker
  get predefinedDateOptions(): Locator {
    return this.page.locator(
      '[data-date-picker-predefined="predefined-options"]',
    );
  }

  get predefinedOptions(): Locator {
    return this.predefinedDateOptions;
  }

  get customRangeOption(): Locator {
    return this.page.locator('[data-daterange-dropdown-value="Custom Range"]');
  }

  // Filters
  get filterChipArea(): Locator {
    return this.page.locator(
      '[class="flex relative  flex-row  flex-wrap"]',
    );
  }

  get filterChipContainer(): Locator {
    return this.filterChipArea;
  }

  get statusFieldWrapper(): Locator {
    return this.page.locator('[data-component-field-wrapper="field-status"]');
  }

  get customerIdInput(): Locator {
    return this.page.locator('[name="customer_id"]');
  }

  get merchantOrderRefIdInput(): Locator {
    return this.page.locator('[name="merchant_order_reference_id"]');
  }

  // Toasts
  get emailSentToast(): Locator {
    return this.page.locator('[data-toast="Email Sent"]');
  }

  get genericErrorToast(): Locator {
    return this.page.locator(
      '[data-toast="Something went wrong. Please try again."]',
    );
  }

  dataToast(text: string): Locator {
    return this.page.locator(`[data-toast="${text}"]`);
  }

  // Data labels (generic)
  dataLabel(label: string): Locator {
    return this.page.locator(`[data-label="${label}"]`);
  }

  // Orders table cells: data-table-location="Orders_trX_tdY"
  orderCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="Orders_tr${row}_td${col}"]`,
    );
  }

  // Refunds table (shown both on payment details and refund list)
  get refundsTable(): Locator {
    return this.page.locator('table[data-expandable-table="Refunds"]');
  }

  refundCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="Refunds_tr${row}_td${col}"]`,
    );
  }

  // Payment attempts table cells
  attemptCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="Attempts_tr${row}_td${col}"]`,
    );
  }

  // Refund modal (opened from payment details)
  get addRefundButton(): Locator {
    return this.page.locator('[data-button-text="+ Refund"]');
  }

  get refundButton(): Locator {
    return this.addRefundButton;
  }

  get initiateRefundButton(): Locator {
    return this.page.locator('[data-button-text="Initiate Refund"]');
  }

  get refundAmountInput(): Locator {
    return this.page.locator('[name="amount"]');
  }

  get refundReasonInput(): Locator {
    return this.page.locator('[name="reason"]');
  }

  // Generate Payment Reports modal
  get generatePaymentReportsModal(): Locator {
    return this.page.locator(
      '[data-component="modal:Generate Payment Reports"]',
    );
  }

  get generateReportsModal(): Locator {
    return this.generatePaymentReportsModal;
  }

  // Payment details accordions / section headers
  get eventsAndLogsSection(): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: /^Events and logs$/ })
      .first();
  }

  get eventsAndLogsText(): Locator {
    return this.page.getByText("Events and logs");
  }

  get customerDetailsSection(): Locator {
    return this.page.getByText("Customer Details");
  }

  get morePaymentDetailsSection(): Locator {
    return this.page.getByText("More Payment Details");
  }

  get paymentMethodDetailsSection(): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: /^Payment Method Details$/ })
      .first();
  }

  get paymentMetadataSection(): Locator {
    return this.page.getByText("Payment Metadata");
  }

  get frmDetailsSection(): Locator {
    return this.page.getByText("FRM Details");
  }

  get refundReasonField(): Locator {
    return this.page.getByText("Refund ReasonN/A");
  }

  get merchantDecisionField(): Locator {
    return this.page.getByText("Merchant DecisionN/A");
  }

  get connectorTransactionIdInTable(): Locator {
    return this.page.getByRole("table").getByText("Connector Transaction ID");
  }

  get firstAttemptRowExpander(): Locator {
    return this.page.locator('[data-table-location="Attempts_tr1_td1"]');
  }

  get refundsSectionBlock(): Locator {
    return this.page.locator('[class="flex flex-col gap-4"]').nth(1);
  }

  customerEmailTestId(email: string): Locator {
    return this.page.getByTestId(email);
  }

  // Payouts table cells: data-table-location="Payouts_trX_tdY"
  payoutCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="Payouts_tr${row}_td${col}"]`,
    );
  }

  // Payout details accordions
  get morePayoutDetailsSection(): Locator {
    return this.page.getByText("More Payout Details");
  }

  get payoutMethodDetailsSection(): Locator {
    return this.page.getByText("Payout Method Details");
  }

  get payoutMetadataSection(): Locator {
    return this.page.getByText("Payout Metadata");
  }

  get payoutMethodText(): Locator {
    return this.page.getByText("Payout Method", { exact: true });
  }

  get payoutErrorCodeText(): Locator {
    return this.page.getByText("Error Code", { exact: true });
  }

  get payoutMetadataJsonText(): Locator {
    return this.page.getByText('{ 2 "key": "value" 3}');
  }

  get paymentSectionText(): Locator {
    return this.page.getByText("Payment", { exact: true });
  }
}

export default PaymentOperations;
