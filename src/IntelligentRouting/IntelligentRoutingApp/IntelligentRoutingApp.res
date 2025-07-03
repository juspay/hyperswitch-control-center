@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)

  {
    switch activeProduct {
    | Vault =>
      switch url.path->HSwitchUtils.urlPath {
      | list{"v2", "dynamic-routing"} => <IntelligentRoutingHome />
      | list{"v2", "dynamic-routing", "home"} => <IntelligentRoutingConfiguration />
      | list{"v2", "dynamic-routing", "dashboard"} => <IntelligentRoutingAnalytics />
      | _ => <EmptyPage path="/v2/dynamic-routing/home" />
      }
    | _ => <HyperswitchURLRouting />
    }
  }
}
