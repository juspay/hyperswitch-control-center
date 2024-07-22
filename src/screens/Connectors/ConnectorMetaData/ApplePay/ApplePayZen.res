@react.component
let make = (~applePayFields, ~update, ~closeModal, ~setShowWalletConfigurationModal) => {
  open LogicUtils
  open ApplePayIntegrationUtils
  open ApplePayIntegrationHelper
  let form = ReactFinalForm.useForm()

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let initalFormValue =
    formState.values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay")

  let setFormData = () => {
    let value = zenApplePayConfig(initalFormValue)
    form.change("metadata.apple_pay", value->Identity.genericTypeToJson)
  }

  React.useEffect(() => {
    setFormData()
    None
  }, [])

  let onSubmit = () => {
    let metadata =
      formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
    let _ = update(metadata)
    setShowWalletConfigurationModal(_ => false)
    Nullable.null->Promise.resolve
  }
  let applePayManualFields =
    applePayFields
    ->Array.mapWithIndex((field, index) => {
      let applePayField = field->convertMapObjectToDict->CommonMetaDataUtils.inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={applePayValueInput(~applePayField, ())}
        />
      </div>
    })
    ->React.array
  <>
    {applePayManualFields}
    <div className="w-full flex gap-2 justify-end p-6">
      <Button
        text="Go Back"
        buttonType={Secondary}
        onClick={_ev => {
          // setShowWalletConfigurationModal(_ => false)
          closeModal()
        }}
      />
      <Button
        text="Verify & Enable"
        buttonType={Primary}
        onClick={_ev => {
          onSubmit()->ignore
        }}
        buttonState={formState.values->validateZenFlow}
      />
    </div>
  </>
}
