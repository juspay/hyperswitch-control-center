import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";

const homePage = new HomePage();

beforeEach(function () {
  const email = helper.generateUniqueEmail();
  cy.visit_signupPage();
  cy.sign_up_with_email(email, Cypress.env("CYPRESS_PASSWORD"));
  cy.url().should("include", "/dashboard/home");
  homePage.enterMerchantName.type("Test_merchant");
  homePage.onboardingSubmitButton.click();
});

describe("Users", () => {
  // it("verify inviting an user and reception the invitation email", () => {
  //   // Navigate to the Users section in Settings
  //   cy.get('[data-testid="settings"]').click();
  //   cy.get('[data-testid="users"]').click();

  //   // Initiate the user invitation process
  //   cy.get('[data-button-for="inviteUsers"]').click();
  //   cy.get('[class="w-full cursor-text"]').type(helper.generateUniqueEmail());
  //   cy.get(
  //     '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
  //   ).click();
  //   cy.get(
  //     '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
  //   ).click();
  //   cy.get('[class="mr-5"]').eq(0).click();
  //   cy.get('[data-button-for="sendInvite"').click();

  //   // Verify the invitation email in the mail server
  //   const MAIL_URL = "http://localhost:8025";
  //   cy.visit(`${MAIL_URL}`);
  //   cy.get("div.messages > div:nth-child(1)").click();
  //   cy.wait(1000);
  //   cy.get("iframe").then(($iframe) => {
  //     cy.get('[class="ng-binding"]').should(
  //       "contain",
  //       "You have been invited to join Hyperswitch Community",
  //     );
  //   });
  // });

  it("verify Organization Admin is the only user before inviting any user", () => {
    // Navigate to the Users section in Settings
    cy.get('[data-testid="settings"]').click();
    cy.get('[data-testid="users"]').click();

    // Verify the number of columns and table headers
    cy.get("table#table thead tr th").should("have.length", 2);
    cy.get("table#table thead tr th").eq(0).should("have.text", "Email");
    cy.get("table#table thead tr th").eq(1).should("have.text", "Role");

    // Verify the table has only one row
    cy.get("table#table tbody tr").should("have.length", 1);

    // Verify the first cell contains an email
    cy.get("table#table tbody tr td")
      .eq(0)
      .invoke("text")
      .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);

    // Verify the second cell contains "Organization Admin"
    cy.get("table#table tbody tr td")
      .eq(1)
      .should("have.text", "Organization Admin");
  });
});
