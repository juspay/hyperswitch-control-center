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

  | _ => Js.Dict.empty()
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
      | _error => Js.Dict.empty()
      }
    }, [connector])

    let update = json => {
      setMetaData(_ => json)
      paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
    }

    let onSubmit = (values, _) => {
      let json = switch method->getPaymentMethodTypeFromString {
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
              ->Js.Dict.set("payment_request_data", paymentRequestData->Js.Json.object_)
            values
          }
        }

      | _ => Js.Dict.empty()->Js.Json.object_
      }

      let _ = update(json)
      setShowWalletConfigurationModal(_ => false)

      Js.Nullable.null->Js.Promise.resolve
    }

    let configurationFields = getConfigurationFields(metadataInputs, method, connector)

    let validate = values => {
      let dict = values->getDictFromJsonObject->getConfigurationFields(method, connector)
      let mandateKyes = configurationFields->Js.Dict.keys->getUniqueArray
      let errorDict = Js.Dict.empty()
      mandateKyes->Js.Array2.forEach(key => {
        if dict->getString(key, "") === "" {
          errorDict->Js.Dict.set(key, `${key} cannot be empty!`->Js.Json.string)
        }
      })
      errorDict->Js.Json.object_
    }

    let name = switch method->getPaymentMethodTypeFromString {
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
      ->Js.Dict.keys
      ->Array.mapWithIndex((field, index) => {
        let label = configurationFields->LogicUtils.getString(field, "")
        <div key={index->Belt.Int.toString}>
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
      {switch (method->getPaymentMethodTypeFromString, connector->getConnectorNameTypeFromString) {
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
