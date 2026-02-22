@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess, _} = GroupACLHooks.useUserGroupACLHook()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=V2,
  )
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId(~version=V2)
  let setConnectorList = HyperswitchAtom.connectorListAtom->Recoil.useSetRecoilState
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let setUpConnectorContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      if (
        userHasAccess(~groupAccess=ConnectorsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsManage) === Access
      ) {
        setConnectorList(_ => [])
        let _ = await fetchConnectorListResponse()
        let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    setUpConnectorContainer()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    | list{"v2", "orchestration", "connectors", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="Payment Connectors"
          remainingPath
          renderList={() => <PaymentConnectors />}
          renderNewForm={() => <PaymentConnectorOnboarding />}
          renderShow={(_, _) =>
            <PaymentProcessorSummary
              baseUrl="v2/orchestration/connectors" showProcessorStatus=false topPadding="!p-0"
            />}
        />
      </AccessControl>
    | list{"v2", "orchestration", "vault-processors", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        <EntityScaffold
          entityName="Vault Processors"
          remainingPath
          renderList={() => <VaultProcessors />}
          renderNewForm={() => <VaultProcessorOnboarding />}
          renderShow={(_, _) =>
            <VaultProcessorSummary baseUrl="v2/orchestration/vault-processors" />}
        />
      </AccessControl>
    | list{"v2", "orchestration", "payment-settings", ..._} => <PaymentSettingsRevamped />
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </PageLoaderWrapper>
}
