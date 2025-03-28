@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "cost-observability", "home"} => <HypersenseHomeContainer />
    | _ =>
      RescriptReactRouter.replace(`/dashboard/v2/cost-observability/home`)
      React.null
    }
  }
}
