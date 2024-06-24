module Wallets = {
  open ConnectorTypes
  open ConnectorUtils
  @react.component
  let make = (
    ~method,
    ~metaData,
    ~setMetaData,
    ~setShowWalletConfigurationModal,
    ~updateDetails,
    ~paymentMethodsEnabled,
    ~paymentMethod,
    ~onCloseClickCustomFun,
  ) => {
    open LogicUtils
    open HyperswitchAtom
    let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
    let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")
    let metadataInputs = React.useMemo1(() => {
      try {
        Window.getConnectorConfig(connector)->getDictFromJsonObject->getDictfromDict("metadata")
      } catch {
      | _error => Dict.make()
      }
    }, [connector])

    let update = json => {
      setMetaData(_ => json)
      paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
    }

    <div>
      {if featureFlagDetails.connectorMetadatav2 {
        switch method.payment_method_type->getPaymentMethodTypeFromString {
        | ApplePay =>
          <ApplePayIntegrationV2
            connector setShowWalletConfigurationModal update onCloseClickCustomFun
          />

        | _ => React.null
        }
      } else {
        {
          switch method.payment_method_type->getPaymentMethodTypeFromString {
          | ApplePay =>
            <ApplePayWalletIntegration
              metadataInputs
              update
              metaData
              setShowWalletConfigurationModal
              connector
              onCloseClickCustomFun
            />

          | GooglePay =>
            <GooglePayIntegration
              connector setShowWalletConfigurationModal update onCloseClickCustomFun
            />
          | _ => React.null
          }
        }
      }}
    </div>
  }
}
