import { Page, Locator } from "@playwright/test";

export class PaymentOperations {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Add locators here
}

export default PaymentOperations;
