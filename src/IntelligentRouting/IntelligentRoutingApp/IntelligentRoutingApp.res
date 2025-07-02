@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)

  {
    switch merchantDetailsTypedValue.product_type {
    | Vault =>
      switch url.path->HSwitchUtils.urlPath {
      | list{"v2", "dynamic-routing"} => <IntelligentRoutingHome />
      | list{"v2", "dynamic-routing", "home"} => <IntelligentRoutingConfiguration />
      | list{"v2", "dynamic-routing", "dashboard"} => <IntelligentRoutingAnalytics />
      | _ => <EmptyPage path="/v2/dynamic-routing/home" />
      }
    | _ => React.null
    }
  }
}
