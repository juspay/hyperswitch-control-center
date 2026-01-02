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

  //V2 Home
  get homeV2() {
    return cy.get('[class="flex flex-col gap-2 mb-2"]');
  }

  //Operations
  get operations() {
    return cy.get("[data-testid=operations]");
  }

  get paymentOperations() {
    return cy.get("[data-testid=payments]");
  }

  get refundOperations() {
    return cy.get('[data-testid="refunds"]');
  }

  get disputesOperations() {
    return cy.get('[data-testid="disputes"]');
  }

  get payoutsOperations() {
    return cy.get('[data-testid="payouts"]');
  }

  get customers() {
    return cy.get('[data-testid="customers"]');
  }

  //Connectors
  get connectors() {
    return cy.get("[data-testid=connectors]");
  }

  get paymentProcessors() {
    return cy.get("[data-testid=paymentprocessors]");
  }

  get payoutConnectors() {
    return cy.get('[data-testid="payoutprocessors"]');
  }

  get threeDSConnectors() {
    return cy.get('[data-testid="3dsauthenticators"]');
  }

  get frmConnectors() {
    return cy.get('[data-testid="fraud&risk"]');
  }

  get pmAuthConnectors() {
    return cy.get('[data-testid="pmauthprocessor"]');
  }

  get taxConnectors() {
    return cy.get('[data-testid="taxprocessor"]');
  }

  get vaultConnectors() {
    return cy.get('[data-testid="vaultprocessor"]');
  }

  //Analytics
  get analytics() {
    return cy.get('[data-testid="analytics"]');
  }

  get paymentsAnalytics() {
    return cy.get('[data-testid="payments"]');
  }

  get refundAnalytics() {
    return cy.get('[data-testid="refunds"]');
  }

  //Workflow
  get workflow() {
    return cy.get('[data-testid="workflow"]');
  }

  get routing() {
    return cy.get('[data-testid="routing"]');
  }

  get surchargeRouting() {
    return cy.get('[data-testid="surcharge"]');
  }

  get threeDSRouting() {
    return cy.get('[data-testid="3dsdecisionmanager"]');
  }

  get payoutRouting() {
    return cy.get('[data-testid="payoutrouting"]');
  }

  // Developer
  get developer() {
    return cy.get('[data-testid="developers"]');
  }

  get paymentSettings() {
    return cy.get('[data-testid="paymentsettings"]');
  }

  get apiKeys() {
    return cy.get('[data-testid="apikeys"]');
  }

  get webhooks() {
    return cy.get('[data-testid="webhooks"]');
  }
  // Settings

  get settings() {
    return cy.get('[data-testid="settings"]');
  }

  get configurePMT() {
    return cy.get('[data-testid="configurepmts"]');
  }

  get users() {
    return cy.get('[data-testid="users"]');
  }

  //Profile
  get user_account() {
    return cy.get('[data-icon="nd-dropdown-menu"]');
  }

  get user_profile() {
    return cy.get('[id="neglectTopbarTheme"]').first().children().eq(0);
  }

  get sign_out() {
    return cy.contains("Sign out");
  }
}

export default HomePage;
