@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "cost-observability"} => <HypersenseConfigurationContainer />
    | list{"v2", "cost-observability", "home"} => <HypersenseHomeContainer />
    | _ => <EmptyPage path="/v2/cost-observability/home" />
    }
  }
}
