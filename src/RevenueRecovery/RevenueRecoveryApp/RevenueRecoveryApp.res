@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recovery"} => <RevenueRecoveryOnboardingLanding createMerchant=true />
    | list{"v2", "recovery", "home"}
    | list{"v2", "recovery", "onboarding", ..._}
    | list{"v2", "recovery", "overview", ..._} =>
      <RecoveryConnectorContainer />
    | list{"v2", "recovery", "summary", ..._} => <BillingConnectorsSummary />
    | _ => React.null
    }
  }
}
