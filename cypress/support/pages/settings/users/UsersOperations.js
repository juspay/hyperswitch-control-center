class UsersOperations {
  get visit() {
    // Visit the users page directly
    return cy.visit("/dashboard/users");
  }

  get urlCheck() {
    // Verify that the URL includes "/dashboard/users"
    return cy.url().should("include", "/dashboard/users");
  }

  get navigate() {
    // Navigate to the Users section in Settings
    this.navigateToUsers();
  }

  get navigateInviteUsers() {
    // Navigate to the Users section in Settings and click Invite Users button
    this.navigateToUsers();
    cy.get('[data-button-for="inviteUsers"]').click();
  }

  navigateToUsers() {
    // Helper method to navigate to Users section in Settings
    cy.get('[data-testid="settings"]').click();
    cy.get('[data-testid="users"]').click();
  }

  get verifyPageTitle() {
    // Verify the page title displays "Team management"
    cy.get("div.text-fs-28.font-semibold.leading-10").should(
      "have.text",
      "Team management",
    );
  }

  get sendInvite() {
    // Click on the Send Invite button
    cy.get('[data-button-for="sendInvite"').click();
  }

  get verifyInviteEmail() {
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
  }

  verifyUserDetailsUsernameDisplay(email) {
    const username =
      email.split("@")[0].charAt(0).toUpperCase() +
      email.split("@")[0].slice(1);
    cy.get("p.text-2xl.font-semibold.leading-8")
      .should("exist")
      .and("have.text", username);
  }

  verifyUserDetailsEmailDisplay(email) {
    // Verify the email is displayed in the user details table
    cy.get("p")
      .contains(email)
      .should("exist")
      .and("have.class", "text-grey-600")
      .and("have.class", "opacity-40");
  }

  verifyUserDetailsTableRowContent(merchants, profiles, role) {
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td").eq(0).should("have.text", merchants);
        cy.get("td").eq(1).should("have.text", profiles);
        cy.get("td").eq(2).should("have.text", role);
      });
  }

  verifyStatus(status, textColor, bgColor) {
    // Verify the styling of the status indicator
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(3)
          .find("p")
          .should("have.text", status)
          .should("have.class", `text-${textColor}`)
          .should("have.class", `bg-${bgColor}`)
          .should("have.class", "bg-opacity-20")
          .should("have.class", "rounded-full");
      });
  }

  get verifyActiveStatus() {
    this.verifyStatus("Active", "green-700", "green-700");
  }

  get verifyInviteStatus() {
    this.verifyStatus("InviteSent", "orange-950", "orange-950"); // This should be Invite Sent
  }

  get verifyManageUserButton() {
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
  }

  get verifyManageUserButton() {
    cy.get('[data-button-for="manageUser"]').click();
    cy.get('[data-button-for="update"]').should("exist");
    cy.get('[data-button-for="resend"]').click();
    cy.get('[data-button-for="delete"]').should("exist");
  }

  inviteUser(
    userEmail,
    userRole,
    profileType = "all_profiles",
    merchantType = "All_merchants",
  ) {
    cy.get('[class="w-full cursor-text"]').type(userEmail);

    // Wait for the email input to be populated and verify it exists
    if (userRole === "Organization Admin") {
      cy.get('[data-value="testMerchant"]').click();
      cy.get('[data-dropdown-value="All merchants"]').click();
    }

    // Select merchant/profile if needed
    if (profileType === "default") {
      cy.get('[data-value="allProfiles"]').click();
      cy.get('[data-dropdown-value="default"]').click();
    }

    // Select role
    cy.get(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    ).click();
    cy.get(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    ).click();
    cy.get('[class="mr-5"]').contains(userRole).click();

    cy.get('[data-button-for="sendInvite"]').click();
    cy.get('[data-button-for="sendInvite"]').should("not.exist");
  }

  verifyUserDetails(
    userEmail,
    expectedRole,
    merchantType = "Test_merchant",
    profileType = "all_profiles",
  ) {
    cy.get("[data-breadcrumb]").eq(1).should("have.text", userEmail);
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td").eq(0).should("have.text", merchantType);
        cy.get("td").eq(1).should("have.text", profileType);
        cy.get("td").eq(2).should("have.text", expectedRole);
        cy.get("td").eq(3).find("p").should("have.class", "text-orange-950");
      });
    cy.get('[data-button-for="manageUser"]').should("exist");
  }

  updateUserRole(currentRole) {
    cy.get(
      `[data-value="${currentRole.toLowerCase().replace(/\s+(.)/g, (match, group) => group.toUpperCase())}"]`,
    ).click();
    cy.get("[data-dropdown-value]")
      .filter((i, el) => {
        const $el = Cypress.$(el);
        return (
          !/[A-Z]/.test($el.text()) &&
          $el.attr("data-dropdown-value-selected") !== "true"
        );
      })
      .first()
      .invoke("text")
      .then((newRole) => {
        cy.get(`[data-dropdown-value="${newRole}"]`).click();
        cy.get('[data-button-for="update"]').click();

        // Click into user details and verify updated role
        cy.get("table#table tbody tr").last().click();
        cy.get("td")
          .eq(2)
          .should(
            "have.text",
            newRole
              .split("_")
              .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
              .join(" "),
          );
      });
  }

  get deleteUser() {
    cy.get('[data-button-for="manageUser"]').click();
    cy.get('[data-button-for="delete"]').click();
    cy.get('[data-button-for="confirm"]').click();
  }
}

export default UsersOperations;
