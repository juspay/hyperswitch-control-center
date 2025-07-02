@react.component
let make = () => {
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)

  {
    switch merchantDetailsTypedValue.product_type {
    | CostObservability =>
      switch url.path->HSwitchUtils.urlPath {
      | list{"v2", "cost-observability"} => <HypersenseConfigurationContainer />
      | list{"v2", "cost-observability", "home"} => <HypersenseHomeContainer />
      | _ => <EmptyPage path="/v2/cost-observability/home" />
      }
    | _ => React.null
    }
  }
}
