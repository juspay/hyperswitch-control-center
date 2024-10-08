/*
Modules that depend on Connector and Business Profiles data are located within this container.
 */
@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if (
        userHasAccess(~groupACL=ConnectorsView) === Access ||
        userHasAccess(~groupACL=WorkflowsView) === Access ||
        userHasAccess(~groupACL=WorkflowsManage) === Access
      ) {
        let _ = await fetchConnectorListResponse()
        let _ = await fetchBusinessProfiles()
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
      <AccessControl permission={userHasAccess(~groupACL=ConnectorsView)}>
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
        isEnabled={featureFlagDetails.payOut} permission={userHasAccess(~groupACL=ConnectorsView)}>
        <EntityScaffold
          entityName="PayoutConnectors"
          remainingPath
          renderList={() => <ConnectorList isPayoutFlow=true />}
          renderNewForm={() => <ConnectorHome isPayoutFlow=true />}
          renderShow={(_, _) => <ConnectorHome isPayoutFlow=true />}
        />
      </AccessControl>
    | list{"3ds-authenticators", ...remainingPath} =>
      <AccessControl
        permission={userHasAccess(~groupACL=ConnectorsView)}
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
        permission={userHasAccess(~groupACL=ConnectorsView)}
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
        permission={userHasAccess(~groupACL=ConnectorsView)}
        isEnabled={featureFlagDetails.taxProcessor}>
        <EntityScaffold
          entityName="Tax Processor"
          remainingPath
          renderList={() => <TaxProcessorList />}
          renderNewForm={() => <TaxProcessorHome />}
          renderShow={(_, _) => <TaxProcessorHome />}
        />
      </AccessControl>
    | list{"fraud-risk-management", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.frm} permission={userHasAccess(~groupACL=ConnectorsView)}>
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
        permission={userHasAccess(~groupACL=ConnectorsView)}
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
    // Routing
    | list{"routing", ...remainingPath} =>
      <AccessControl permission={userHasAccess(~groupACL=WorkflowsView)}>
        <EntityScaffold
          entityName="Routing"
          remainingPath
          renderList={() => <RoutingStack remainingPath />}
          renderShow={(routingType, _) => <RoutingConfigure routingType />}
        />
      </AccessControl>
    | list{"payoutrouting", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.payOut} permission={userHasAccess(~groupACL=WorkflowsView)}>
        <EntityScaffold
          entityName="PayoutRouting"
          remainingPath
          renderList={() => <PayoutRoutingStack remainingPath />}
          renderShow={(routingType, _) => <PayoutRoutingConfigure routingType />}
        />
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </PageLoaderWrapper>
}
