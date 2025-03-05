@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)

  // Need to be moved into vault container
  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)

  let goToLanding = () => {
    if showSideBar {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/vault/home"))
    }
  }

  React.useEffect(() => {
    goToLanding()
    None
  }, [])

  let isMerchantAvailForProduct =
    merchantList
    ->Array.find(value =>
      value.productType->Option.mapOr(false, productType => productType == Vault)
    )
    ->Option.isSome

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault", "home"} =>
      isMerchantAvailForProduct ? <VaultDefaultHome /> : <VaultHome />
    | list{"v2", "vault", "onboarding", ...remainingPath} =>
      <EntityScaffold
        entityName="VaultConnector"
        remainingPath
        access=Access
        renderList={() => <VaultConfiguration />}
        renderNewForm={() => <VaultOnboarding />}
        renderShow={(_, _) => <PaymentProcessorSummary baseUrl="v2/vault/onboarding" />}
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
    }
  }
}
