import * as helper from "../../support/helper";
import SignInPage from "../../support/pages/auth/SignInPage";
import SignUpPage from "../../support/pages/auth/SignUpPage";
import ResetPasswordPage from "../../support/pages/auth/ResetPasswordPage";
import HomePage from "../../support/pages/homepage/HomePage";
import { authenticator } from "otplib";

const signinPage = new SignInPage();
const signupPage = new SignUpPage();
const resetPasswordPage = new ResetPasswordPage();
const homepage = new HomePage();

describe("Sign up", () => {
  it("should verify all components on the sign-up page", () => {
    cy.visit_signupPage();

    signupPage.headerText.should("contain", "Welcome to Hyperswitch");
    signupPage.signInLink.should("contain", "Sign in");
    signupPage.emailInput.should(
      "have.attr",
      "placeholder",
      "Enter your Email",
    );
    signupPage.signUpButton
      .contains("Get started, for free!")
      .should("be.visible");
    signupPage.signUpButton.should("be.disabled");
    signupPage.footerText.should("be.visible");
    signinPage.tcText.should("be.visible");
  });

  it("should display an error message for an invalid email", () => {
    const invalidEmails = [
      "@#$%",
      "plainaddress",
      "missing@domain",
      "user@.com",
      "user@domain..com",
      "user@domain,com",
      "user@domain.123",
      "user@domain.c",
      "user@domain.",
      "user@.com",
      "12345678",
      "abc@@xy.zi",
      "@com.in",
      "abc.in",
      "abc..xyz@abc.com",
    ];

    cy.visit_signupPage();

    invalidEmails.forEach((invalidEmail) => {
      signupPage.emailInput.clear();

      signupPage.emailInput.type(invalidEmail).blur();
      signupPage.invalidInputError
        .should("be.visible")
        .and("contain", "Please enter valid Email ID");
      signupPage.signUpButton.should("be.disabled");

      signupPage.emailInput.clear().type(Cypress.env("CYPRESS_USERNAME"));
      signupPage.invalidInputError.should("not.exist");
    });
  });

  it("should show success message page after using magic link", () => {
    cy.visit_signupPage();
    signinPage.signUpLink.click();
    signupPage.emailInput.type(Cypress.env("CYPRESS_USERNAME"));

    signupPage.signUpButton.click();

    signupPage.headerText.should("contain", "Please check your inbox");
    signupPage.headerText
      .next("div")
      .should("contain", "A magic link has been sent to")
      .should("contain", Cypress.env("CYPRESS_USERNAME"));
    signupPage.footerText.should("be.visible").should("contain", "Cancel");
  });

  it("should verify password masking while signup", () => {
    const email = helper.generateUniqueEmail();
    const password = Cypress.env("CYPRESS_PASSWORD");

    cy.visit_signupPage();
    signupPage.emailInput.type(email);
    signupPage.signUpButton.click();

    cy.redirect_from_mail_inbox();
    signinPage.skip2FAButton.click();

    resetPasswordPage.createPassword
      .should("have.attr", "type", "password")
      .type(password);
    resetPasswordPage.confirmPassword
      .should("have.attr", "type", "password")
      .type(password);

    resetPasswordPage.eyeIcon.eq(0).click();
    resetPasswordPage.createPassword.should("have.attr", "type", "text");
    resetPasswordPage.createPassword.should("have.value", password);

    resetPasswordPage.eyeIcon.click();
    resetPasswordPage.confirmPassword.should("have.attr", "type", "text");
    resetPasswordPage.confirmPassword.should("have.value", password);
  });

  it("should be able to sign up using magic link", () => {
    const email = helper.generateUniqueEmail();
    const password = Cypress.env("CYPRESS_PASSWORD");

    cy.visit_signupPage();
    signupPage.emailInput.type(email);
    signupPage.signUpButton.click();
    signupPage.headerText.should("contain", "Please check your inbox");

    cy.redirect_from_mail_inbox();

    // Skip 2FA
    signinPage.skip2FAButton.click();
    // Set password
    resetPasswordPage.createPassword.type(password);
    resetPasswordPage.confirmPassword.type(password);
    resetPasswordPage.confirmButton.click();
    // Login to dashboard
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(password);
    signinPage.signinButton.click();
    // Skip 2FA
    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");
  });

  it("should navigate back to the login page when the `cancel` button in signup page is clicked", () => {
    cy.visit_signupPage();
    signinPage.signUpLink.click();
    signupPage.emailInput.type(Cypress.env("CYPRESS_USERNAME"));

    signupPage.signUpButton.click();

    signupPage.footerText.click();
    cy.url().should("include", "/login");
  });
});

