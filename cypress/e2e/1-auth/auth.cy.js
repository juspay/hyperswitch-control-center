import * as helper from "../../support/helper";
import SignInPage from "../../support/pages/auth/SignInPage";
import SignUpPage from "../../support/pages/auth/SignUpPage";
import ResetPasswordPage from "../../support/pages/auth/ResetPasswordPage";
import { reset } from "mixpanel-browser";

const signinPage = new SignInPage();
const signupPage = new SignUpPage();
const resetPasswordPage = new ResetPasswordPage();

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
});

describe("Sign in", () => {
  it("should verify all required components on the login page", () => {
    cy.visit("/");
    cy.url().should("include", "/dashboard/login");

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
    signinPage.signinButton.should("be.visible");
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

  it("should login successfully with email containing spaces", () => {
    const email = helper.generateUniqueEmail();
    cy.visit("/");
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));

    cy.url().should("include", "/dashboard/home");
  });

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
      .should("contain", "Use any authenticator app to complete the setup")
      .and(
        "contain",
        "Follow these steps to configure two factor authentication",
      )
      .and(
        "contain",
        "Scan the QR code shown on the screen with your authenticator application",
      )
      .and(
        "contain",
        "Enter the OTP code displayed on the authenticator app in below text field or textbox",
      );

    signinPage.otpBox2FA.should(
      "contain",
      "Enter a 6-digit authentication code generated by you authenticator app",
    );
    signinPage.otpBox2FA
      .children()
      .eq(1)
      .find("div.w-16.h-16")
      .should("have.length", 6);

    signinPage.skip2FAButton.should("be.visible");
    signinPage.enable2FA
      .should("be.visible")
      .and("be.disabled")
      .and("contain", "Enable 2FA");
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

    signinPage.otpBox2FA
      .children()
      .eq(1)
      .find("div.w-16.h-16")
      .each(($input, index) => {
        cy.wrap($input).type(otp.charAt(index));
      });

    signinPage.enable2FA.click();

    cy.contains("Invalid TOTP").should("be.visible");
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
});
