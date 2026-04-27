import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { UsersPage } from "../../support/pages/settings/UsersPage";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { ResetPasswordPage } from "../../support/pages/auth/ResetPasswordPage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  redirectFromMailInbox,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
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
    const usersPage = new UsersPage(page);
    const invitedEmail = generateUniqueEmail();

    await homePage.users.click();
    await usersPage.inviteUser(invitedEmail);

    await page.goto(MAIL_URL);
    await page.locator('[id="search"]').fill(invitedEmail);
    await page.locator('[id="search"]').press("Enter");
    await expect(
      page
        .locator("div.msglist-message")
        .filter({ hasText: "You have been invited to join Hyperswitch Community" })
        .filter({ hasText: invitedEmail })
        .first(),
    ).toBeVisible();
  });

  test("should show processing screen when accepting invite from email link", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);
    const invitedEmail = generateUniqueEmail();
    const password = PLAYWRIGHT_PASSWORD;

    await homePage.users.click();
    await usersPage.inviteUser(invitedEmail);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await redirectFromMailInbox(
      page,
      invitedEmail,
      "You have been invited to join Hyperswitch Community",
    );

    await expect(page).toHaveURL(/.*accept_invite_from_email/);
    await expect(
      page.getByRole('button', { name: 'Continue with Password' })
    ).toBeVisible();
    await page.getByRole('button', { name: 'Continue with Password' }).click();
    await signinPage.skip2FAButton.click();

    await resetPasswordPage.newPasswordField.fill(password);
    await resetPasswordPage.newPasswordField.blur();
    await resetPasswordPage.confirmPasswordField.fill(password);
    await resetPasswordPage.confirmPasswordField.blur();
    await resetPasswordPage.confirmButton.click();

    await loginUI(page, invitedEmail, PLAYWRIGHT_PASSWORD);
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should redirect to login when accepting invite with an invalid or expired token", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const invitedEmail = generateUniqueEmail();

    await homePage.users.click();
    await usersPage.inviteUser(invitedEmail);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await page.goto(MAIL_URL);
    await page.locator('[id="search"]').fill(invitedEmail);
    await page.locator('[id="search"]').press("Enter");
    await page
      .locator("div.msglist-message")
      .filter({ hasText: "You have been invited to join Hyperswitch Community" })
      .filter({ hasText: invitedEmail })
      .first()
      .click();
    await page.waitForTimeout(1000);

    const iframe = page.locator("iframe").first().contentFrame();
    const verifyLink = await iframe.locator("a").first().getAttribute("href");
    const tamperedLink = verifyLink!.replace(/token=[^&]+/, "token=abcd");
    await page.goto(tamperedLink);

    await expect(page).toHaveURL(/.*login/);
    await expect(page.getByTestId('card-header')).toHaveText("Hey there, Welcome back!");
  });
});