describe("Sign in", () => {
  it("should verify all components on the signin page", () => {
    cy.visit("/");

    signinPage.headerText.should("contain", "Hey there, Welcome back!");
    signinPage.signUpLink.should("contain", "Sign up");
    signinPage.emailInput.should("be.visible");
    signupPage.emailInput.should(
      "have.attr",
      "placeholder",
      "Enter your Email",
    );
    signinPage.passwordInput.should("be.visible");
    signupPage.passwordInput.should(
      "have.attr",
      "placeholder",
      "Enter your Password",
    );
    signinPage.forgetPasswordLink
      .should("be.visible")
      .and("contains.text", "Forgot Password?");
    signinPage.signinButton.should("be.visible");
    signinPage.emailSigninLink
      .should("be.visible")
      .and("contains.text", "sign in with an email");
    signinPage.tcText.should("exist");
    signinPage.footerText.should("exist");
  });

  it("should return to login page when clicked on 'Sign in'", () => {
    cy.visit("/");
    signinPage.signUpLink.click();
    cy.url().should("include", "/register");

    signupPage.headerText.should("contain", "Welcome to Hyperswitch");
    signupPage.signInLink.click();

    cy.url().should("include", "/login");
    signinPage.headerText.should("contain", "Hey there, Welcome back!");
  });

  it("should successfully login in with valid credentials", () => {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.visit("/");
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();
    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");
  });

  it("should display an error message with invalid credentials", () => {
    cy.visit("/");

    signinPage.emailInput.type("abc@gmail.com");
    signinPage.passwordInput.type("aAbcd?");
    signinPage.signinButton.click();

    signinPage.invalidCredsToast.should("be.visible");
  });

  it("should successfully login using magic link for registered user", () => {
    const email = helper.generateUniqueEmail();
    const password = Cypress.env("CYPRESS_PASSWORD");

    cy.visit_signupPage();
    signupPage.emailInput.type(email);
    signupPage.signUpButton.click();
    signupPage.headerText.should("contain", "Please check your inbox");

    cy.redirect_from_mail_inbox();

    signinPage.skip2FAButton.click();

    resetPasswordPage.createPassword.type(password);
    resetPasswordPage.confirmPassword.type(password);
    resetPasswordPage.confirmButton.click();

    signinPage.emailSigninLink.click();
    signinPage.emailInput.type(email);
    signinPage.signinButton.click();

    cy.signin_from_mail_inbox();

    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");
  });

  it("should display only email field when 'sign in with an email' is clicked", () => {
    cy.visit("/");

    cy.get('[data-testid="password"]').should("exist");
    cy.get('[data-testid="forgot-password"]').should("exist");

    signinPage.emailSigninLink.click();

    cy.get('[data-testid="password"]').should("not.exist");
    cy.get('[data-testid="forgot-password"]').should("not.exist");
  });

  it("should verify components displayed in 2FA setup page", () => {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.visit("/");
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();

    signinPage.headerText2FA.should(
      "contain",
      "Enable Two Factor Authentication",
    );

    signinPage.instructions2FA
      .should("contain", "Follow these steps to configure 2FA:")
      .and("contain", "Scan the QR code with your authenticator app")
      .and("contain", "Enter the 6-digit code shown in your app below");

    signinPage.otpBoxHeader.should(
      "contain",
      "Then, Enter a 6-digit code generated by your authenticator.",
    );
    signinPage.otpBox2FA.children().should("have.length", 6);

    signinPage.skip2FAButton.should("be.visible");
    signinPage.enable2FA
      .should("be.visible")
      .and("be.disabled")
      .and("contain", "Enter Code");
    signinPage.footerText2FA
      .should("be.visible")
      .contains("Log in with a different account?");
    signinPage.footerText2FA.should("contain", "Click here to log out.");
  });

  it("should display error message with invalid TOTP in 2FA page", () => {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
    const otp = "123456";

    cy.visit("/");
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();

    signinPage.otpBox2FA.find("div.w-16.h-16").each(($input, index) => {
      cy.wrap($input).type(otp.charAt(index));
    });

    signinPage.enable2FA.click();

    cy.contains("Incorrect code, please try again").should("be.visible");
  });

  it("should navigate to homepage when 2FA is skipped", () => {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.visit("/");
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();

    signinPage.headerText2FA.should(
      "contain",
      "Enable Two Factor Authentication",
    );

    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");
  });

  it("should navigate to signin page when 'Click here to log out.' is clicked in 2FA page", () => {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.visit("/");
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();

    signinPage.headerText2FA.should(
      "contain",
      "Enable Two Factor Authentication",
    );

    signinPage.footerText2FA.children().eq(0).click();

    signinPage.headerText.should("contain", "Hey there, Welcome back!");
  });
});

