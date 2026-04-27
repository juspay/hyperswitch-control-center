import { Page, Locator } from "@playwright/test";

export class UsersPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get inviteUsersButton(): Locator {
    return this.page.locator('[data-button-for="inviteUsers"]');
  }

  get emailListInput(): Locator {
    return this.page.locator('[name="email_list"]');
  }

  get roleDropdownTrigger(): Locator {
    return this.page.locator(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    );
  }

  get roleOption(): Locator {
    return this.page.locator(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    );
  }

  get entityOption(): Locator {
    return this.page.locator('[class="mr-5"]');
  }

  get sendInviteButton(): Locator {
    return this.page.locator('[data-button-for="sendInvite"]');
  }

  async inviteUser(email: string): Promise<void> {
    await this.inviteUsersButton.click();
    await this.emailListInput.fill(email);
    await this.roleDropdownTrigger.click();
    await this.roleOption.click();
    await this.entityOption.nth(0).click();
    await this.sendInviteButton.click();
  }
}

export default UsersPage;
