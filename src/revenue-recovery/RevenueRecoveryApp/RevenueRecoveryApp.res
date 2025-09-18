@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recovery"} => <RevenueRecoveryOnboardingLanding createMerchant=true />
    | _ => <RecoveryConnectorContainer />
    }
  }
}
