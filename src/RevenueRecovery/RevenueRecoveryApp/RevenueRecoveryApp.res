@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recovery"} => <RevenueRecoveryOnboardingLanding />
    | list{"v2", "recovery", "home"} => <RevenueRecoveryOnboarding />
    | list{"v2", "recovery", "summary", ..._} => <BillingConnectorsSummary />
    | list{"v2", "recovery", "onboarding", ..._}
    | list{"v2", "recovery", "overview", ..._}
    | list{"v2", "recovery", "connectors", ..._} =>
      <RecoveryConnectorContainer />
    | _ => React.null
    }
  }
}
