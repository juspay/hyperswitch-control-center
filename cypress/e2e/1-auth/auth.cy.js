import * as helper from "../../support/helper";
import SignInPage from "../../support/pages/auth/SignInPage";
import SignUpPage from "../../support/pages/auth/SignUpPage";

const signinPage = new SignInPage();
const signupPage = new SignUpPage();

describe("Sign up", () => {
  it("should verify all components on the sign-up page", () => {
    cy.visit("/");

    signinPage.signUpLink.click();
    cy.url().should("include", "/register");

    signupPage.headerText.should("contain", "Welcome to Hyperswitch");
    signupPage.signInLink.should("contain", "Sign in");
    signupPage.emailInput.should(
      "have.attr",
      "placeholder",
      "Enter your Email",
    );
    signupPage.passwordInput.should(
      "have.attr",
      "placeholder",
      "Enter your Password",
    );
    signupPage.signUpButton.contains("Get started, for free!").should("exist");
    signupPage.signUpButton.should("be.disabled");

    signinPage.tcText.should("exist");
    signinPage.footerText.should("exist");
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

    cy.visit("/register");

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

  it("should display an error message for an invalid password", () => {
    const validPassword = "vaLidP@ssw0rd";
    const invalidPasswords = [
      {
        password: "gdfRT5^",
        expectedMessage:
          "Your password is not strong enough. Password size must be more than 8",
      },
      {
        password: "abcdefgh",
        expectedMessage:
          "Your password is not strong enough. A good password must contain atleast uppercase,numeric,special character",
      },
      {
        password: "ABCDEFGH",
        expectedMessage:
          "Your password is not strong enough. A good password must contain atleast lowercase,numeric,special character",
      },
      {
        password: "1234567",
        expectedMessage:
          "Your password is not strong enough. Password size must be more than 8",
      },
      {
        password: "!@#$%^&*",
        expectedMessage:
          "Your password is not strong enough. A good password must contain atleast uppercase,lowercase,numeric character",
      },
      {
        password: "passWORD",
        expectedMessage:
          "Your password is not strong enough. A good password must contain atleast numeric,special character",
      },
      {
        password: "passWORD1",
        expectedMessage:
          "Your password is not strong enough. A good password must contain atleast special character",
      },
      {
        password: "passWORD@",
        expectedMessage:
          "Your password is not strong enough. A good password must contain atleast numeric character",
      },
      {
        password: "1234%^&*",
        expectedMessage:
          "Your password is not strong enough. A good password must contain atleast uppercase,lowercase character",
      },
      {
        password: "3123 As@6",
        expectedMessage: "Password should not contain whitespaces.",
      },
    ];

    cy.visit("/register");

    signupPage.emailInput.type(Cypress.env("CYPRESS_USERNAME"));

    invalidPasswords.forEach(({ password, expectedMessage }) => {
      signupPage.passwordInput.clear().type(password).blur();
      signupPage.invalidInputError
        .should("be.visible")
        .and("contain", expectedMessage);
      signupPage.signUpButton.should("be.disabled");

      signupPage.passwordInput.clear().type(validPassword).blur();
      signupPage.invalidInputError.should("not.exist");
    });
  });

  it("should allow users to signin in with a valid email and password", () => {
    const email = helper.generateUniqueEmail();
    cy.visit("/register");

    signupPage.emailInput.type(email);
    signupPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signupPage.signUpButton.click();
    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");
  });

  it("should verify all components on the signup page when email feature flag is enabled", () => {
    cy.enable_email_feature_flag();
    signinPage.signUpLink.click();

    signupPage.emailInput.should("be.visible");
    signupPage.emailInput.should(
      "have.attr",
      "placeholder",
      "Enter your Email",
    );
    signupPage.signUpButton.should("contain", "Get started, for free!");
    signupPage.footerText.should("be.visible");
  });

  it("should show success message page after using magic link", () => {
    cy.enable_email_feature_flag();
    signinPage.signUpLink.click();
    signupPage.emailInput.type(Cypress.env("CYPRESS_USERNAME"));

    cy.mock_magic_link_signin_success();
    signupPage.signUpButton.click();
    cy.wait("@getMagicLinkSuccess");

    signupPage.headerText.should("contain", "Please check your inbox");

    signupPage.headerText
      .next("div")
      .should("contain", "A magic link has been sent to")
      .should("contain", Cypress.env("CYPRESS_USERNAME"));

    signupPage.footerText.should("be.visible").should("contain", "Cancel");
  });

  it("should navigate back to the login page when the cancel button in signup page is clicked", () => {
    cy.enable_email_feature_flag();
    signinPage.signUpLink.click();
    signupPage.emailInput.type(Cypress.env("CYPRESS_USERNAME"));

    cy.mock_magic_link_signin_success();
    signupPage.signUpButton.click();
    cy.wait("@getMagicLinkSuccess");

    signupPage.footerText.click();
    cy.url().should("include", "/login");
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
    cy.singup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
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
    signinPage.passwordInput.type("aAbcd");
    signinPage.signinButton.click();

    signinPage.invalidCredsToast.should("be.visible");
  });

  it("should login successfully with email containing spaces", () => {
    const email = helper.generateUniqueEmail();
    cy.visit("/");
    cy.singup_curl(email, Cypress.env("CYPRESS_PASSWORD"));

    signinPage.signin(` ${email} `, Cypress.env("CYPRESS_PASSWORD"));

    cy.url().should("include", "/dashboard/home");
  });

  it("should verify all components on the signin page when email feature flag is enabled", () => {
    cy.enable_email_feature_flag();

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
    cy.enable_email_feature_flag();

    cy.get('[data-testid="password"]').should("exist");
    cy.get('[data-testid="forgot-password"]').should("exist");

    signinPage.emailSigninLink.click();

    cy.get('[data-testid="password"]').should("not.exist");
    cy.get('[data-testid="forgot-password"]').should("not.exist");
  });

  it("should verify components displayed in 2FA setup page", () => {
    const email = helper.generateUniqueEmail();
    cy.singup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
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
    cy.singup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
    const otp = "123456";

    cy.visit("/");
    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();

    signinPage.headerText2FA.should(
      "contain",
      "Enable Two Factor Authentication",
    );

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
    cy.singup_curl(email, Cypress.env("CYPRESS_PASSWORD"));

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

  it("should navigate to signin page when 'Click here to log out.' is clickeed in 2FA page", () => {
    const email = helper.generateUniqueEmail();
    cy.singup_curl(email, Cypress.env("CYPRESS_PASSWORD"));

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
    cy.enable_email_feature_flag();

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
});
