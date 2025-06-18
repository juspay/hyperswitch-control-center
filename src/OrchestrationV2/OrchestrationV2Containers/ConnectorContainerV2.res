@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess, _} = GroupACLHooks.useUserGroupACLHook()
  let _fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let _fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let setUpConnectoreContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      // TODO: implement call for V2 apis here
      // if (
      //   userHasAccess(~groupAccess=ConnectorsView) === Access ||
      //   userHasAccess(~groupAccess=WorkflowsView) === Access ||
      //   userHasAccess(~groupAccess=WorkflowsManage) === Access
      // ) {
      //   let _ = await fetchConnectorListResponse()
      //   let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      // }
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
    | list{"v2", "orchestration-v2", "connectors", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="Payment Connectors" remainingPath renderList={() => <PaymentConnectorsV2 />}
        />
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </PageLoaderWrapper>
}
