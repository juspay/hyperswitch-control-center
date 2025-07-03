@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)

  {
    if merchantDetailsTypedValue.product_type == Vault {
      switch url.path->HSwitchUtils.urlPath {
      | list{"v2", "vault"} => <VaultHome />
      | list{"v2", "vault", "home"} => <VaultDefaultHome />
      | list{"v2", "vault", "onboarding", ..._} | list{"v2", "vault", "customers-tokens", ..._} =>
        <VaultContainer />
      | _ => React.null
      }
    } else {
      React.null
    }
  }
}
