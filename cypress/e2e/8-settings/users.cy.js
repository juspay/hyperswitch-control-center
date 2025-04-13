import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";

const homePage = new HomePage();
let email;

beforeEach(function () {
  // Generate a unique email for the test
  email = helper.generateUniqueEmail();

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

    it("Verify the UI of 'Users' tab", () => {
      cy.get(
        "div.font-semibold.text-black.dark\\:text-primary.text-blue-600",
      ).contains("Users");
    });

    it("Verify the UI of 'Roles' tab", () => {
      cy.get("div.text-jp-gray-900.text-opacity-50").contains("Roles");
    });

    it("Verify the UI of search input", () => {
      cy.get('input[placeholder="Search by name or email.."]').should("exist");
    });

    it("Verify the UI of Data Filter Dropdown", () => {
      cy.get('div[data-icon="settings-new"]').should("exist");
      cy.get("p.text-jp-gray-900").contains("View data for:");
      cy.get('div[data-icon="arrow-without-tail"]').should("exist");
    });

    it("Verify the UI Functionality of the Data Filter Dropdown by clicking on gear icon", () => {
      cy.get('div[data-icon="settings-new"]').click({ force: true });
      cy.get('div[data-dropdown-value="All"]').contains("(Default)");
      cy.get('div[data-dropdown-value^="org_"]').contains("(Organization)");
      cy.get('div[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
      cy.get('div[data-dropdown-value="default"]').contains("(Profile)");
    });

    it('Verify the UI Functionality of the Data Filter Dropdown by clicking on "View data for:"', () => {
      cy.get("p.text-jp-gray-900").click({ force: true });
      cy.get('div[data-dropdown-value="All"]').contains("(Default)");
      cy.get('div[data-dropdown-value^="org_"]').contains("(Organization)");
      cy.get('div[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
      cy.get('div[data-dropdown-value="default"]').contains("(Profile)");
    });

    it("Verify the UI Functionality of the Data Filter Dropdown by clicking on arrow without tail icon", () => {
      cy.get('div[data-icon="arrow-without-tail"]').click({ force: true });
      cy.get('div[data-dropdown-value="All"]').contains("(Default)");
      cy.get('div[data-dropdown-value^="org_"]').contains("(Organization)");
      cy.get('div[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
      cy.get('div[data-dropdown-value="default"]').contains("(Profile)");
    });

    it('Verify the page has a "Invite users" button', () => {
      cy.get('button[data-button-for="inviteUsers"').should("exist");
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

describe("Users - Details", () => {
  beforeEach(function () {
    cy.get("table#table tbody tr").click();
  });

  context("verify the UI of the Users page", () => {
    it("Verify the page title is Team management", () => {
      cy.get("div.text-fs-28.font-semibold.leading-10").should(
        "have.text",
        "Team management",
      );
    });

    it("Verify the breadcrumb has the user's email", () => {
      cy.get("div[data-breadcrumb]").should("exist");
      cy.get("div[data-breadcrumb]").should("have.length", 2);
      cy.get("div[data-breadcrumb]")
        .eq(0)
        .should("have.text", "Team management");
      cy.get("div[data-breadcrumb]").eq(1).should("have.text", email);
    });

    it("Verify the user's username is displayed", () => {
      const username =
        email.split("@")[0].charAt(0).toUpperCase() +
        email.split("@")[0].slice(1);
      cy.get("p.text-2xl.font-semibold.leading-8")
        .should("exist")
        .and("have.text", username);
    });

    it("Verify the user's email is displayed", () => {
      cy.get("p")
        .contains(email)
        .should("exist")
        .and("have.class", "text-grey-600")
        .and("have.class", "opacity-40");
    });

    it("Verify the existence of access details table", () => {
      cy.get("table").should("exist");
    });

    it("Verify the number of columns in the access details table", () => {
      cy.get("table th").should("have.length", 5); // There should be 4 columns
    });

    it("Verify the table headers", () => {
      cy.get("table th").eq(0).should("have.text", "Merchants");
      cy.get("table th").eq(1).should("have.text", "Profile Name"); // This should be Profiles
      cy.get("table th").eq(2).should("have.text", "Role");
      cy.get("table th").eq(3).should("have.text", "Status");
    });

    it("Verify the content of table rows", () => {
      cy.get("table tr")
        .eq(1)
        .within(() => {
          cy.get("td").eq(0).should("have.text", "All_merchants"); // This should be All Merchants
          cy.get("td").eq(1).should("have.text", "all_profiles"); // This should be All Profiles
          cy.get("td").eq(2).should("have.text", "Organization Admin");
          cy.get("td").eq(3).should("have.text", "Active");
        });
    });

    it("Verify the styling of the status indicator", () => {
      cy.get("table tr")
        .eq(1)
        .within(() => {
          cy.get("td")
            .eq(3)
            .find("p")
            .should("have.class", "text-green-700")
            .should("have.class", "bg-green-700")
            .should("have.class", "bg-opacity-20")
            .should("have.class", "rounded-full");
        });
    });
  });
});
