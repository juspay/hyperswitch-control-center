import { test, expect } from "../../support/test";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { HomePage } from "../../support/pages/homepage/HomePage";
import {
  signupUser,
  createAuth,
  getAuthIdByEmail,
} from "../../support/commands";

// Traces would record the Okta credentials typed into the SSO form.
test.use({ trace: "off" });

const ssoBaseUrl = process.env.PLAYWRIGHT_SSO_BASE_URL;
(ssoBaseUrl ? test.describe.serial : test.describe.skip)(
  "Okta SSO tests",
  () => {
    let authId = "";

    test.beforeAll(async ({ request }) => {
      try {
        await signupUser(
          process.env.PLAYWRIGHT_SSO_USERNAME!,
          process.env.PLAYWRIGHT_SSO_PASSWORD!,
          request,
        );
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        // Ignore "already exists" error on retries, rethrow all others
        if (!errorMsg.includes("already exists")) {
          throw error;
        }
      }
      try {
        await createAuth(request);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        // Ignore "auth method already exists" error on retries, rethrow all others
        if (!errorMsg.includes("already exists")) {
          throw error;
        }
      }
      authId = await getAuthIdByEmail(request);
    });

    test("should display 'Continue with Okta' button when login URL is accessed with valid okta enabled auth_id", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto(`/?auth_id=${authId}`);
      await page.waitForLoadState("networkidle");

      await expect(signinPage.continueWithOktaButton).toBeVisible({
        timeout: 30000,
      });
      await expect(signinPage.continueWithOktaButton).toContainText(
        "Continue with Okta",
      );
    });

    test("should not display the SSO button when login URL is accessed without, with empty, or with invalid auth_id parameter", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto("/");
      await expect(signinPage.continueWithOktaButton).not.toBeAttached();

      await page.goto("/?auth_id=");
      await expect(signinPage.continueWithOktaButton).not.toBeAttached();

      await page.goto("/?auth_id=abcd");
      await expect(signinPage.continueWithOktaButton).not.toBeAttached();
    });

    test("should redirect to Okta login page when 'Continue with Okta' button is clicked", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*okta\.com.*/, { timeout: 30000 });
    });

    test("should redirect to dashboard homepage after entering valid Okta credentials", async ({
      page,
    }) => {
      // Cross-domain Okta round-trip + dashboard load is too slow for the
      // default 30s test budget on CI; bump it before chaining waits.
      test.setTimeout(90000);
      const signinPage = new SignInPage(page);
      const ssoUsername = process.env.PLAYWRIGHT_SSO_USERNAME || "";
      const ssoPassword = process.env.PLAYWRIGHT_SSO_PASSWORD || "";

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*okta\.com.*/, { timeout: 30000 });

      await signinPage.oktaEmailInput.fill(ssoUsername);
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill(ssoPassword);
      await signinPage.oktaVerifyButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });
    });

    test("should show authentication error after entering invalid Okta credentials and stay on Okta login page", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await signinPage.oktaEmailInput.fill("demo.user@test.com");
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill("Test@1234");
      await signinPage.oktaVerifyButton.click();

      await expect(signinPage.oktaErrorMessage).toBeVisible();
      await expect(signinPage.oktaErrorMessage).toContainText(
        "Unable to sign in",
      );
      await expect(page).toHaveURL(/.*okta\.com.*/);
    });

    test("should automatically log in and redirect to the dashboard after logout once initial Okta login is successful", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const signinPage = new SignInPage(page);
      const ssoUsername = process.env.PLAYWRIGHT_SSO_USERNAME || "";
      const ssoPassword = process.env.PLAYWRIGHT_SSO_PASSWORD || "";

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await signinPage.oktaEmailInput.fill(ssoUsername);
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill(ssoPassword);
      await signinPage.oktaVerifyButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });

      await homePage.userAccount.click();
      await homePage.signOut.click();

      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });
    });

    test("should require full Okta login after logged out from okta", async ({
      page,
      request: _request,
    }) => {
      const homePage = new HomePage(page);
      const signinPage = new SignInPage(page);
      const ssoUsername = process.env.PLAYWRIGHT_SSO_USERNAME || "";
      const ssoPassword = process.env.PLAYWRIGHT_SSO_PASSWORD || "";
      const ssoBase = process.env.PLAYWRIGHT_SSO_BASE_URL || "";

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await signinPage.oktaEmailInput.fill(ssoUsername);
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill(ssoPassword);
      await signinPage.oktaVerifyButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });

      await homePage.userAccount.click();
      await homePage.signOut.click();

      await page.request.get(`${ssoBase}/login/signout`, { maxRedirects: 0 });

      await signinPage.continueWithOktaButton.click();

      await expect(page).toHaveURL(/.*okta\.com.*/);
    });
  },
);
