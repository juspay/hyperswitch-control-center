import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";
const MAIL_URL = process.env.PLAYWRIGHT_MAIL_URL || "http://localhost:8025";

test.describe("Users", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should successfully invite a user and verify received invite", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const invitedEmail = generateUniqueEmail();

    await homePage.users.click();
    await page.locator('[data-button-for="inviteUsers"]').click();
    await page.locator('[name="email_list"]').fill(invitedEmail);
    await page
      .locator(
        '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
      )
      .click();
    await page
      .locator(
        '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
      )
      .click();
    await page.locator('[class="mr-5"]').nth(0).click();
    await page.locator('[data-button-for="sendInvite"]').click();

    await page.goto(MAIL_URL);
    await expect(page.locator("div.messages > div:nth-child(1)")).toContainText("You have been invited to join Hyperswitch Community");
  });
});
