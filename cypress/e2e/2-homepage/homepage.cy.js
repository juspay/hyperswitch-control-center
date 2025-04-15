import * as helper from "../../support/helper";
import SignInPage from "../../support/pages/auth/SignInPage";
import SignUpPage from "../../support/pages/auth/SignUpPage";

const signinPage = new SignInPage();
const signupPage = new SignUpPage();

describe("Sign up", () => {
  let email = "";

  // check if the permissions and access level allow the test to run
  beforeEach(function () {
    if (Cypress.env("RBAC") == "") {
      email = helper.generateUniqueEmail();
      cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
    }
    // add valid param check
    else {
      const testName = Cypress.currentTest.title;
      const tags = testName.match(/@([a-zA-Z0-9_-]+)/g) || []; // Extract all tags from the test name

      // Check if the test case name contains any of the tags in ["org", "merchant", "profile"]
      const containsAccessLevelTag = tags.some((tag) =>
        ["@org", "@merchant", "@profile"].includes(tag),
      );

      if (containsAccessLevelTag) {
        cy.checkPermissionsFromTestName("@account " + testName).then(
          (shouldSkip) => {
            if (shouldSkip) {
              this.skip(); // Skip if test is skippable
            }

            // Create user with role passed from env            // TODO: create a function to pass role and access level to create the user
            email = helper.generateUniqueEmail();
            cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
          },
        );
      } else {
        this.skip(); // Skip if no access level tag
      }
    }
  });

  it("@merchant should run for both org and custom role", () => {
    cy.visit("/");

    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();
    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");

    cy.get("[class='md:max-w-40 max-w-16']").click();
    cy.get("[data-icon='nd-plus']").click({ force: true });

    cy.get("[name='profile_name']").clear().type("new_profile_name");

    cy.get("[data-button-for='addProfile']").click();
  });

  it("should only for org user", () => {
    cy.visit("/");
  });

  // it("should process a payment using the SDK", () => {
  // });
});
