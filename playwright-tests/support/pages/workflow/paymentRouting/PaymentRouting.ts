import { Page, Locator } from "@playwright/test";

export class PaymentRouting {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }
}

export default PaymentRouting;
