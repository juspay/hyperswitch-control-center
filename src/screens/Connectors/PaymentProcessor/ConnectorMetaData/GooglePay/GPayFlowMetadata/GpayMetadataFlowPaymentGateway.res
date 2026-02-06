@react.component
let make = (~connector, ~googlePayFields, ~closeAccordionFn, ~update, ~closeModal) => {
  open LogicUtils
  open GooglePayUtils

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
      | Standard(data) => form.change("metadata.google_pay", data->Identity.genericTypeToJson)
      | _ => ()
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
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black"
      fieldWrapperClass="w-full flex justify-between items-center pl-2 pr-4"
      field={FormRenderer.makeFieldInfo(
        ~name={"metadata.google_pay.support_predecrypted_token"},
        ~label="Enable Pre-decrypt flow",
        ~customInput=InputFields.boolInput(
          ~isDisabled=false,
          ~boolCustomClass="rounded-lg ",
          ~isCheckBox=true,
        ),
      )}
    />
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
