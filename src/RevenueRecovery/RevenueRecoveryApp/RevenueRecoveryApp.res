@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)

  {
    switch activeProduct {
    | Recovery =>
      switch url.path->HSwitchUtils.urlPath {
      | list{"v2", "recovery"} => <RevenueRecoveryOnboardingLanding createMerchant=true />
      | _ => <RecoveryConnectorContainer />
      }
    | _ => <HyperswitchURLRouting />
    }
  }
}
