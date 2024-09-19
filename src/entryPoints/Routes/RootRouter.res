/**
 * @module RootRouter.res
 * 
 * @description Maps all the routes for the application with their respective components that
 * are accessible regardless of user access levels.
 */
module UserEntityRouter = {
  @react.component
  let make = () => {
    let {userInfo: {userEntity}} = React.useContext(UserInfoProvider.defaultContext)

    {
      switch userEntity {
      | #Profile =>
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
        <MerchantAccountContainer />
      | #Merchant
      | #Organization =>
        <MerchantEntityRoutes />
      | #Internal => <InternalEntityRoutes />
      }
    }
  }
}

@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  open GlobalVars
  open LogicUtils

  let {setDashboardPageState, isProdIntentCompleted} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let url = RescriptReactRouter.useUrl()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (userPermissionJson, _) = Recoil.useRecoilState(userPermissionAtom)
  let enumDetails =
    enumVariantAtom
    ->Recoil.useRecoilValueFromAtom
    ->safeParse
    ->QuickStartUtils.getTypedValueFromDict

  let determineStripePlusPayPal = () => {
    enumDetails->checkStripePlusPayPal
      ? RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
      : setDashboardPageState(_ => #STRIPE_PLUS_PAYPAL)

    React.null
  }

  let determineWooCommerce = () => {
    enumDetails->checkWooCommerce
      ? RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
      : setDashboardPageState(_ => #WOOCOMMERCE_FLOW)

    React.null
  }

  let determineQuickStartPageState = () => {
    isProdIntentCompleted->Option.getOr(false) &&
    enumDetails.integrationCompleted &&
    !(enumDetails.testPayment.payment_id->isEmptyString)
      ? RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
      : setDashboardPageState(_ => #QUICK_START)

    React.null
  }

  <ErrorBoundary>
    {switch url.path->urlPath {
    | list{"home", ..._}
    | list{"sdk"} =>
      <MerchantAccountContainer />
    | list{"connectors", ..._}
    | list{"payoutconnectors", ..._}
    | list{"3ds-authenticators", ..._}
    | list{"pm-authentication-processor", ..._}
    | list{"fraud-risk-management", ..._}
    | list{"configure-pmts", ..._}
    | list{"routing", ..._}
    | list{"payoutrouting", ..._} =>
      <ConnectorContainer />
    | list{"business-details", ..._}
    | list{"business-profiles", ..._}
    | list{"payment-settings", ..._} =>
      <BusinessProfileContainer />
    | list{"payments", ..._}
    | list{"refunds", ..._}
    | list{"disputes", ..._}
    | list{"payouts", ..._} =>
      <TransactionContainer />
    | list{"analytics-payments"}
    | list{"performance-monitor"}
    | list{"analytics-refunds"}
    | list{"analytics-disputes"} =>
      <AnalyticsContainser />
    | list{"new-analytics-overview"}
    | list{"new-analytics-payment"} =>
      <AccessControl
        isEnabled={featureFlagDetails.newAnalytics} permission=userPermissionJson.analyticsView>
        <FilterContext key="NewAnalytics" index="NewAnalytics">
          <NewAnalyticsContainer />
        </FilterContext>
      </AccessControl>
    | list{"users", "invite-users"} =>
      <AccessControl permission=userPermissionJson.usersManage>
        <InviteUsers />
      </AccessControl>
    | list{"users", "create-custom-role"} =>
      <AccessControl permission=userPermissionJson.usersManage>
        <CreateCustomRole baseUrl="users" breadCrumbHeader="Users" />
      </AccessControl>
    | list{"users", ...remainingPath} =>
      <AccessControl permission=userPermissionJson.usersView>
        <EntityScaffold
          entityName="UserManagement"
          remainingPath
          renderList={_ => <UserRoleEntry />}
          renderShow={(_, _) => <ShowUserData />}
        />
      </AccessControl>
    | list{"users-v2", ..._} => <UserManagementContainer />
    | list{"compliance"} =>
      <AccessControl isEnabled=featureFlagDetails.complianceCertificate permission=Access>
        <Compliance />
      </AccessControl>
    | list{"3ds"} =>
      <AccessControl permission=userPermissionJson.workflowsView>
        <HSwitchThreeDS />
      </AccessControl>
    | list{"surcharge"} =>
      <AccessControl
        isEnabled={featureFlagDetails.surcharge} permission=userPermissionJson.workflowsView>
        <Surcharge />
      </AccessControl>
    | list{"account-settings"} =>
      <AccessControl
        isEnabled=featureFlagDetails.sampleData permission=userPermissionJson.merchantDetailsManage>
        <HSwitchSettings />
      </AccessControl>
    | list{"account-settings", "profile", ...remainingPath} =>
      <EntityScaffold
        entityName="profile setting"
        remainingPath
        renderList={() => <HSwitchProfileSettings />}
        renderShow={(_, _) => <ModifyTwoFaSettings />}
      />
    | list{"quick-start"} => determineQuickStartPageState()
    | list{"woocommerce"} => determineWooCommerce()
    | list{"stripe-plus-paypal"} => determineStripePlusPayPal()
    | list{"search"} => <SearchResultsPage />
    | list{"payment-attempts"} =>
      <AccessControl
        isEnabled={featureFlagDetails.globalSearch} permission=userPermissionJson.operationsView>
        <PaymentAttemptTable />
      </AccessControl>
    | list{"payment-intents"} =>
      <AccessControl
        isEnabled={featureFlagDetails.globalSearch} permission=userPermissionJson.operationsView>
        <PaymentIntentTable />
      </AccessControl>
    | list{"refunds-global"} =>
      <AccessControl
        isEnabled={featureFlagDetails.globalSearch} permission=userPermissionJson.operationsView>
        <RefundsTable />
      </AccessControl>
    | list{"dispute-global"} =>
      <AccessControl
        isEnabled={featureFlagDetails.globalSearch} permission=userPermissionJson.operationsView>
        <DisputeTable />
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <UserEntityRouter />
    }}
  </ErrorBoundary>
}
