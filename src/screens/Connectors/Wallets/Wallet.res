module Wallets = {
  open ConnectorTypes
  open ConnectorUtils
  @react.component
  let make = (
    ~method,
    ~setMetaData,
    ~setShowWalletConfigurationModal,
    ~updateDetails,
    ~paymentMethodsEnabled,
    ~paymentMethod,
    ~onCloseClickCustomFun,
  ) => {
    open LogicUtils

    let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")

    let update = json => {
      setMetaData(_ => json)
      paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
    }

    <div>
      {switch method.payment_method_type->getPaymentMethodTypeFromString {
      | ApplePay =>
        <ApplePayIntegration
          connector setShowWalletConfigurationModal update onCloseClickCustomFun
        />
      | GooglePay =>
        <GooglePayIntegration
          connector setShowWalletConfigurationModal update onCloseClickCustomFun
        />
      | _ => React.null
      }}
    </div>
  }
}