(Cypress.env("CYPRESS_SSO_BASE_URL") ? describe : describe.skip)(
  "Okta SSO tests",
  () => {
    let auth_id = "";

    before(() => {
      cy.signup_API(
        Cypress.env("CYPRESS_SSO_USERNAME"),
        Cypress.env("CYPRESS_SSO_PASSWORD"),
      );
      cy.create_auth();
      cy.get_authID_by_email().then((authId) => {
        auth_id = authId;
      });
    });

    it("should display “Continue with Okta” button when login URL is accessed with valid okta enabled auth_id", () => {
      cy.visit(`/?auth_id=${auth_id}`);

      signinPage.continueWithOktaButton.should("be.visible");
      signinPage.continueWithOktaButton.should("contain", "Continue with Okta");
    });

    it("should not display the SSO button when login URL is accessed without, with empty, or with invalid auth_id parameter", () => {
      cy.visit("/");
      signinPage.continueWithOktaButton.should("not.exist");

      cy.visit("/?auth_id=");
      signinPage.continueWithOktaButton.should("not.exist");

      cy.visit("/?auth_id=abcd");
      signinPage.continueWithOktaButton.should("not.exist");
    });

    it("should redirect to Okta login page when “Continue with Okta” button is clicked", () => {
      cy.visit(`/?auth_id=${auth_id}`);

      signinPage.continueWithOktaButton.click();

      cy.waitUntil(() => cy.url().then((url) => url.includes("okta.com")), {
        errorMsg: "Did not reach okta.com in time",
        timeout: 10000,
        interval: 300,
      });
    });

    it("should redirect to dashboard homepage after entering valid Okta credentials ", () => {
      cy.visit(`/?auth_id=${auth_id}`);

      signinPage.continueWithOktaButton.click();

      cy.waitUntil(() => cy.url().then((url) => url.includes("okta.com")), {
        errorMsg: "Did not reach okta.com in time",
        timeout: 10000,
        interval: 300,
      });

      signinPage.oktaEmailInput.type(Cypress.env("CYPRESS_SSO_USERNAME"));
      signinPage.oktaNextButton.click();
      signinPage.oktaPasswordInput.type(Cypress.env("CYPRESS_SSO_PASSWORD"));
      signinPage.oktaVerifynButton.click();

      cy.waitUntil(
        () => cy.url().then((url) => url.includes("/dashboard/home")),
        {
          errorMsg: "Did not reach /dashboard/home in time",
          timeout: 10000,
          interval: 300,
        },
      );
    });

    it("should show authentication error after entering invalid Okta credentials and stay on Okta login page", () => {
      cy.visit(`/?auth_id=${auth_id}`);

      signinPage.continueWithOktaButton.click();

      signinPage.oktaEmailInput.type("demo.user@test.com");
      signinPage.oktaNextButton.click();
      signinPage.oktaPasswordInput.type("Test@1234");
      signinPage.oktaVerifynButton.click();

      signinPage.oktaErrorMessage
        .should("be.visible")
        .should("contain", "Unable to sign in");

      cy.url().should("contain", "okta.com");
    });

    it(`should automatically log in and redirect to the dashboard after logout once initial Okta login is successfull`, () => {
      cy.visit(`/?auth_id=${auth_id}`);

      signinPage.continueWithOktaButton.click();

      signinPage.oktaEmailInput.type(Cypress.env("CYPRESS_SSO_USERNAME"));
      signinPage.oktaNextButton.click();
      signinPage.oktaPasswordInput.type(Cypress.env("CYPRESS_SSO_PASSWORD"));
      signinPage.oktaVerifynButton.click();

      cy.waitUntil(
        () => cy.url().then((url) => url.includes("/dashboard/home")),
        {
          errorMsg: "Did not reach /dashboard/home in time",
          timeout: 10000,
          interval: 300,
        },
      );

      homepage.user_account.click();
      homepage.sign_out.click();

      signinPage.continueWithOktaButton.click();

      cy.waitUntil(
        () => cy.url().then((url) => url.includes("/dashboard/home")),
        {
          errorMsg: "Did not reach /dashboard/home in time",
          timeout: 10000,
          interval: 300,
        },
      );
    });

    it(`should require full Okta login after logged out from okta`, () => {
      cy.visit(`/?auth_id=${auth_id}`);

      signinPage.continueWithOktaButton.click();

      signinPage.oktaEmailInput.type(Cypress.env("CYPRESS_SSO_USERNAME"));
      signinPage.oktaNextButton.click();
      signinPage.oktaPasswordInput.type(Cypress.env("CYPRESS_SSO_PASSWORD"));
      signinPage.oktaVerifynButton.click();

      cy.waitUntil(
        () => cy.url().then((url) => url.includes("/dashboard/home")),
        {
          errorMsg: "Did not reach /dashboard/home in time",
          timeout: 10000,
          interval: 300,
        },
      );

      homepage.user_account.click();
      homepage.sign_out.click();

      cy.request({
        method: "GET",
        url: `${Cypress.env("CYPRESS_SSO_BASE_URL")}/login/signout`,
        followRedirect: false,
      });

      signinPage.continueWithOktaButton.click();

      cy.waitUntil(() => cy.url().then((url) => url.includes("okta.com")), {
        errorMsg: "Did not reach okta.com in time",
        timeout: 10000,
        interval: 300,
      });
      cy.url().should("contain", "okta.com");
    });
  },
);

