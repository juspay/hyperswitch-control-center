import { Page, Locator } from "@playwright/test";

export class PayoutConnector {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }
}

export default PayoutConnector;
