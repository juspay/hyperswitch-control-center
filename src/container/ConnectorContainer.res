@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let (surveyModal, setSurveyModal) = React.useState(_ => false)
  let (userPermissionJson, _) = Recoil.useRecoilState(userPermissionAtom)
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()
  let fetchMerchantAccountDetails = MerchantDetailsHook.useFetchMerchantDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if (
        userPermissionJson.connectorsView === Access ||
        userPermissionJson.workflowsView === Access ||
        userPermissionJson.workflowsManage === Access
      ) {
        let _ = await fetchConnectorListResponse()
        let _ = await fetchBusinessProfiles()
        let _ = await fetchMerchantAccountDetails()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    setUpConnectoreContainer()->ignore
    None
  }, [userPermissionJson])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    | list{"home"} => featureFlagDetails.quickStart ? <HomeV2 /> : <Home />
    // Connector Modules
    | list{"connectors", ...remainingPath} =>
      <AccessControl permission=userPermissionJson.connectorsView>
        <EntityScaffold
          entityName="Connectors"
          remainingPath
          renderList={() => <ConnectorList />}
          renderNewForm={() => <ConnectorHome />}
          renderShow={_ => <ConnectorHome />}
        />
      </AccessControl>
    | list{"payoutconnectors", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.payOut} permission=userPermissionJson.connectorsView>
        <EntityScaffold
          entityName="PayoutConnectors"
          remainingPath
          renderList={() => <ConnectorList isPayoutFlow=true />}
          renderNewForm={() => <ConnectorHome isPayoutFlow=true />}
          renderShow={_ => <ConnectorHome isPayoutFlow=true />}
        />
      </AccessControl>
    | list{"3ds-authenticators", ...remainingPath} =>
      <AccessControl
        permission=userPermissionJson.connectorsView
        isEnabled={featureFlagDetails.threedsAuthenticator}>
        <EntityScaffold
          entityName="3DS Authenticator"
          remainingPath
          renderList={() => <ThreeDsConnectorList />}
          renderNewForm={() => <ThreeDsProcessorHome />}
          renderShow={_ => <ThreeDsProcessorHome />}
        />
      </AccessControl>

    | list{"pm-authentication-processor", ...remainingPath} =>
      <AccessControl
        permission=userPermissionJson.connectorsView
        isEnabled={featureFlagDetails.pmAuthenticationProcessor}>
        <EntityScaffold
          entityName="PM Authentication Processor"
          remainingPath
          renderList={() => <PMAuthenticationConnectorList />}
          renderNewForm={() => <PMAuthenticationHome />}
          renderShow={_ => <PMAuthenticationHome />}
        />
      </AccessControl>
    | list{"fraud-risk-management", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.frm} permission=userPermissionJson.connectorsView>
        <EntityScaffold
          entityName="risk-management"
          remainingPath
          renderList={() => <FRMSelect />}
          renderNewForm={() => <FRMConfigure />}
          renderShow={_ => <FRMConfigure />}
        />
      </AccessControl>
    | list{"configure-pmts", ...remainingPath} =>
      <AccessControl
        permission=userPermissionJson.connectorsView isEnabled={featureFlagDetails.configurePmts}>
        <FilterContext key="ConfigurePmts" index="ConfigurePmts">
          <EntityScaffold
            entityName="ConfigurePMTs"
            remainingPath
            renderList={() => <PaymentMethodList />}
            renderShow={_profileId => <PaymentSettings webhookOnly=false showFormOnly=false />}
          />
        </FilterContext>
      </AccessControl>
    // Routing
    | list{"routing", ...remainingPath} =>
      <AccessControl permission=userPermissionJson.workflowsView>
        <EntityScaffold
          entityName="Routing"
          remainingPath
          renderList={() => <RoutingStack remainingPath />}
          renderShow={routingType => <RoutingConfigure routingType />}
        />
      </AccessControl>
    | list{"payoutrouting", ...remainingPath} =>
      <AccessControl
        isEnabled={featureFlagDetails.payOut} permission=userPermissionJson.workflowsView>
        <EntityScaffold
          entityName="PayoutRouting"
          remainingPath
          renderList={() => <PayoutRoutingStack remainingPath />}
          renderShow={routingType => <PayoutRoutingConfigure routingType />}
        />
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <> </>
    }}
    <RenderIf
      condition={!featureFlagDetails.isLiveMode &&
      userPermissionJson.merchantDetailsManage === Access &&
      merchantDetailsTypedValue.merchant_name->Option.isNone}>
      <SbxOnboardingSurvey showModal=surveyModal setShowModal=setSurveyModal />
    </RenderIf>
  </PageLoaderWrapper>
}
