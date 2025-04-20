import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import UsersList from "../../support/pages/settings/users/UsersList";

const homePage = new HomePage();
const usersList = new UsersList();
let email;
let invitedUserEmail;
let role;

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
  usersList.navigate;
});

describe("Users - UI", () => {
  it("Verify the UI of the Users page", () => {
    // Verify the page title
    usersList.verifyPageTitle;

    // Verify the UI of 'Users' tab
    cy.get(
      "div.font-semibold.text-black.dark\\:text-primary.text-blue-600",
    ).contains("Users");

    // Verify the UI of 'Roles' tab
    cy.get("div.text-jp-gray-900.text-opacity-50").contains("Roles");

    // Verify the UI of search input
    cy.get('[placeholder="Search by name or email.."]').should("exist");

    // Verify the functionality of the search input
    cy.get('[placeholder="Search by name or email.."]').type(email);
    cy.get('[placeholder="Search by name or email.."]').should(
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
    cy.get('[placeholder="Search by name or email.."]').clear();
    cy.get('[placeholder="Search by name or email.."]').type(
      "cypress+org_admin@test.com",
    );
    cy.get('[placeholder="Search by name or email.."]').should(
      "have.value",
      "cypress+org_admin@test.com",
    );
    cy.get("div").contains("No Data Available").should("exist");

    // Verify the UI of Data Filter Dropdown
    cy.get('[data-icon="settings-new"]').should("exist");
    cy.get("p.text-jp-gray-900").contains("View data for:");
    cy.get('[data-icon="arrow-without-tail"]').should("exist");

    // Verify the UI Functionality of the Data Filter Dropdown by clicking on gear icon
    cy.get('[data-icon="settings-new"]').click({ force: true });
    cy.get('[data-dropdown-value="All"]').contains("(Default)");
    cy.get('[data-dropdown-value^="org_"]').contains("(Organization)");
    cy.get('[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
    cy.get('[data-dropdown-value="default"]').contains("(Profile)");

    //Verify the UI Functionality of the Data Filter Dropdown by clicking on "View data for:
    cy.get("p.text-jp-gray-900").click({ force: true });
    cy.get('[data-dropdown-value="All"]').contains("(Default)");
    cy.get('[data-dropdown-value^="org_"]').contains("(Organization)");
    cy.get('[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
    cy.get('[data-dropdown-value="default"]').contains("(Profile)");

    // Verify the UI Functionality of the Data Filter Dropdown by clicking on arrow without tail icon
    cy.get('[data-icon="arrow-without-tail"]').click({ force: true });
    cy.get('[data-dropdown-value="All"]').contains("(Default)");
    cy.get('[data-dropdown-value^="org_"]').contains("(Organization)");
    cy.get('[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
    cy.get('[data-dropdown-value="default"]').contains("(Profile)");

    // Verify the page has a clickable "Invite users" button
    cy.get('[data-button-for="inviteUsers"]')
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
    usersList.verifyPageTitle;

    // Verify the breadcrumb has the user's email
    cy.get("[data-breadcrumb]").should("exist");
    cy.get("[data-breadcrumb]").should("have.length", 2);
    cy.get("[data-breadcrumb]").eq(0).should("have.text", "Team management");
    cy.get("[data-breadcrumb]").eq(1).should("have.text", email);

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
    cy.get("table th").should("have.length", 5);

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
  it("Verify whether invalid users with invalid email address can be invited", () => {
    // Navigate to Invite Users page
    usersList.navigateInviteUsers;

    // Get invalid emails
    const invalidEmails = helper.getInvalidEmails();

    // Enter invalid emails
    invalidEmails.forEach((email) => {
      cy.get('[class="w-full cursor-text"]').type(email);
      // Check if role dropdown exists
      cy.get(
        '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
      ).should("not.exist");
      // Verify Send Invite button is disabled
      cy.get('[data-button-for="sendInvite"]').should("be.disabled");
      // Clear the email input field by pressing Ctrl+A and Delete
      cy.get('[class="w-full cursor-text"]').type("{selectall}{backspace}");
    });
  });

  it("Verify inviting an Organization Admin successfully", () => {
    role = "Organization Admin";

    // Navigate to Invite Users page
    usersList.navigateInviteUsers;

    // Generate a unique email for the test
    invitedUserEmail = helper.generateUniqueEmail();

    // Enter email address for the new user
    cy.get('[class="w-full cursor-text"]').type(invitedUserEmail);

    // Select role dropdown
    cy.get(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    ).click();

    // Select Merchants that are supposed to be accessed by the new user
    cy.get('[data-value="testMerchant"]').click();
    cy.get('[data-dropdown-value="All merchants"]').click();

    // Select role option
    cy.get(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    ).click();

    // Select option Organization Admin
    cy.get('[class="mr-5"]').contains(role).click();

    // Click send invite button
    usersList.sendInvite;

    // Verify invite email was received and contains correct content
    usersList.verifyInviteEmail;

    // Navigate back to Users page
    usersList.visit;

    // Verify the new user is listed in the Users page
    cy.get("table#table tbody tr").should("have.length", 2);

    // Verify the first cell of the last row contains an email
    cy.get("table#table tbody tr:last-child td")
      .eq(0)
      .invoke("text")
      .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);

    // Verify the second cell of the last row contains Organization Admin
    cy.get("table#table tbody tr:last-child td")
      .eq(1)
      .should("have.text", role);

    // Verify User Details
    cy.get("table#table tbody tr").last().click();

    // Verify the user's username is displayed
    const username =
      invitedUserEmail.split("@")[0].charAt(0).toUpperCase() +
      invitedUserEmail.split("@")[0].slice(1);
    cy.get("p.text-2xl.font-semibold.leading-8")
      .should("exist")
      .and("have.text", username);

    // Verify the user's email is displayed
    cy.get("p")
      .contains(invitedUserEmail)
      .should("exist")
      .and("have.class", "text-grey-600")
      .and("have.class", "opacity-40");

    // Verify the content of table rows
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td").eq(0).should("have.text", "All_merchants"); // This should be All Merchants
        cy.get("td").eq(1).should("have.text", "all_profiles"); // This should be All Profiles
        cy.get("td").eq(2).should("have.text", role);
        cy.get("td").eq(3).should("have.text", "InviteSent"); // This should be Invite Sent
      });

    // Verify the styling of the status indicator
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(3)
          .find("p")
          .should("have.class", "text-orange-950")
          .should("have.class", "bg-orange-950")
          .should("have.class", "bg-opacity-20")
          .should("have.class", "rounded-full");
      });

    // Verify there is a button to Manage the Invited User
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(4)
          .find('[data-button-for="manageUser"]')
          .should("exist")
          .and("have.text", "Manage user");
      });
  });

  it("Verify inviting an Merchant Admin successfully", () => {
    role = "Merchant Admin";

    // Navigate to Invite Users page
    usersList.navigateInviteUsers;

    // Generate a unique email for the test
    invitedUserEmail = helper.generateUniqueEmail();

    // Enter email address for the new user
    cy.get('[class="w-full cursor-text"]').type(invitedUserEmail);

    // Select role dropdown
    cy.get(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    ).click();

    // Select role option
    cy.get(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    ).click();

    // Select option Merchant Admin
    cy.get('[class="mr-5"]').contains(role).click();

    // Click send invite button
    usersList.sendInvite;

    // Verify invite email was received and contains correct content
    usersList.verifyInviteEmail;

    // Navigate back to Users page
    usersList.visit;

    // Verify the new user is listed in the Users page
    cy.get("table#table tbody tr").should("have.length", 2);

    // Verify the first cell of the last row contains an email
    cy.get("table#table tbody tr:last-child td")
      .eq(0)
      .invoke("text")
      .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);

    // Verify the second cell of the last row contains Merchant Admin
    cy.get("table#table tbody tr:last-child td")
      .eq(1)
      .should("have.text", role);

    // Verify User Details
    cy.get("table#table tbody tr").last().click();

    // Verify the user's username is displayed
    const username =
      invitedUserEmail.split("@")[0].charAt(0).toUpperCase() +
      invitedUserEmail.split("@")[0].slice(1);
    cy.get("p.text-2xl.font-semibold.leading-8")
      .should("exist")
      .and("have.text", username);

    // Verify the user's email is displayed
    cy.get("p")
      .contains(invitedUserEmail)
      .should("exist")
      .and("have.class", "text-grey-600")
      .and("have.class", "opacity-40");

    // Verify the content of table rows
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td").eq(0).should("have.text", "Test_merchant"); // This should be All Merchants
        cy.get("td").eq(1).should("have.text", "all_profiles"); // This should be All Profiles
        cy.get("td").eq(2).should("have.text", role);
        cy.get("td").eq(3).should("have.text", "InviteSent"); // This should be Invite Sent
      });

    // Verify the styling of the status indicator
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(3)
          .find("p")
          .should("have.class", "text-orange-950")
          .should("have.class", "bg-orange-950")
          .should("have.class", "bg-opacity-20")
          .should("have.class", "rounded-full");
      });

    // Verify there is a button to Manage the Invited User
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(4)
          .find('[data-button-for="manageUser"]')
          .should("exist")
          .and("have.text", "Manage user");
      });
  });

  it("Verify inviting an Merchant Developer successfully", () => {
    role = "Merchant Developer";

    // Navigate to Invite Users page
    usersList.navigateInviteUsers;

    // Generate a unique email for the test
    invitedUserEmail = helper.generateUniqueEmail();

    // Enter email address for the new user
    cy.get('[class="w-full cursor-text"]').type(invitedUserEmail);

    // Select role dropdown
    cy.get(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    ).click();

    // Select role option
    cy.get(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    ).click();

    // Select option Merchant Developer
    cy.get('[class="mr-5"]').contains(role).click();

    // Click send invite button
    usersList.sendInvite;

    // Verify invite email was received and contains correct content
    usersList.verifyInviteEmail;

    // Navigate back to Users page
    usersList.visit;

    // Verify the new user is listed in the Users page
    cy.get("table#table tbody tr").should("have.length", 2);

    // Verify the first cell of the last row contains an email
    cy.get("table#table tbody tr:last-child td")
      .eq(0)
      .invoke("text")
      .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);

    // Verify the second cell of the last row contains Merchant Developer
    cy.get("table#table tbody tr:last-child td")
      .eq(1)
      .should("have.text", role);

    // Verify User Details
    cy.get("table#table tbody tr").last().click();

    // Verify the user's username is displayed
    const username =
      invitedUserEmail.split("@")[0].charAt(0).toUpperCase() +
      invitedUserEmail.split("@")[0].slice(1);
    cy.get("p.text-2xl.font-semibold.leading-8")
      .should("exist")
      .and("have.text", username);

    // Verify the user's email is displayed
    cy.get("p")
      .contains(invitedUserEmail)
      .should("exist")
      .and("have.class", "text-grey-600")
      .and("have.class", "opacity-40");

    // Verify the content of table rows
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td").eq(0).should("have.text", "Test_merchant"); // This should be All Merchants
        cy.get("td").eq(1).should("have.text", "all_profiles"); // This should be All Profiles
        cy.get("td").eq(2).should("have.text", role);
        cy.get("td").eq(3).should("have.text", "InviteSent"); // This should be Invite Sent
      });

    // Verify the styling of the status indicator
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(3)
          .find("p")
          .should("have.class", "text-orange-950")
          .should("have.class", "bg-orange-950")
          .should("have.class", "bg-opacity-20")
          .should("have.class", "rounded-full");
      });

    // Verify there is a button to Manage the Invited User
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(4)
          .find('[data-button-for="manageUser"]')
          .should("exist")
          .and("have.text", "Manage user");
      });
  });
});
