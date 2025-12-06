module AdditionalDetailsSidebarComp = {
  open ConnectorTypes
  open ConnectorUtils
  @react.component
  let make = (
    ~method: option<ConnectorTypes.paymentMethodConfigType>,
    ~setMetaData,
    ~updateDetails,
    ~paymentMethodsEnabled,
    ~paymentMethod,
    ~setInitialValues,
    ~pmtName: string,
    ~closeAccordionFn,
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
          update=updatePaymentMethods
          paymentMethod
          paymentMethodType=pmtName
          setInitialValues
          closeAccordionFn
        />
      | _ => React.null
      }}
      <RenderIf condition={paymentMethod->getPaymentMethodFromString !== BankDebit}>
        {switch pmtName->getPaymentMethodTypeFromString {
        | ApplePay => <ApplePayIntegration connector closeAccordionFn update=updateMetadata />
        | GooglePay => <GooglePayIntegration connector closeAccordionFn update=updateMetadata />
        | SamsungPay =>
          <SamsungPayIntegration connector closeAccordionFn update=updatePaymentMethods />
        | Paze => <PazeIntegration connector closeAccordionFn update=updatePaymentMethods />
        | _ => React.null
        }}
      </RenderIf>
    </div>
  }
}
