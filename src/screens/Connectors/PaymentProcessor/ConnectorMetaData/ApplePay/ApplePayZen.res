@react.component
let make = (~applePayFields, ~update, ~closeModal, ~closeAccordionFn, ~connector) => {
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
    closeAccordionFn()
    Nullable.null->Promise.resolve
  }
  let applePayManualFields =
    applePayFields
    ->Array.mapWithIndex((field, index) => {
      let applePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={applePayValueInput(~applePayField, ~connector)}
        />
      </div>
    })
    ->React.array

  <div className="flex flex-col gap-6 p-6">
    <div> {applePayManualFields} </div>
    <div className="w-full flex gap-2 justify-end">
      <Button
        text="Go Back"
        buttonType={Secondary}
        onClick={_ => {
          closeModal()
        }}
        customButtonStyle="w-full"
      />
      <Button
        text="Verify & Enable"
        buttonType={Primary}
        onClick={_ => {
          onSubmit()->ignore
        }}
        buttonState={formState.values->validateZenFlow}
        customButtonStyle="w-full"
      />
    </div>
  </div>
}
