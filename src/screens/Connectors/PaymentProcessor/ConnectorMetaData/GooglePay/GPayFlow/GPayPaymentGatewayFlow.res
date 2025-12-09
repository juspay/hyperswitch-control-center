@react.component
let make = (
  ~googlePayFields,
  ~googlePayIntegrationType,
  ~closeModal,
  ~connector,
  ~closeAccordionFn,
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

  let googlePayFieldsForPaymentGateway = googlePayFields->Array.filter(field => {
    let typedData = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
    !(ignoreDirectFields->Array.includes(typedData.name))
  })

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
    let connectorWalletDetails =
      formState.values->getDictFromJsonObject->getDictfromDict("connector_wallets_details")

    let metadataDetails =
      connectorWalletDetails
      ->getMetadataFromConnectorWalletDetailsGooglePay(connector)
      ->Identity.genericTypeToJson
    form.change("metadata.google_pay", metadataDetails)
    closeAccordionFn()
    let _ = update(metadataDetails)
    Nullable.null->Promise.resolve
  }

  <div className="flex flex-col gap-6">
    <div>
      {googlePayFieldsForPaymentGateway
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
        buttonState={formState.values->validateGooglePay(connector, ~googlePayIntegrationType)}
        customButtonStyle="w-full"
      />
    </div>
  </div>
}
