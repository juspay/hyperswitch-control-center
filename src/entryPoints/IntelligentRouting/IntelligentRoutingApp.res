@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)

  let goToLanding = () => {
    if showSideBar {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/intelligent-routing"))
    }
  }

  React.useEffect0(() => {
    goToLanding()
    None
  })

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "intelligent-routing"} => <IntelligentRoutingHome />
    | list{"v2", "intelligent-routing", "home"} => <IntelligentRoutingConfiguration />
    | list{"v2", "intelligent-routing", "dashboard"} => <IntelligentRoutingAnalytics />
    | _ => React.null
    }
  }
}
