class UsersList {
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

  get verifyInviteStatus() {
    // Verify the styling of the status indicator
    cy.get("table tr")
      .eq(1)
      .within(() => {
        cy.get("td")
          .eq(3)
          .find("p")
          .should("have.text", "InviteSent") // This should be Invite Sent
          .should("have.class", "text-orange-950")
          .should("have.class", "bg-orange-950")
          .should("have.class", "bg-opacity-20")
          .should("have.class", "rounded-full");
      });
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
}

export default UsersList;
