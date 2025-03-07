@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let setUpVaultContainer = async () => {
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

  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)

  let isMerchantAvailForProduct =
    merchantList
    ->Array.find(value =>
      value.productType->Option.mapOr(false, productType => productType == Vault)
    )
    ->Option.isSome

  React.useEffect(() => {
    setUpVaultContainer()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    {switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault", "home"} =>
      isMerchantAvailForProduct ? <VaultDefaultHome /> : <VaultHome />
    | list{"v2", "vault", "onboarding", ...remainingPath} =>
      <EntityScaffold
        entityName="VaultConnector"
        remainingPath
        access=Access
        renderList={() => <VaultConfiguration />}
        renderNewForm={() => <VaultOnboarding />}
        renderShow={(_, _) => <PaymentProcessorSummary />}
      />
    | list{"v2", "vault", "customers-tokens", ...remainingPath} =>
      <EntityScaffold
        entityName="Vault"
        remainingPath
        access=Access
        renderList={() => <VaultCustomersAndTokens />}
        renderShow={(id, _) => <VaultCustomerSummary id />}
      />
    | _ => React.null
    }}
  </PageLoaderWrapper>
}
