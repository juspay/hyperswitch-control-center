@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "hypersense"} => <HypersenseConfigurationContainer />
    | list{"v2", "hypersense", "home"} => <HypersenseHomeContainer />
    | _ => React.null
    }
  }
}
