import { Locator } from "@playwright/test";
import { PaymentOperations } from "./PaymentOperations";

export class PayoutOperations extends PaymentOperations {
  // Payouts uses a 4-column TransactionView grid (matching refunds), not the
  // 5-column payments grid.
  get payoutsTransactionView(): Locator {
    return this.page.locator(
      '[class="grid lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6 mb-8"]',
    );
  }

  get payoutStatusFieldWrapper(): Locator {
    return this.page.getByRole('button', { name: 'Select status' });
  }

  get daterangeDropdownValue(): Locator {
    return this.page.getByRole('menuitem', { name: 'Last 30 minutes' });
  }

  get clearAllButton(): Locator {
    return this.page.getByRole("button", { name: "Clear All" });
  }
}

export default PayoutOperations;
