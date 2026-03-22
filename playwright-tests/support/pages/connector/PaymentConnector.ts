import { Page, Locator } from "@playwright/test";

export class PaymentConnector {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }
}

export default PaymentConnector;
