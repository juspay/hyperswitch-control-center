let getConfigurationFields = (metadataInputs, method, connector) => {
  open ConnectorUtils
  open LogicUtils
  switch method->getPaymentMethodTypeFromString {
  | GooglePay => metadataInputs->getDictfromDict("google_pay")

  | ApplePay =>
    switch connector->getConnectorNameTypeFromString {
    | ZEN => metadataInputs->getDictfromDict("apple_pay")
    | _ => metadataInputs->getDictfromDict("apple_pay")->getDictfromDict("session_token_data")
    }

  | _ => Dict.make()
  }
}
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
  ) => {
    open LogicUtils
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

    let onSubmit = (values, _) => {
      let json = switch method.payment_method_type->getPaymentMethodTypeFromString {
      | GooglePay => values
      | ApplePay =>
        switch connector->getConnectorNameTypeFromString {
        | ZEN => values

        | _ => {
            let paymentRequestData =
              metadataInputs->getDictfromDict("apple_pay")->getDictfromDict("payment_request_data")

            let _ =
              values
              ->getDictFromJsonObject
              ->getDictfromDict("apple_pay")
              ->Dict.set("payment_request_data", paymentRequestData->JSON.Encode.object)
            values
          }
        }

      | _ => Dict.make()->JSON.Encode.object
      }

      let _ = update(json)
      setShowWalletConfigurationModal(_ => false)

      Nullable.null->Promise.resolve
    }

    let configurationFields = getConfigurationFields(
      metadataInputs,
      method.payment_method_type,
      connector,
    )

    let validate = values => {
      let dict =
        values->getDictFromJsonObject->getConfigurationFields(method.payment_method_type, connector)
      let mandateKyes = configurationFields->Dict.keysToArray->getUniqueArray
      let errorDict = Dict.make()
      mandateKyes->Array.forEach(key => {
        if dict->getString(key, "") === "" {
          errorDict->Dict.set(key, `${key} cannot be empty!`->JSON.Encode.string)
        }
      })
      errorDict->JSON.Encode.object
    }

    let name = switch method.payment_method_type->getPaymentMethodTypeFromString {
    | GooglePay => `google_pay`

    | ApplePay =>
      switch connector->getConnectorNameTypeFromString {
      | ZEN => `apple_pay`
      | _ => `apple_pay.session_token_data`
      }

    | _ => ``
    }

    let fields = {
      configurationFields
      ->Dict.keysToArray
      ->Array.mapWithIndex((field, index) => {
        let label = configurationFields->LogicUtils.getString(field, "")
        <div key={index->Int.toString}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={FormRenderer.makeFieldInfo(
              ~label,
              ~name={`${name}.${field}`},
              ~placeholder={`Enter ${label->LogicUtils.snakeToTitle}`},
              ~customInput=InputFields.textInput(),
              ~isRequired=true,
              (),
            )}
          />
        </div>
      })
      ->React.array
    }
    <div>
      {switch (
        method.payment_method_type->getPaymentMethodTypeFromString,
        connector->getConnectorNameTypeFromString,
      ) {
      | (ApplePay, STRIPE) | (ApplePay, BANKOFAMERICA) | (ApplePay, CYBERSOURCE) =>
        <ApplePayWalletIntegration metadataInputs update metaData setShowWalletConfigurationModal />
      | _ =>
        <Form initialValues={metaData} onSubmit validate>
          {fields}
          <FormRenderer.SubmitButton
            text="Proceed" showToolTip=true buttonSize=Button.Large customSumbitButtonStyle="w-full"
          />
          <FormValuesSpy />
        </Form>
      }}
    </div>
  }
}
