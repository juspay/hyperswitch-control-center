/*
PM - PaymentMethod
PMT - PaymentMethodType
PME - PaymentMethodExperience
PMIndex - PaymentMethod Index
PMTIndex - PaymentMethodType Index
 */
@react.component
let make = (~initialValues, ~isInEditState, ~ignoreKeys=[]) => {
  open LogicUtils
  open ConnectorPaymentMethodV2Utils
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let pmts = React.useMemo(() => {
    try {
      Window.getConnectorConfig(connector)->getDictFromJsonObject
    } catch {
    | _ => Dict.make()
    }
  }, [connector])

  let initialValue = React.useMemo(() => {
    let val = initialValues->getDictFromJsonObject

    ConnectorListInterface.mapDictToIndividualConnectorPayload(
      ConnectorListInterface.connectorInterfaceV2,
      val,
    )
  }, [initialValues])
  let defaultIgnoreKeys = ConnectorUtils.configKeysToIgnore->Array.concat(ignoreKeys)

  let paymentMethodValues = React.useMemo(() => {
    let newDict = Dict.make()
    let keys =
      pmts
      ->Dict.keysToArray
      ->Array.filter(val => !Array.includes(defaultIgnoreKeys, val))

    keys->Array.forEach(key => {
      let pm = if key->getPMTFromString == Credit || key->getPMTFromString == Debit {
        "card"
      } else {
        key
      }
      let paymentMethodType = pmts->getArrayFromDict(key, [])
      let updatedData = paymentMethodType->Array.map(
        val => {
          let paymemtMethodType = val->getDictFromJsonObject->getString("payment_method_type", "")
          let paymemtMethodExperience =
            val->getDictFromJsonObject->getString("payment_experience", "")

          let wasmDict = val->getDictFromJsonObject
          let exisitngData = switch initialValue.payment_methods_enabled->Array.find(
            ele => {
              ele.payment_method_type == pm
            },
          ) {
          | Some(data) => {
              let filterData = data.payment_method_subtypes->Array.filter(
                available => {
                  // explicit check for card (for card we need to check the card network rather than the payment method type)
                  if (
                    available.payment_method_subtype == key &&
                      available.card_networks->getValueFromArray(0, "") == paymemtMethodType
                  ) {
                    true
                  } // explicit check for klarna (for klarna we need to check the payment experience rather than the payment method type)
                  else if (
                    connector->ConnectorUtils.getConnectorNameTypeFromString ==
                      Processors(KLARNA) &&
                      available.payment_method_subtype->getPMTFromString == Klarna
                  ) {
                    switch available.payment_experience {
                    | Some(str) => str == paymemtMethodExperience
                    | None => false
                    }
                  } else if (
                    available.payment_method_subtype == paymemtMethodType &&
                    available.payment_method_subtype->getPMTFromString != Credit &&
                    available.payment_method_subtype->getPMTFromString != Debit
                  ) {
                    true
                  } else {
                    false
                  }
                },
              )

              filterData->getValueFromArray(0, wasmDict->getPaymentMethodDictV2(key, connector))
            }
          | None => wasmDict->getPaymentMethodDictV2(key, connector)
          }

          exisitngData
        },
      )
      let existingDataInDict =
        newDict->getArrayFromDict(pm, [])->getPaymentMethodMapper(connector, pm)
      newDict->Dict.set(
        pm,
        existingDataInDict->Array.concat(updatedData)->Identity.genericTypeToJson,
      )
    })
    newDict
  }, (initialValue, connector))
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let data = formState.values->getDictFromJsonObject
  let connData = ConnectorListInterface.mapDictToIndividualConnectorPayload(
    ConnectorListInterface.connectorInterfaceV2,
    data,
  )

  <div className="flex flex-col gap-6 col-span-3">
    <div className="max-w-3xl flex flex-col gap-8">
      {paymentMethodValues
      ->Dict.keysToArray
      ->Array.mapWithIndex((pmValue, index) => {
        // determine the index of the payment method from the form state
        let isPMEnabled =
          connData.payment_methods_enabled->Array.findIndex(ele =>
            ele.payment_method_type == pmValue
          )
        let pmIndex =
          isPMEnabled == -1
            ? connData.payment_methods_enabled->Array.length > 0
                ? connData.payment_methods_enabled->Array.length
                : 0
            : isPMEnabled
        switch pmValue->getPMFromString {
        | Card =>
          <Card
            key={index->Int.toString}
            index
            pm=pmValue
            pmIndex
            paymentMethodValues
            connector
            isInEditState
            initialValues
            formValues=connData
          />
        | _ =>
          <OtherPaymentMethod
            key={index->Int.toString}
            index
            pm=pmValue
            pmIndex
            paymentMethodValues
            connector
            isInEditState
            initialValues
            formValues=connData
          />
        }
      })
      ->React.array}
    </div>
  </div>
}
