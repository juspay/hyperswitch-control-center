import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";

const homePage = new HomePage();

beforeEach(function () {
  // Generate a unique email for the test
  const email = helper.generateUniqueEmail();

  // Visit the signup page
  cy.visit_signupPage();

  // Sign up with the generated email and a predefined password
  cy.sign_up_with_email(email, Cypress.env("CYPRESS_PASSWORD"));

  // Verify that the URL includes "/dashboard/home" after signup
  cy.url().should("include", "/dashboard/home");

  // Enter the merchant name in the input field
  homePage.enterMerchantName.type("Test_merchant");

  // Click the submit button to complete onboarding
  homePage.onboardingSubmitButton.click();

  // Navigate to the Users section in Settings
  cy.get('[data-testid="settings"]').click();
  cy.get('[data-testid="users"]').click();
});

describe("Users - UI", () => {
  context("verify the UI of the Users page", () => {
    it("Verify the page title is Team management", () => {
      cy.get("div.text-fs-28.font-semibold.leading-10").should(
        "have.text",
        "Team management",
      );
    });

    it("Verify the 'Users' tab UI", () => {
      cy.get(
        "div.font-semibold.text-black.dark\\:text-primary.text-blue-600",
      ).contains("Users");
    });

    it("Verify the 'Roles' tab UI", () => {
      cy.get("div.text-jp-gray-900.text-opacity-50").contains("Roles");
    });

    it("Verify the page has a table with id 'table'", () => {
      cy.get("table#table").should("exist");
    });

    it("Verify the table has a header with id 'header'", () => {
      cy.get("table#table thead").should("exist");
    });

    it("Verify the table has a body with id 'body'", () => {
      cy.get("table#table tbody").should("exist");
    });
  });
});

describe("Users - Listings", () => {
  context(
    "verify Organization Admin is the only user before inviting any user",
    () => {
      it("Verify the number of columns and table headers", () => {
        cy.get("table#table thead tr th").should("have.length", 2);
      });

      it("Verify table headers are Email and Role", () => {
        cy.get("table#table thead tr th").eq(0).should("have.text", "Email");
        cy.get("table#table thead tr th").eq(1).should("have.text", "Role");
      });

      it("Verify the users list table has only one row", () => {
        cy.get("table#table tbody tr").should("have.length", 1);
      });

      it("Verify the first cell of the row contains an email", () => {
        cy.get("table#table tbody tr td")
          .eq(0)
          .invoke("text")
          .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);
      });

      it("Verify the second cell contains Organization Admin", () => {
        cy.get("table#table tbody tr td")
          .eq(1)
          .should("have.text", "Organization Admin");
      });
    },
  );
});
