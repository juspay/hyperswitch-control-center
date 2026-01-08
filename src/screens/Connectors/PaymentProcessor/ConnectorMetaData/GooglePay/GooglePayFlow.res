@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open GooglePayUtils

  let googlePayFields = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        Window.getConnectorConfig(connector)
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getArrayFromDict("google_pay", [])
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
  let initialGooglePayDict = React.useMemo(() => {
    formState.values->getDictFromJsonObject->getDictfromDict("metadata")
  }, [])

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
    closeAccordionFn()
    let _ = update(metadata)
    Nullable.null->Promise.resolve
  }

  let closeModal = () => {
    onCloseClickCustomFun()
    closeAccordionFn()
  }

  <div className="flex flex-col gap-6">
    <div>
      {googlePayFields
      ->Array.mapWithIndex((field, index) => {
        let googlePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
        <div key={`${googlePayField.name}-${index->Int.toString}`}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={googlePayValueInput(~googlePayField)}
          />
        </div>
      })
      ->React.array}
    </div>
    <div className={`flex gap-2 justify-end mt-4`}>
      <Button
        text="Cancel"
        buttonType={Secondary}
        onClick={_ => {
          closeModal()->ignore
        }}
        customButtonStyle="w-full"
      />
      <Button
        onClick={_ => {
          onSubmit()->ignore
        }}
        text="Proceed"
        buttonType={Primary}
        buttonState={formState.values->validateGooglePay(connector)}
        customButtonStyle="w-full"
      />
    </div>
  </div>
}
