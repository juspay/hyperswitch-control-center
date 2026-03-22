import { Page, Locator } from "@playwright/test";

export class SignUpPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Add locators here
}

export default SignUpPage;
