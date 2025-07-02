@react.component
let make = () => {
    open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)
  {

    {switch merchantDetailsTypedValue.product_type {
    | Recon =>

    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recovery"} => <RevenueRecoveryOnboardingLanding createMerchant=true />
    | _ => <RecoveryConnectorContainer />
    }
     | _ => React.null
    }}
  }
}
