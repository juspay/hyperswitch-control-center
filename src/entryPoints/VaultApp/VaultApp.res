@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault"} => <VaultHome />
    | list{"v2", "vault", "home"} => <VaultDefaultHome />
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
