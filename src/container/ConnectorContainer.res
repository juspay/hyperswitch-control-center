/*
Modules that depend on Connector and Business Profiles data are located within this container.
 */

@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess, hasAllGroupsAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonTokenDetails()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if (
        userHasAccess(~groupAccess=ConnectorsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsManage) === Access
      ) {
        let _ = await fetchConnectorListResponse()
        let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    setUpConnectoreContainer()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    // Connector Modules
    | list{"connectors", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="Connectors"
          remainingPath
          renderList={() => <ConnectorList />}
          renderNewForm={() => <ConnectorHome />}
          renderShow={(_, _) => <ConnectorHome />}
        />
      </AccessControl>
    | list{"payoutconnectors", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.payOut}
        authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="PayoutConnectors"
          remainingPath
          renderList={() => <PayoutProcessorList />}
          renderNewForm={() => <PayoutProcessorHome />}
          renderShow={(_, _) => <PayoutProcessorHome />}
        />
      </AccessControl>
    | list{"3ds-authenticators", ...remainingPath} =>
      <AccessControl
        authorization={userHasAccess(~groupAccess=ConnectorsView)}
        isEnabled={featureFlagDetails.threedsAuthenticator}>
        <EntityScaffold
          entityName="3DS Authenticator"
          remainingPath
          renderList={() => <ThreeDsConnectorList />}
          renderNewForm={() => <ThreeDsProcessorHome />}
          renderShow={(_, _) => <ThreeDsProcessorHome />}
        />
      </AccessControl>

    | list{"pm-authentication-processor", ...remainingPath} =>
      <AccessControl
        authorization={userHasAccess(~groupAccess=ConnectorsView)}
        isEnabled={featureFlagDetails.pmAuthenticationProcessor}>
        <EntityScaffold
          entityName="PM Authentication Processor"
          remainingPath
          renderList={() => <PMAuthenticationConnectorList />}
          renderNewForm={() => <PMAuthenticationHome />}
          renderShow={(_, _) => <PMAuthenticationHome />}
        />
      </AccessControl>
    | list{"tax-processor", ...remainingPath} =>
      <AccessControl
        authorization={userHasAccess(~groupAccess=ConnectorsView)}
        isEnabled={featureFlagDetails.taxProcessor}>
        <EntityScaffold
          entityName="Tax Processor"
          remainingPath
          renderList={() => <TaxProcessorList />}
          renderNewForm={() => <TaxProcessorHome />}
          renderShow={(_, _) => <TaxProcessorHome />}
        />
      </AccessControl>
    | list{"billing-processor", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="Billing Processor"
          remainingPath
          renderList={() => <BillingProcessorList />}
          renderNewForm={() => <BillingProcessorHome />}
          renderShow={(_, _) => <BillingProcessorHome />}
        />
      </AccessControl>
    | list{"vault-processor", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="Vault Processor"
          remainingPath
          renderList={() => <VaultProcessorsList />}
          renderNewForm={() => <VaultProcessorsHome />}
          renderShow={(_, _) => <VaultProcessorsHome />}
        />
      </AccessControl>
    | list{"fraud-risk-management", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.frm}
        authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="risk-management"
          remainingPath
          renderList={() => <FRMSelect />}
          renderNewForm={() => <FRMConfigure />}
          renderShow={(_, _) => <FRMConfigure />}
        />
      </AccessControl>
    | list{"configure-pmts", ...remainingPath} =>
      <AccessControl
        authorization={userHasAccess(~groupAccess=ConnectorsView)}
        isEnabled={featureFlagDetails.configurePmts}>
        <FilterContext key="ConfigurePmts" index="ConfigurePmts">
          <EntityScaffold
            entityName="ConfigurePMTs"
            remainingPath
            renderList={() => <PaymentMethodList />}
            renderShow={(_, _) => <PaymentSettings webhookOnly=false showFormOnly=false />}
          />
        </FilterContext>
      </AccessControl>
    | list{"payment-link-theme"} =>
      <AccessControl
        isEnabled={featureFlagDetails.paymentLinkThemeConfigurator}
        authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <SDKProvider>
          <PaymentLinkThemeConfigurator />
        </SDKProvider>
      </AccessControl>
    // Routing
    | list{"routing", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=WorkflowsView)}>
        <EntityScaffold
          entityName="Routing"
          remainingPath
          renderList={() => <RoutingStack remainingPath />}
          renderShow={(routingType, _) => <RoutingConfigure routingType />}
        />
      </AccessControl>
    | list{"payoutrouting", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.payOut}
        authorization={userHasAccess(~groupAccess=WorkflowsView)}>
        <EntityScaffold
          entityName="PayoutRouting"
          remainingPath
          renderList={() => <PayoutRoutingStack remainingPath />}
          renderShow={(routingType, _) => <PayoutRoutingConfigure routingType />}
        />
      </AccessControl>
    | list{"payment-settings", ...remainingPath} =>
      <EntityScaffold
        entityName="PaymentSettings"
        remainingPath
        renderList={() => <PaymentSettings webhookOnly=false showFormOnly=false />}
      />
    | list{"payment-settings-new", ...remainingPath} =>
      <AccessControl isEnabled={featureFlagDetails.paymentSettingsV2} authorization=Access>
        <EntityScaffold
          entityName="PaymentSettingsV2" remainingPath renderList={() => <PaymentSettingsV2 />}
        />
      </AccessControl>

    | list{"webhooks", ...remainingPath} =>
      <AccessControl isEnabled={featureFlagDetails.devWebhooks} authorization=Access>
        <FilterContext key="webhooks" index="webhooks">
          <EntityScaffold
            entityName="Webhooks"
            remainingPath
            access=Access
            renderList={() => <Webhooks />}
            renderShow={(id, _) => <WebhooksDetails id />}
          />
        </FilterContext>
      </AccessControl>
    | list{"sdk"} =>
      <AccessControl
        isEnabled={!featureFlagDetails.isLiveMode}
        authorization={hasAllGroupsAccess([
          userHasAccess(~groupAccess=OperationsManage),
          userHasAccess(~groupAccess=ConnectorsManage),
        ])}>
        <SDKProvider>
          <SDKPage />
        </SDKProvider>
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </PageLoaderWrapper>
}
