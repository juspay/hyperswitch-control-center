@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault", "configuration"} => <VaultConfiguration />
    | list{"v2", "vault", "customers-tokens"} => <VaultCustomersAndTokens />
    | _ => React.null
    }
  }
}
