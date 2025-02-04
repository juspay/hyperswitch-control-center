@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  // Need to be moved into vault container
  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)

  let goToLanding = () => {
    if showSideBar {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/vault/home"))
    }
  }

  React.useEffect0(() => {
    goToLanding()
    None
  })

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault", "home"} => <VaultHome />
    // | list{"v2", "vault", "configuration"} => <VaultConfiguration />
    | list{"v2", "vault", "onboarding", ...remainingPath} =>
      <EntityScaffold
        entityName="VaultConnector"
        remainingPath
        access=Access
        renderList={() => <VaultConfiguration />}
        renderNewForm={() => <VaultOnboarding />}
        renderShow={(_, _) => <ConnectorSummary />}
      />
    | list{"v2", "vault", "customers-tokens"} => <VaultCustomersAndTokens />
    | _ => React.null
    }
  }
}
