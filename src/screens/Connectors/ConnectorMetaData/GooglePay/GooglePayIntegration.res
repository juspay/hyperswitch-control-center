@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open GooglePayUtils
  let googlePayFields = React.useMemo1(() => {
    try {
      if connector->isNonEmptyString {
        let dict =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getArrayFromDict("google_pay", [])

        dict
      } else {
        []
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        []
      }
    }
  }, [connector])
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let initialGooglePayDict = React.useMemo0(() => {
    formState.values->getDictFromJsonObject->getDictfromDict("metadata")
  })

  let form = ReactFinalForm.useForm()
  React.useEffect(() => {
    if connector->isNonEmptyString {
      let value = googlePay(initialGooglePayDict->getDictfromDict("google_pay"), connector)
      switch value {
      | Zen(data) => form.change("metadata.google_pay", data->Identity.genericTypeToJson)
      | Standard(data) => form.change("metadata.google_pay", data->Identity.genericTypeToJson)
      }
    }
    None
  }, [connector])
  let onSubmit = () => {
    let metadata =
      formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
    setShowWalletConfigurationModal(_ => false)
    let _ = update(metadata)
    Nullable.null->Promise.resolve
  }

  let closeModal = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }
  <>
    {googlePayFields
    ->Array.mapWithIndex((field, index) => {
      let googlePayField = field->convertMapObjectToDict->CommonMetaDataUtils.inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={googlePayValueInput(~googlePayField)}
        />
      </div>
    })
    ->React.array}
    <div className={`flex gap-2 justify-end mt-4`}>
      <Button
        text="Cancel"
        buttonType={Secondary}
        onClick={_ev => {
          closeModal()->ignore
        }}
      />
      <Button
        onClick={_ev => {
          onSubmit()->ignore
        }}
        text="Proceed"
        buttonType={Primary}
      />
    </div>
  </>
}
