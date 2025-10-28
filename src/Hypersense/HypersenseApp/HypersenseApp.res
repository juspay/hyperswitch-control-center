@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "cost-observability"} => <HypersenseConfigurationContainer />
    | list{"v2", "cost-observability", "home"} => <HypersenseHomeContainer />
    | _ => <EmptyPage path="/v2/cost-observability/hom" />
    }
  }
}
