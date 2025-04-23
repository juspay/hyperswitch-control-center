import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import UsersOperations from "../../support/pages/settings/users/UsersOperations";

const homePage = new HomePage();
const usersOperations = new UsersOperations();
let email;
let invitedUserEmail;
let role;

beforeEach(function () {
  email = helper.generateUniqueEmail();
  cy.visit_signupPage();
  cy.sign_up_with_email(email, Cypress.env("CYPRESS_PASSWORD"));
  cy.url().should("include", "/dashboard/home");
  homePage.enterMerchantName.type("Test_merchant");
  homePage.onboardingSubmitButton.click();
  usersOperations.navigate;
});

describe("Users - UI", () => {
  it("Verify the UI of the Users page", () => {
    usersOperations.verifyPageTitle;

    // Verify tabs
    cy.get(
      "div.font-semibold.text-black.dark\\:text-primary.text-blue-600",
    ).contains("Users");
    cy.get("div.text-jp-gray-900.text-opacity-50").contains("Roles");

    // Verify search functionality
    const searchInput = cy.get('[placeholder="Search by name or email.."]');
    searchInput.should("exist");
    searchInput.type(email).should("have.value", email);

    // Verify table
    cy.get("table#table tbody tr").should("have.length", 1);
    cy.get("table#table tbody tr")
      .first()
      .find("td")
      .first()
      .should("contain.text", email);

    // Verify search with non-existent user
    searchInput.clear().type("cypress+org_admin@test.com");
    cy.get("div").contains("No Data Available").should("exist");

    // Verify data filter dropdown
    const verifyDropdown = () => {
      cy.get('[data-dropdown-value="All"]').contains("(Default)");
      cy.get('[data-dropdown-value^="org_"]').contains("(Organization)");
      cy.get('[data-dropdown-value="Test_merchant"]').contains("(Merchant)");
      cy.get('[data-dropdown-value="default"]').contains("(Profile)");
    };

    cy.get('[data-icon="settings-new"]').should("exist").click({ force: true });
    verifyDropdown();

    cy.get("p.text-jp-gray-900").click({ force: true });
    verifyDropdown();

    cy.get('[data-icon="arrow-without-tail"]').click({ force: true });
    verifyDropdown();

    // Verify invite button
    cy.get('[data-button-for="inviteUsers"]')
      .should("exist")
      .should("be.enabled")
      .should("not.be.disabled");
  });
});

describe("Users - Listings", () => {
  it("Verify User's Listing before inviting any user", () => {
    cy.get("table#table thead tr th").should("have.length", 2);
    cy.get("table#table thead tr th").eq(0).should("have.text", "Email");
    cy.get("table#table thead tr th").eq(1).should("have.text", "Role");

    cy.get("table#table tbody tr").should("have.length", 1);
    cy.get("table#table tbody tr td")
      .eq(0)
      .invoke("text")
      .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);
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
    usersOperations.verifyPageTitle;

    cy.get("[data-breadcrumb]").should("exist").should("have.length", 2);
    cy.get("[data-breadcrumb]").eq(0).should("have.text", "Team management");
    cy.get("[data-breadcrumb]").eq(1).should("have.text", email);

    usersOperations.verifyUserDetailsUsernameDisplay(email);
    usersOperations.verifyUserDetailsEmailDisplay(email);

    cy.get("table").should("exist");
    cy.get("table th").should("have.length", 5);

    usersOperations.verifyUserDetailsTableRowContent(
      "All_merchants",
      "all_profiles",
      "Organization Admin",
    );
    usersOperations.verifyActiveStatus;
  });
});

describe("Users - Invite Users", () => {
  const roles = [
    {
      name: "Organization Admin",
      profileType: "all_profiles",
      merchantType: "All_merchants",
    },
    {
      name: "Merchant Admin",
      profileType: "all_profiles",
      merchantType: "Test_merchant",
    },
    {
      name: "Merchant Developer",
      profileType: "all_profiles",
      merchantType: "Test_merchant",
    },
    {
      name: "Merchant Operator",
      profileType: "all_profiles",
      merchantType: "Test_merchant",
    },
    {
      name: "Merchant View Only",
      profileType: "all_profiles",
      merchantType: "Test_merchant",
    },
    {
      name: "Merchant Iam",
      profileType: "all_profiles",
      merchantType: "Test_merchant",
    },
    {
      name: "Customer Support",
      profileType: "all_profiles",
      merchantType: "Test_merchant",
    },
    {
      name: "Profile Admin",
      profileType: "default",
      merchantType: "Test_merchant",
    },
    {
      name: "Profile Developer",
      profileType: "default",
      merchantType: "Test_merchant",
    },
    {
      name: "Profile Operator",
      profileType: "default",
      merchantType: "Test_merchant",
    },
    {
      name: "Profile View Only",
      profileType: "default",
      merchantType: "Test_merchant",
    },
    {
      name: "Profile Iam",
      profileType: "default",
      merchantType: "Test_merchant",
    },
    {
      name: "Customer Support",
      profileType: "default",
      merchantType: "Test_merchant",
      expectedRole: "Profile Customer Support",
    },
  ];

  it("Verify whether invalid users with invalid email address can be invited", () => {
    usersOperations.navigateInviteUsers;
    const invalidEmails = helper.getInvalidEmails();

    invalidEmails.forEach((email) => {
      cy.get('[class="w-full cursor-text"]').type(email);
      cy.get(
        '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
      ).should("not.exist");
      cy.get('[data-button-for="sendInvite"]').should("be.disabled");
      cy.get('[class="w-full cursor-text"]').type("{selectall}{backspace}");
    });
  });

  roles.forEach(({ name, profileType, merchantType, expectedRole }) => {
    it(`Verify inviting a ${name} successfully`, () => {
      // Generate unique email for the invited user
      invitedUserEmail = helper.generateUniqueEmail();
      role = name;

      // Navigate to invite users page and send invite
      usersOperations.navigateInviteUsers;
      cy.inviteUser(invitedUserEmail, role, profileType, merchantType);

      // Visit users page and verify new user appears in table
      usersOperations.visit;
      cy.get("table#table tbody tr").should("have.length", 2);

      // Verify email format in first column
      cy.get("table#table tbody tr:last-child td")
        .eq(0)
        .invoke("text")
        .should("match", /^[^\s@]+@[^\s@]+\.[^\s@]+$/);

      // Verify role in second column matches expected role
      cy.get("table#table tbody tr:last-child td")
        .eq(1)
        .should("have.text", expectedRole || role);

      // Click into user details and verify all fields
      cy.get("table#table tbody tr").last().click();
      cy.verifyUserDetails(
        invitedUserEmail,
        expectedRole || role,
        merchantType,
        profileType,
      );

      // Verify the Manage User button
      usersOperations.verifyManageUserButton;

      // Verify updating user role
      cy.updateUserRole(expectedRole || role);

      // Verify resending the user invite

      // Verify deleting the user invite
      cy.deleteUser();
    });
  });
});
