import { Page, Locator } from "@playwright/test";

export class CustomerOperations {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get searchInput(): Locator {
    return this.page.getByRole("textbox", { name: "Search for Customer ID" });
  }

  get genericSearchInput(): Locator {
    return this.page.locator('input[placeholder*="Search" i]').first();
  }

  get pageHeading(): Locator {
    return this.page.getByText("CustomersView all customers");
  }

  get table(): Locator {
    return this.page.locator("#table");
  }

  get tableRows(): Locator {
    return this.page.locator("#table tbody tr");
  }

  get filterRow(): Locator {
    return this.page.locator(".flex.flex-row.items-stretch");
  }

  customerCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="Customers_tr${row}_td${col}"]`,
    );
  }
}

export default CustomerOperations;
