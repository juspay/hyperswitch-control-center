@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"v2", "recovery", "home"} => <RevenueRecoveryHome />
    | list{"v2", "recovery", "payment-processors", ..._} => <RecoveryConnectorContainer />
    | list{"v2", "recovery", "billing-processors", ..._} => <RevenueRecoveryBillingProcessors />
    | list{"v2", "recovery", "payments"} => <RevenueRecoveryPayments />
    | _ => React.null
    }
  }
}
