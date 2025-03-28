@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  Js.log("inside  vault app")

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "vault", "home"} => <VaultDefaultHome />
    | list{"v2", "vault", "onboarding", ..._} | list{"v2", "vault", "customers-tokens", ..._} =>
      <VaultContainer />
    | _ => {
        Js.log("inside vault defautl")
        RescriptReactRouter.replace(`/dashboard/v2/vault/home`)
        React.null
      }
    }
  }
}
