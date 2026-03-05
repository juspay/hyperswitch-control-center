@react.component
let make = (~setScreenState) => {
  open HyperswitchAtom

  let url = RescriptReactRouter.useUrl()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {
    isFeatureEnabledForDenyListMerchant,
    merchantSpecificConfig,
  } = MerchantSpecificConfigHook.useMerchantSpecificConfig()
  let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
  let (isCurrentMerchantPlatform, _) = OMPSwitchHooks.useOMPType()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"home", ..._}
    | list{"recon"}
    | list{"upload-files"}
    | list{"run-recon"}
    | list{"recon-analytics"}
    | list{"reports"}
    | list{"config-settings"} =>
      <MerchantAccountContainer setAppScreenState=setScreenState />
    // Commented as not needed now
    // list{"file-processor"}

    | list{"connectors", ..._}
    | list{"payoutconnectors", ..._}
    | list{"3ds-authenticators", ..._}
    | list{"pm-authentication-processor", ..._}
    | list{"tax-processor", ..._}
    | list{"billing-processor", ..._}
    | list{"vault-processor", ..._}
    | list{"fraud-risk-management", ..._}
    | list{"configure-pmts", ..._}
    | list{"payment-link-theme", ..._}
    | list{"routing", ..._}
    | list{"payoutrouting", ..._}
    | list{"payment-settings", ..._}
    | list{"webhooks", ..._}
    | list{"sdk"}
    | list{"vault-onboarding", ..._}
    | list{"vault-customers-tokens", ..._} =>
      <AccessControl authorization={isCurrentMerchantPlatform ? NoAccess : Access}>
        <ConnectorContainer />
      </AccessControl>
    | list{"apm"} => <APMContainer />
    | list{"payments", ..._}
    | list{"refunds", ..._}
    | list{"disputes", ..._}
    | list{"payouts", ..._} =>
      <AccessControl authorization={isCurrentMerchantPlatform ? NoAccess : Access}>
        <TransactionContainer />
      </AccessControl>
    | list{"analytics-payments"}
    | list{"performance-monitor"}
    | list{"analytics-refunds"}
    | list{"analytics-disputes"}
    | list{"analytics-authentication"}
    | list{"analytics-routing", ..._} =>
      <AccessControl authorization={isCurrentMerchantPlatform ? NoAccess : Access}>
        <AnalyticsContainer />
      </AccessControl>

    | list{"new-analytics"}
    | list{"new-analytics", "payment"}
    | list{"new-analytics", "refund"}
    | list{"new-analytics", "smart-retry"} =>
      <AccessControl
        isEnabled={featureFlagDetails.newAnalytics &&
        isFeatureEnabledForDenyListMerchant(merchantSpecificConfig.newAnalytics)}
        authorization={userHasAccess(~groupAccess=AnalyticsView)}>
        <FilterContext key="NewAnalytics" index="NewAnalytics">
          <InsightsAnalyticsContainer />
        </FilterContext>
      </AccessControl>
    | list{"customers", ...remainingPath} =>
      <AccessControl
        authorization={userHasAccess(~groupAccess=OperationsView)}
        isEnabled={[#Tenant, #Organization, #Merchant]->checkUserEntity}>
        <FilterContext key="Customers" index="Customers">
          <EntityScaffold
            entityName="Customers"
            remainingPath
            access=Access
            renderList={() => featureFlagDetails.devCustomer ? <CustomerV2 /> : <Customers />}
            renderShow={(id, _) => <ShowCustomers id />}
          />
        </FilterContext>
      </AccessControl>
    | list{"users", ..._} =>
      <AccessControl authorization={userHasAccess(~groupAccess=UsersView)}>
        <UserManagementContainer />
      </AccessControl>
    | list{"developer-api-keys"} =>
      <AccessControl
        // TODO: Remove `MerchantDetailsView` permission in future
        authorization={hasAnyGroupAccess(
          userHasAccess(~groupAccess=MerchantDetailsView),
          userHasAccess(~groupAccess=AccountView),
        )}
        isEnabled={!checkUserEntity([#Profile])}>
        <KeyManagement />
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
    | list{"3ds-exemption"} =>
      <AccessControl
        isEnabled={featureFlagDetails.threedsExemptionRules}
        authorization={userHasAccess(~groupAccess=WorkflowsView)}>
        <HSwitchThreeDsExemption />
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
    | list{"organization-settings"} =>
      <AccessControl
        authorization={userHasAccess(~groupAccess=AccountManage)}
        isEnabled={checkUserEntity([#Organization])}>
        <OrganizationSettings />
      </AccessControl>
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
    | list{"payouts-global"} =>
      <AccessControl
        isEnabled={featureFlagDetails.globalSearch}
        authorization={userHasAccess(~groupAccess=OperationsView)}>
        <PayoutTable key={url.search} />
      </AccessControl>
    | list{"payout-attempts"} =>
      <AccessControl
        isEnabled={featureFlagDetails.globalSearch}
        authorization={userHasAccess(~groupAccess=OperationsView)}>
        <PayoutAttemptTable key={url.search} />
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
    | list{"unauthorized"} => <UnauthorizedPage />
    | list{"chat-bot"} =>
      <AccessControl
        isEnabled={featureFlagDetails.devAiChatBot && !checkUserEntity([#Profile])}
        // TODO: Remove `MerchantDetailsView` permission in future
        authorization={hasAnyGroupAccess(
          userHasAccess(~groupAccess=MerchantDetailsView),
          userHasAccess(~groupAccess=AccountView),
        )}>
        <ChatBot />
      </AccessControl>
    | _ => <EmptyPage path="/home" />
    }
  }
}
