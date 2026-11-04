@react.component
let make = (~remainingPath) => {
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let setUpConnectorContainer = async () => {
    try {
      // Not parallel: connector list recoil must commit before ConnectorList mounts
      let _ = await fetchConnectorListResponse()
      let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect(() => {
    setUpConnectorContainer()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState showLogoutButton=true>
    <EntityScaffold
      entityName="Connectors"
      remainingPath
      renderList={() =>
        <ConnectorList
          showDummyProcessorBanner=false
          showRequestConnectorBtn=false
          showDummyConnectorButton=false
        />}
      renderNewForm={() => <ConnectorHome showBreadCrumbWarning=false />}
      renderShow={(_, _) => <ConnectorHome showBreadCrumbWarning=false />}
    />
  </PageLoaderWrapper>
}
