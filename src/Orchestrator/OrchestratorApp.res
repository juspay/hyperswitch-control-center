@react.component
let make = (~setScreenState) => {
  open HSwitchUtils
  open HyperswitchAtom
  open GlobalVars

  let url = RescriptReactRouter.useUrl()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {
    useIsFeatureEnabledForMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)

  switch url.path->urlPath {
  | list{"home", ..._}
  | list{"recon"}
  | list{"upload-files"}
  | list{"run-recon"}
  | list{"recon-analytics"}
  | list{"reports"}
  | list{"config-settings"}
  | list{"sdk"} =>
    <MerchantAccountContainer setAppScreenState=setScreenState />

  | list{"connectors", ..._}
  | list{"payoutconnectors", ..._}
  | list{"3ds-authenticators", ..._}
  | list{"pm-authentication-processor", ..._}
  | list{"tax-processor", ..._}
  | list{"fraud-risk-management", ..._}
  | list{"configure-pmts", ..._}
  | list{"routing", ..._}
  | list{"payoutrouting", ..._}
  | list{"payment-settings", ..._} =>
    <ConnectorContainer />

  | list{"apm"} => <APMContainer />

  | list{"business-details", ..._}
  | list{"business-profiles", ..._} =>
    <BusinessProfileContainer />

  | list{"payments", ..._}
  | list{"refunds", ..._}
  | list{"disputes", ..._}
  | list{"payouts", ..._} =>
    <TransactionContainer />

  | list{"analytics-payments"}
  | list{"performance-monitor"}
  | list{"analytics-refunds"}
  | list{"analytics-disputes"}
  | list{"analytics-authentication"} =>
    <AnalyticsContainer />

  | list{"new-analytics-payment"}
  | list{"new-analytics-refund"}
  | list{"new-analytics-smart-retry"} =>
    <AccessControl
      isEnabled={featureFlagDetails.newAnalytics &&
      useIsFeatureEnabledForMerchant(merchantSpecificConfig.newAnalytics)}
      authorization={userHasAccess(~groupAccess=AnalyticsView)}>
      <FilterContext key="NewAnalytics" index="NewAnalytics">
        <NewAnalyticsContainer />
      </FilterContext>
    </AccessControl>

  | list{"customers", ...remainingPath} =>
    <AccessControl
      authorization={userHasAccess(~groupAccess=OperationsView)}
      isEnabled={[#Tenant, #Organization, #Merchant]->checkUserEntity}>
      <EntityScaffold
        entityName="Customers"
        remainingPath
        access=Access
        renderList={() => <Customers />}
        renderShow={(id, _) => <ShowCustomers id />}
      />
    </AccessControl>

  // TODO : Move to hyperswitchApp
  | list{"users", ..._} => <UserManagementContainer />

  | list{"developer-api-keys"} =>
    <AccessControl
      // TODO: Remove `MerchantDetailsManage` permission in future
      authorization={hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsView),
        userHasAccess(~groupAccess=AccountManage),
      )}
      isEnabled={!checkUserEntity([#Profile])}>
      <KeyManagement.KeysManagement />
    </AccessControl>

  | list{"compliance"} =>
    <AccessControl isEnabled=featureFlagDetails.complianceCertificate authorization=Access>
      <Compliance />
    </AccessControl>

  | list{"3ds"} =>
    <AccessControl authorization={userHasAccess(~groupAccess=WorkflowsView)}>
      <HSwitchThreeDS />
    </AccessControl>

  | list{"surcharge"} =>
    <AccessControl
      isEnabled={featureFlagDetails.surcharge}
      authorization={userHasAccess(~groupAccess=WorkflowsView)}>
      <Surcharge />
    </AccessControl>

  | list{"account-settings"} =>
    <AccessControl
      isEnabled=featureFlagDetails.sampleData
      // TODO: Remove `MerchantDetailsManage` permission in future
      authorization={hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsManage),
        userHasAccess(~groupAccess=AccountManage),
      )}>
      <HSwitchSettings />
    </AccessControl>

  | list{"account-settings", "profile", ...remainingPath} =>
    <EntityScaffold
      entityName="profile setting"
      remainingPath
      renderList={() => <HSwitchProfileSettings />}
      renderShow={(_, _) => <ModifyTwoFaSettings />}
    />

  | list{"search"} => <SearchResultsPage />

  | list{"payment-attempts"} =>
    <AccessControl
      isEnabled={featureFlagDetails.globalSearch}
      authorization={userHasAccess(~groupAccess=OperationsView)}>
      <PaymentAttemptTable />
    </AccessControl>

  | list{"payment-intents"} =>
    <AccessControl
      isEnabled={featureFlagDetails.globalSearch}
      authorization={userHasAccess(~groupAccess=OperationsView)}>
      <PaymentIntentTable />
    </AccessControl>

  | list{"refunds-global"} =>
    <AccessControl
      isEnabled={featureFlagDetails.globalSearch}
      authorization={userHasAccess(~groupAccess=OperationsView)}>
      <RefundsTable />
    </AccessControl>

  | list{"dispute-global"} =>
    <AccessControl
      isEnabled={featureFlagDetails.globalSearch}
      authorization={userHasAccess(~groupAccess=OperationsView)}>
      <DisputeTable />
    </AccessControl>

  | _ =>
    if activeProduct === Orchestration {
      RescriptReactRouter.replace(appendDashboardPath(~url="/home"))
      <MerchantAccountContainer setAppScreenState=setScreenState />
    } else {
      React.null
    }
  }
}
