@react.component
let make = () => {
  open HSwitchUtils
  open RevenueRecoveryOnboardingUtils
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=V2,
  )
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let {merchantId, profileId} = getUserInfoData()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

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

  let hasConfiguredBillingConnector =
    ConnectorInterface.useConnectorArrayMapper(
      ~interface=ConnectorInterface.connectorInterfaceV2,
      ~retainInList=BillingProcessor,
    )->Array.length > 0

  React.useEffect(() => {
    setUpConnectorContainer()->ignore
    None
  }, [merchantId, profileId])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    | list{"v2", "recovery", "home"} =>
      hasConfiguredBillingConnector
        ? <div className="mt-10">
            {sampleDataBanner}
            <RevenueRecoveryOverview />
          </div>
        : <RevenueRecoveryOnboardingLanding default=false />
    | list{"v2", "recovery", "onboarding", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        {<div className="mt-14">
          {sampleDataBanner}
          <EntityScaffold
            entityName="onboarding"
            remainingPath
            renderList={() => <RevenueRecoveryOnboarding />}
            renderNewForm={() => <RevenueRecoveryOnboarding />}
            renderShow={(_, _) => <RevenueRecoveryOnboarding />}
          />
        </div>}
      </AccessControl>
    | list{"v2", "recovery", "overview", ...remainingPath} =>
      <div className="mt-10">
        {sampleDataBanner}
        <EntityScaffold
          entityName="Payments"
          remainingPath
          access=Access
          renderList={() => <RevenueRecoveryOverview />}
          renderCustomWithOMP={(id, _, _, _) => <ShowRevenueRecovery id />}
        />
      </div>

    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </PageLoaderWrapper>
}