describe("Forgot password", () => {
  it("should verify all components in forgot passowrd page", () => {
    cy.visit("/");
    signinPage.forgetPasswordLink.click();
    cy.url().should("include", "/dashboard/forget-password");
    signinPage.forgetPasswordHeader.should("contain", "Forgot Password?");

    signinPage.emailInput.should("be.visible");
    signinPage.emailInput
      .children()
      .eq(0)
      .should("have.attr", "placeholder", "Enter your Email");

    signinPage.resetPasswordButton.should("be.visible").and("be.disabled");
    signinPage.cancelForgetPassword
      .should("be.visible")
      .and("contain", "Cancel");
  });

  it("should display fail toast when unregistered email is used", () => {
    cy.visit("/");
    signinPage.forgetPasswordLink.click();

    signinPage.emailInput.type("abcde@gmail.com");

    signinPage.resetPasswordButton.click();

    cy.get(`[data-toast="Forgot Password Failed, Try again"]`)
      .should("be.visible")
      .and("contain", "Forgot Password Failed, Try again");
  });

  it("should display success message when registered email is used", () => {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.visit("/");
    signinPage.forgetPasswordLink.click();
    signinPage.emailInput.type(email);
    signinPage.resetPasswordButton.click();

    cy.get(`[data-toast="Please check your registered e-mail"]`)
      .should("be.visible")
      .and("contain", "Please check your registered e-mail");
    cy.get(`[data-testid="card-header"]`).should(
      "contain",
      "Please check your inbox",
    );
    cy.get(`[class="flex-col items-center justify-center"]`)
      .children()
      .eq(0)
      .should("contain", "A reset password link has been sent to");
    cy.get(`[class="flex-col items-center justify-center"]`)
      .children()
      .eq(1)
      .should("contain", email);
    cy.get(`[class="w-full flex justify-center"]`).should("contain", "Cancel");
  });

  it("should reset password through mail and login successfully", () => {
    const email = helper.generateUniqueEmail();
    let new_password = "Test@123";
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.visit("/");
    signinPage.forgetPasswordLink.click();
    signinPage.emailInput.type(email);
    signinPage.resetPasswordButton.click();
    cy.redirect_from_mail_inbox();

    signinPage.skip2FAButton.click();
    resetPasswordPage.newPasswordField.type(new_password);
    resetPasswordPage.confirmPasswordField.type(new_password);
    resetPasswordPage.confirmButton.click();
    cy.url().should("include", "/login");
    cy.get(`[data-toast="Password Changed Successfully"]`).should(
      "contain",
      "Password Changed Successfully",
    );

    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(new_password);
    signinPage.signinButton.click();
    signinPage.skip2FAButton.click();
    cy.url().should("include", "/dashboard/home");
  });

  //TODO
  //Verify "Cancel" link redirects to login page
});

describe.skip("TOTP flows", () => {
  it("should successfully setup 2FA while signup", () => {
    cy.intercept("GET", "**/2fa/totp/begin", (req) => {
      req.continue((res) => {
        const totpSecret = res.body.secret.secret;
        Cypress.env("TOTP_SECRET", totpSecret);
      });
    }).as("generateTotp");

    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.visit("/");
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();

    cy.get('[viewBox="0 0 41 41"]').should("be.visible");

    cy.wait("@generateTotp").then(() => {
      const secret = Cypress.env("TOTP_SECRET");
      const token = authenticator.generate(secret);

      signinPage.otpBox2FA
        .children()
        .eq(1)
        .find("div.w-16.h-16")
        .each(($input, index) => {
          cy.wrap($input).type(token.charAt(index));
        });

      signinPage.enable2FA.click();

      cy.get('[data-button-for="download"]').click();

      cy.url().should("include", "/dashboard/home");
    });
  });
});
