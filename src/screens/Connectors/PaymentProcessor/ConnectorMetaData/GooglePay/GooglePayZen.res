@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open LogicUtils
  open GooglePayUtils

  let form = ReactFinalForm.useForm()

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let initialFormValue = React.useMemo(() => {
    formState.values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("google_pay")
  }, [])

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

  let setFormData = () => {
    let value = zenGooglePayConfig(initialFormValue)
    form.change("metadata.google_pay", value->Identity.genericTypeToJson)
  }

  React.useEffect(() => {
    setFormData()
    None
  }, [])

  let closeModal = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }

  let onSubmit = () => {
    let metadata =
      formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
    setShowWalletConfigurationModal(_ => false)
    let _ = update(metadata)
    Nullable.null->Promise.resolve
  }

  <>
    {googlePayFields
    ->Array.mapWithIndex((field, index) => {
      let googlePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
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
        onClick={_ => {
          closeModal()->ignore
        }}
      />
      <Button
        onClick={_ => {
          onSubmit()->ignore
        }}
        text="Proceed"
        buttonType={Primary}
        buttonState={formState.values->validateZenFlow}
      />
    </div>
    <FormValuesSpy />
  </>
}
