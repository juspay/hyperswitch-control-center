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
  it("should successfully invite a user and verify received invite", () => {
    cy.get('[data-testid="settings"]').click();
    cy.get('[data-testid="users"]').click();
    cy.get('[data-button-for="inviteUsers"]').click();
    cy.get('[class="w-full cursor-text"]').type(helper.generateUniqueEmail());
    cy.get(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    ).click();
    cy.get(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    ).click();
    cy.get('[class="mr-5"]').eq(0).click();
    cy.get('[data-button-for="sendInvite"').click();

    cy.visit(Cypress.env("MAIL_URL"));
    cy.get("div.messages > div:nth-child(1)").click();
    cy.wait(1000);
    cy.get("iframe").then(($iframe) => {
      cy.get('[class="ng-binding"]').should(
        "contain",
        "You have been invited to join Hyperswitch Community",
      );
    });
  });
});
