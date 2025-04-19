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
  it("Verify the UI of the Users page", () => {
    // Verify the page title
    cy.get("div.text-fs-28.font-semibold.leading-10").should(
      "have.text",
      "Team management",
    );

    // Verify the UI of 'Users' tab
    cy.get(
      "div.font-semibold.text-black.dark\\:text-primary.text-blue-600",
    ).contains("Users");

    // Verify the UI of 'Roles' tab
    cy.get("div.text-jp-gray-900.text-opacity-50").contains("Roles");

    // Verify the UI of search input
    cy.get('input[placeholder="Search by name or email.."]').should("exist");

    // Verify the functionality of the search input
    cy.get('input[placeholder="Search by name or email.."]').type(email);
    cy.get('input[placeholder="Search by name or email.."]').should(
      "have.value",
      email,
    );
    // Verify table exists and has exactly one row
    cy.get("table#table tbody tr").should("have.length", 1);
    // Verify the email in the first cell of the only row
    cy.get("table#table tbody tr")
      .first()
      .find("td")
      .first()
      .should("contain.text", email);
    // Clear the search input
    cy.get('input[placeholder="Search by name or email.."]').clear();
    cy.get('input[placeholder="Search by name or email.."]').type(
      "cypress+org_admin@test.com",
    );
    cy.get('input[placeholder="Search by name or email.."]').should(
      "have.value",
      "cypress+org_admin@test.com",
    );
    cy.get("div").contains("No Data Available").should("exist");

    // Verify the UI of Data Filter Dropdown
    cy.get('div[data-icon="settings-new"]').should("exist");
    cy.get("p.text-jp-gray-900").contains("View data for:");
    cy.get('div[data-icon="arrow-without-tail"]').should("exist");

    // Verify the UI Functionality of the Data Filter Dropdown by clicking on gear icon
    cy.get('div[data-icon="settings-new"]').click({ force: true });
    cy.get('div[data-dropdown-value="All"]').contains("(Default)");
    cy.get('div[data-dropdown-value^="org_"]').contains("(Organization)");
    cy.get('div[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
    cy.get('div[data-dropdown-value="default"]').contains("(Profile)");

    //Verify the UI Functionality of the Data Filter Dropdown by clicking on "View data for:
    cy.get("p.text-jp-gray-900").click({ force: true });
    cy.get('div[data-dropdown-value="All"]').contains("(Default)");
    cy.get('div[data-dropdown-value^="org_"]').contains("(Organization)");
    cy.get('div[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
    cy.get('div[data-dropdown-value="default"]').contains("(Profile)");

    // Verify the UI Functionality of the Data Filter Dropdown by clicking on arrow without tail icon
    cy.get('div[data-icon="arrow-without-tail"]').click({ force: true });
    cy.get('div[data-dropdown-value="All"]').contains("(Default)");
    cy.get('div[data-dropdown-value^="org_"]').contains("(Organization)");
    cy.get('div[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
    cy.get('div[data-dropdown-value="default"]').contains("(Profile)");

    // Verify the page has a clickable "Invite users" button
    cy.get('button[data-button-for="inviteUsers"]')
      .should("exist")
      .should("be.enabled")
      .should("not.be.disabled");
  });
});

describe("Users - Listings", () => {
  it("Verify User's Listing before inviting any user", () => {
    cy.get("table#table thead tr th").should("have.length", 2);

    // Verify table headers are Email and Role
    cy.get("table#table thead tr th").eq(0).should("have.text", "Email");
    cy.get("table#table thead tr th").eq(1).should("have.text", "Role");

    // Verify the users list table has only one row
    cy.get("table#table tbody tr").should("have.length", 1);

    // Verify the first cell of the row contains an email
    cy.get("table#table tbody tr td")
      .eq(0)
      .invoke("text")
      .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);

    // Verify the second cell contains Organization Admin
    cy.get("table#table tbody tr td")
      .eq(1)
      .should("have.text", "Organization Admin");
  });
});

describe("Users - Details", () => {
  beforeEach(function () {
    cy.get("table#table tbody tr").click();
  });

  it("Verify the UI of the Users page", () => {
    // Verify the page title is Team management
    cy.get("div.text-fs-28.font-semibold.leading-10").should(
      "have.text",
      "Team management",
    );

    // Verify the breadcrumb has the user's email
    cy.get("div[data-breadcrumb]").should("exist");
    cy.get("div[data-breadcrumb]").should("have.length", 2);
    cy.get("div[data-breadcrumb]").eq(0).should("have.text", "Team management");
    cy.get("div[data-breadcrumb]").eq(1).should("have.text", email);

    // Verify the user's username is displayed
    const username =
      email.split("@")[0].charAt(0).toUpperCase() +
      email.split("@")[0].slice(1);
    cy.get("p.text-2xl.font-semibold.leading-8")
      .should("exist")
      .and("have.text", username);

    // Verify the user's email is displayed
    cy.get("p")
      .contains(email)
      .should("exist")
      .and("have.class", "text-grey-600")
      .and("have.class", "opacity-40");

    // Verify the existence of access details table
    cy.get("table").should("exist");

    // Verify the number of columns in the access details table
    cy.get("table th").should("have.length", 5); // There should be 4 columns

    // Verify the table headers
    cy.get("table th").eq(0).should("have.text", "Merchants");
    cy.get("table th").eq(1).should("have.text", "Profile Name"); // This should be Profiles
    cy.get("table th").eq(2).should("have.text", "Role");
    cy.get("table th").eq(3).should("have.text", "Status");

    // Verify the content of table rows
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td").eq(0).should("have.text", "All_merchants"); // This should be All Merchants
        cy.get("td").eq(1).should("have.text", "all_profiles"); // This should be All Profiles
        cy.get("td").eq(2).should("have.text", "Organization Admin");
        cy.get("td").eq(3).should("have.text", "Active");
      });

    // Verify the styling of the status indicator
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

describe("Users - Invite Users", () => {
  it("should successfully invite a user and verify received invite", () => {
    // Navigate to Users page through Settings
    cy.get('[data-testid="settings"]').click();
    cy.get('[data-testid="users"]').click();

    // Click invite users button
    cy.get('[data-button-for="inviteUsers"]').click();

    // Enter email address for the new user
    cy.get('[class="w-full cursor-text"]').type(helper.generateUniqueEmail());

    // Select role dropdown
    cy.get(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    ).click();

    // Select role option
    cy.get(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    ).click();

    // Select first merchant option
    cy.get('[class="mr-5"]').eq(0).click();

    // Click send invite button
    cy.get('[data-button-for="sendInvite"').click();

    // Navigate to mail server to verify invite email
    cy.visit(Cypress.env("MAIL_URL"));

    // Click on the first email in inbox
    cy.get("div.messages > div:nth-child(1)").click();

    // Wait for email content to load
    cy.wait(1000);

    // Verify invite email content
    cy.get("iframe").then(($iframe) => {
      cy.get('[class="ng-binding"]').should(
        "contain",
        "You have been invited to join Hyperswitch Community",
      );
    });
  });
});
