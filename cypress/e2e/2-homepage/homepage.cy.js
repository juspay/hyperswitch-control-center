import * as helper from "../../support/helper";
import SignInPage from "../../support/pages/auth/SignInPage";
import SignUpPage from "../../support/pages/auth/SignUpPage";

const signinPage = new SignInPage();
const signupPage = new SignUpPage();

describe("Sign up", () => {
  // beforeEach(function () {

  //     const role = "admin";
  //     const access = "merchant";

  //     const email = helper.generateUniqueEmail();
  //     cy.visit("/");
  //     cy.signup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
  //     signinPage.signin(email, Cypress.env("CYPRESS_PASSWORD"));

  //     cy.get('[data-testid="settings"]').click();
  //     cy.get('[data-testid="users"]').click();
  //     cy.get('[data-button-for="inviteUsers"]').click();
  //     cy.get('[name="email_list"]').clear().type("merchant@test.in")
  //     cy.get('[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]').click();
  //     cy.get('[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]').click();
  //     cy.get('[id="headlessui-menu-item-:r8:"]').click();
  //     cy.get('[data-button-for="sendInvite"]').click();
  //     cy.wait(2000);

  //     cy.visit("/");

  //     cy.signup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
  //   });

  // check if the permissions and access level allow the test to run
  beforeEach(function () {
    const testName = Cypress.currentTest.title;
    cy.checkPermissionsFromTestName(testName);
  });

  it("@analytics @profile @write", () => {
    const email = helper.generateUniqueEmail();
    cy.singup_curl(email, Cypress.env("CYPRESS_PASSWORD"));
    cy.visit("/");

    signinPage.emailInput.type(email);
    signinPage.passwordInput.type(Cypress.env("CYPRESS_PASSWORD"));
    signinPage.signinButton.click();
    signinPage.skip2FAButton.click();

    cy.url().should("include", "/dashboard/home");

    cy.get("[class='flex flex-col items-start']").children().eq(2).click();
    cy.get("[aria-label='Edit']").children().eq(1).click({ force: true });

    cy.get(
      '[class="w-full p-2 bg-transparent focus:outline-none text-md !py-0 text-nd_gray-600"]',
    )
      .clear()
      .type("new_profile_name");

    cy.get('[data-icon="nd-check"]').eq(1).click();
  });

  it.skip("@analytics @org @read", () => {
    cy.checkPermissionForTest(
      "workflow",
      Cypress.env("role"),
      Cypress.env("accessLevel"),
      "read",
    ).then((shouldRun) => {
      if (shouldRun) {
        // Test code for viewing workflow data
        cy.get('[data-testid="workflow-data"]').should("be.visible");
      } else {
        cy.log("Skipping test due to insufficient permissions or access level");
      }
    });
  });
});
