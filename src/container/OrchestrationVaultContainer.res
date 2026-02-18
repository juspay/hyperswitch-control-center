@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V1(CONNECTOR),
    ~version=V1,
  )

  let (sampleReport, setSampleReport) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let setConnectorList = HyperswitchAtom.connectorListAtom->Recoil.useSetRecoilState
  let setIsOrchestrationVault = Recoil.useSetRecoilState(HyperswitchAtom.orchestrationVaultAtom)

  let setUpVaultContainer = async () => {
    try {
      if (
        userHasAccess(~groupAccess=ConnectorsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsManage) === Access
      ) {
        setConnectorList(_ => [])
        let _ = await fetchConnectorListResponse()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    setIsOrchestrationVault(_ => true)
    setUpVaultContainer()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    {switch url.path->HSwitchUtils.urlPath {
    | list{"vault-onboarding", ...remainingPath} =>
      <EntityScaffold
        entityName="VaultConnector"
        remainingPath
        access=Access
        renderList={() => <VaultConfiguration />}
        renderNewForm={() => <VaultOnboarding />}
      />
    | list{"vault-customers-tokens", ...remainingPath} =>
      <EntityScaffold
        entityName="Vault"
        remainingPath
        access=Access
        renderList={() => <VaultCustomersAndTokens sampleReport setSampleReport />}
        renderShow={(id, _) => <VaultCustomerSummary id sampleReport />}
      />
    | _ => React.null
    }}
  </PageLoaderWrapper>
}
