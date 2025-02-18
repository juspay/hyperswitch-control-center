@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recovery"} => <RevenueRecoveryOnboardingLanding />
    | list{"v2", "recovery", "connectors", ..._} => <RecoveryConnectorContainer />
    | list{"v2", "recovery", "overview"} => <RevenueRecoveryOverview />
    | _ => React.null
    }
  }
}
