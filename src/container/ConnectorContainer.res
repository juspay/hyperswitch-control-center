@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let (userPermissionJson, _) = Recoil.useRecoilState(userPermissionAtom)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
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
    {switch url.path {
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
    | _ => <> </>
    }}
  </PageLoaderWrapper>
}
