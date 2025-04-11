@react.component
let make = (
  ~googlePayFields,
  ~googlePayIntegrationType,
  ~closeModal,
  ~connector,
  ~setShowWalletConfigurationModal,
  ~update,
) => {
  open LogicUtils
  open GPayFlowUtils

  let form = ReactFinalForm.useForm()

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let initialGooglePayDict = React.useMemo(() => {
    formState.values->getDictFromJsonObject->getDictfromDict("connector_wallets_details")
  }, [])

  let setFormData = () => {
    if connector->isNonEmptyString {
      let value = googlePay(
        initialGooglePayDict->getDictfromDict("google_pay"),
        connector,
        ~googlePayIntegrationType,
      )
      form.change("connector_wallets_details.google_pay", value->Identity.genericTypeToJson)
    }
  }

  React.useEffect(() => {
    setFormData()
    None
  }, [connector])

  let onSubmit = () => {
    let metadata =
      formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
    setShowWalletConfigurationModal(_ => false)
    let _ = update(metadata)
    Nullable.null->Promise.resolve
  }

  let googlePayFieldsForDirect = googlePayFields->Array.filter(field => {
    let typedData = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
    directFields->Array.includes(typedData.name)
  })

  <>
    {googlePayFieldsForDirect
    ->Array.mapWithIndex((field, index) => {
      let googlePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={googlePayValueInput(~googlePayField, ~googlePayIntegrationType)}
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
        buttonState={formState.values->validateGooglePay(connector, ~googlePayIntegrationType)}
      />
    </div>
    <FormValuesSpy />
  </>
}
