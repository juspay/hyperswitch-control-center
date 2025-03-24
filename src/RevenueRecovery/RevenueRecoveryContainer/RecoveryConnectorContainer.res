@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=V2,
  )
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let {merchantId, profileId} = getUserInfoData()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let navigate = hasConfiguredBillingConnector => {
    switch url.path->urlPath {
    | list{"v2", "recovery", "home"} =>
      if hasConfiguredBillingConnector {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/overview"))
      }
    | list{"v2", "recovery", "overview", ..._}
    | list{"v2", "recovery", "summary", ..._} =>
      if !hasConfiguredBillingConnector {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
      }
    | _ => ()
    }
  }

  let setUpConnectorContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if (
        userHasAccess(~groupAccess=ConnectorsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsManage) === Access
      ) {
        let _ = await fetchConnectorListResponse()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  let connectors = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV2,
    ~retainInList=BillingProcessor,
  )

  React.useEffect(() => {
    let hasConfiguredBillingConnector = connectors->Array.length > 0
    navigate(hasConfiguredBillingConnector)
    None
  }, (url, connectors))

  React.useEffect(() => {
    setUpConnectorContainer()->ignore
    None
  }, [merchantId, profileId])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    | list{"v2", "recovery", "home"} => <RevenueRecoveryOnboardingLanding createMerchant=false />
    | list{"v2", "recovery", "onboarding", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="onboarding"
          remainingPath
          renderList={() => <RevenueRecoveryOnboarding />}
          renderNewForm={() => <RevenueRecoveryOnboarding />}
          renderShow={(_, _) => <RevenueRecoveryOnboarding />}
        />
      </AccessControl>
    | list{"v2", "recovery", "overview", ...remainingPath} =>
      <EntityScaffold
        entityName="Payments"
        remainingPath
        access=Access
        renderList={() => <RevenueRecoveryOverview />}
        renderCustomWithOMP={(id, _, _, _) => <ShowRevenueRecovery id />}
      />
    | list{"v2", "recovery", "summary", ..._} => <BillingConnectorsSummary />
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </PageLoaderWrapper>
}
