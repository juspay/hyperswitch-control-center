@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault", "configuration"} => <VaultConfiguration />
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
