@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault"} => <VaultHome />
    | list{"v2", "vault", "home"} => <VaultDefaultHome />
    | list{"v2", "vault", "onboarding", ..._} | list{"v2", "vault", "customers-tokens", ..._} =>
      <VaultContainer />
    | list{"v2", "vault", "api-keys"} => <VaultAPIKeys />
    | _ => React.null
    }
  }
}
