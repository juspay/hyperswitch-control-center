import * as helper from "../../support/helper";
import SignInPage from "../../support/pages/auth/SignInPage";
import SignUpPage from "../../support/pages/auth/SignUpPage";

const signinPage = new SignInPage();
const signupPage = new SignUpPage();

describe("Sign up", () => {
  let email = "";

  // check if the permissions and access level allow the test to run
  beforeEach(function () {
    if (!Cypress.env("RBAC")) {
      email = helper.generateUniqueEmail();
      cy.signup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
    } else {
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
            cy.signup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
          },
        );
      } else {
        this.skip(); // Skip if no access level tag
      }
    }
  });

  it("@profile", () => {
    cy.visit("/");

    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();
    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");

    cy.get("[class='flex flex-col items-start']").children().eq(4).click();
    cy.get("[aria-label='Edit']").click({ force: true });

    cy.get(
      '[class="w-full p-2 bg-transparent focus:outline-none text-md !py-0 text-nd_gray-600"]',
    )
      .clear()
      .type("new_profile_name");

    cy.get('[data-icon="nd-check"]').eq(1).click();
  });

  it("test case", () => {
    cy.visit("/");
  });
});
