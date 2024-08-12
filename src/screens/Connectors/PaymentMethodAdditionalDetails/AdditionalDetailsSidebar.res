module AdditionalDetailsSidebarComp = {
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
    ~setInitialValues,
  ) => {
    open LogicUtils

    let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")

    let updateMetadata = json => {
      setMetaData(_ => json)
      paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
    }

    let updatePaymentMethods = () => {
      paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
    }

    <div>
      {switch paymentMethod->getPaymentMethodFromString {
      | BankDebit =>
        <BankDebit
          setShowWalletConfigurationModal
          update=updatePaymentMethods
          onCloseClickCustomFun
          paymentMethod
          paymentMethodType=method.payment_method_type
          setInitialValues
        />
      | _ => React.null
      }}
      <RenderIf condition={paymentMethod->getPaymentMethodFromString !== BankDebit}>
        {switch method.payment_method_type->getPaymentMethodTypeFromString {
        | ApplePay =>
          <ApplePayIntegration
            connector setShowWalletConfigurationModal update=updateMetadata onCloseClickCustomFun
          />
        | GooglePay =>
          <GooglePayIntegration
            connector setShowWalletConfigurationModal update=updateMetadata onCloseClickCustomFun
          />
        | _ => React.null
        }}
      </RenderIf>
    </div>
  }
}
