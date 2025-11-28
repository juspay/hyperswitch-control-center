class HomePage {
  // Onboarding
  get enterMerchantName() {
    return cy.get('[name="merchant_name"]');
  }

  get onboardingSubmitButton() {
    return cy.get('[data-button-for="startExploring"]');
  }

  get subHeaderText() {
    return cy.get(
      '[class="opacity-50 mt-2 text-fs-16 text-nd_gray-400 !opacity-100 font-medium !mt-1"]',
    );
  }

  get orgIcon() {
    return cy.get(
      '[class="w-10 h-10 rounded-lg flex items-center justify-center relative cursor-pointer group/parent"]',
    );
  }

  get merchantDropdown() {
    return cy.get('[class="w-fit flex flex-col gap-4"]');
  }

  get profileDropdown() {
    return cy.get('[class="md:max-w-40 max-w-16"]');
  }

  get profileDropdownList() {
    return cy.get(
      '[class="max-h-72 overflow-scroll px-1 pt-1 selectbox-scrollbar"]',
    );
  }

  get orgChartIcon() {
    return cy.get('[data-icon="github-fork"]');
  }

  get merchantID() {
    return cy.get('[style="overflow-wrap: anywhere;"]');
  }

  get globalSearchInput() {
    return cy.get('[class="w-max"]');
  }

  get productionAccessBanner() {
    return cy.get(
      '[class="absolute w-fit max-w-fixedPageWidth bg-white flex flex-col items-center -top-11"]',
    );
  }

  get integrateConnectorCard() {
    return cy.get(
      '[class="relative bg-white  border p-6 rounded flex flex-col justify-between flex-1 rounded-xl p-6 gap-4"]',
    );
  }

  get demoCheckoutCard() {
    return cy
      .get(
        '[class="relative bg-white  border p-6 rounded flex flex-col justify-between flex-1 rounded-xl p-6 gap-4"]',
      )
      .eq(1);
  }
  //Sidebar

  //Operations
  get operations() {
    return cy.get("[data-testid=operations]");
  }

  get paymentOperations() {
    return cy.get("[data-testid=payments]");
  }

  //Connectors
  get connectors() {
    return cy.get("[data-testid=connectors]");
  }

  get paymentProcessors() {
    return cy.get("[data-testid=paymentprocessors]");
  }

  //Workflow
  get workflow() {
    return cy.get('[data-testid="workflow"]');
  }

  get routing() {
    return cy.get('[data-testid="routing"]');
  }

  //Profile
  get user_account() {
    //return cy.get('[id="headlessui-popover-button-:r0:"]');
    return cy.get('[id="headlessui-popover-button-:rc:"]');
  }

  get user_profile() {
    return cy.get('[id="neglectTopbarTheme"]').first().children().eq(0);
  }

  get sign_out() {
    return cy.contains("Sign out");
  }
}

export default HomePage;
