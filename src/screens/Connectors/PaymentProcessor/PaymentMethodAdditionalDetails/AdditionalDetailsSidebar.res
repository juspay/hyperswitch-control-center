module AdditionalDetailsSidebarComp = {
  open ConnectorTypes
  open ConnectorUtils
  @react.component
  let make = (
    ~method: option<ConnectorTypes.paymentMethodConfigType>,
    ~setMetaData,
    ~setShowWalletConfigurationModal,
    ~updateDetails,
    ~paymentMethodsEnabled,
    ~paymentMethod,
    ~onCloseClickCustomFun,
    ~setInitialValues,
    ~pmtName: string,
  ) => {
    open LogicUtils
    let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")

    let updateMetadata = json => {
      setMetaData(_ => json)
      switch method {
      | Some(pmt) => paymentMethodsEnabled->addMethod(paymentMethod, pmt)->updateDetails
      | _ => ()
      }
    }

    let updatePaymentMethods = () => {
      switch method {
      | Some(pmt) => paymentMethodsEnabled->addMethod(paymentMethod, pmt)->updateDetails
      | _ => ()
      }
    }

    <div>
      {switch paymentMethod->getPaymentMethodFromString {
      | BankDebit =>
        <BankDebit
          setShowWalletConfigurationModal
          update=updatePaymentMethods
          paymentMethod
          paymentMethodType=pmtName
          setInitialValues
        />
      | _ => React.null
      }}
      <RenderIf condition={paymentMethod->getPaymentMethodFromString !== BankDebit}>
        {switch pmtName->getPaymentMethodTypeFromString {
        | ApplePay =>
          <ApplePayIntegration
            connector setShowWalletConfigurationModal update=updateMetadata onCloseClickCustomFun
          />
        | GooglePay =>
          <GooglePayIntegration
            connector setShowWalletConfigurationModal update=updateMetadata onCloseClickCustomFun
          />
        | SamsungPay =>
          <SamsungPayIntegration
            connector
            setShowWalletConfigurationModal
            update=updatePaymentMethods
            onCloseClickCustomFun
          />
        | Paze =>
          <PazeIntegration
            connector
            setShowWalletConfigurationModal
            update=updatePaymentMethods
            onCloseClickCustomFun
          />
        | AmazonPay =>
          <AmazonPayIntegration
            connector
            setShowWalletConfigurationModal
            update=updatePaymentMethods
            onCloseClickCustomFun
          />
        | _ => React.null
        }}
      </RenderIf>
    </div>
  }
}
