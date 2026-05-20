import { Locator } from "@playwright/test";
import { PaymentOperations } from "./PaymentOperations";

export class RefundOperations extends PaymentOperations {
  // Override transactionView grid layout (refunds shows 4 columns, not 5)
  get refundsTransactionView(): Locator {
    return this.page.locator(
      '[class="grid lg:grid-cols-4 md:grid-cols-2 sm:grid-cols-2 grid-cols-2 gap-spacing-3xl"]',
    );
  }

  get refundStatusFieldWrapper(): Locator {
    return this.page.locator(
      '[data-component-field-wrapper="field-refund_status"]',
    );
  }

  get generateRefundReportsModal(): Locator {
    return this.page.locator(
      '[data-component="modal:Generate Refund Reports"]',
    );
  }

  get refundSummaryAmount(): Locator {
    return this.page.locator(
      '[class="text-fs-32 leading-38 font-bold font-inter-style"]',
    );
  }

  get summaryAmount(): Locator {
    return this.refundSummaryAmount;
  }

  paymentCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="Payment_tr${row}_td${col}"]`,
    );
  }

  daterangeDropdownValue(value: string): Locator {
    return this.page.locator(`[data-daterange-dropdown-value="${value}"]`);
  }

  get clearAllButton(): Locator {
    return this.page.getByRole("button", { name: "Clear All" });
  }
}

export default RefundOperations;
