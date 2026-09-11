@react.component
let make = (
  ~googlePayFields,
  ~googlePayIntegrationType,
  ~setGooglePayIntegrationType,
  ~closeModal,
  ~connector,
  ~closeAccordionFn,
  ~update,
) => {
  open LogicUtils
  open GPayFlowUtils
  open Typography

  let form = ReactFinalForm.useForm()
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)

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
    closeAccordionFn()
    let _ = update(metadata)
    Nullable.null->Promise.resolve
  }

  let onDecryptionKeyHandlingChange = (event: ReactEvent.Form.t) => {
    let updatedIntegrationType =
      event->Identity.formReactEventToString->getGooglePayIntegrationTypeFromName
    setGooglePayIntegrationType(_ => updatedIntegrationType)

    let currentGooglePayDict =
      form.getState().values
      ->getDictFromJsonObject
      ->getDictFromNestedDict("connector_wallets_details", "google_pay")

    form.change(
      "connector_wallets_details.google_pay",
      googlePay(
        currentGooglePayDict,
        connector,
        ~googlePayIntegrationType=updatedIntegrationType,
      )->Identity.genericTypeToJson,
    )
  }

  let activeFields =
    googlePayIntegrationType === #internal_gateway ? internalGatewayFields : directFields

  let googlePayFieldsForDirect = googlePayFields->Array.filter(field => {
    let typedData = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
    activeFields->Array.includes(typedData.name)
  })

  <div className="flex flex-col gap-6">
    <FormRenderer.FieldRenderer
      labelClass={body.md.semibold}
      field={decryptionKeyHandlingInput(
        ~onItemChange=onDecryptionKeyHandlingChange,
        ~fill=textColor.primaryNormal,
      )}
    />
    <div>
      {googlePayFieldsForDirect
      ->Array.mapWithIndex((field, index) => {
        let googlePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
        <div key={`${googlePayField.name}-${index->Int.toString}`}>
          <FormRenderer.FieldRenderer
            labelClass={body.md.semibold}
            field={googlePayValueInput(~googlePayField, ~googlePayIntegrationType)}
          />
        </div>
      })
      ->React.array}
      <RenderIf condition={googlePayIntegrationType === #internal_gateway}>
        <FormRenderer.FieldRenderer
          labelClass={body.md.semibold} field={googlePayMerchantIdInput(~googlePayIntegrationType)}
        />
      </RenderIf>
    </div>
    <RenderIf condition={ConnectorUtils.checkIfPredecryptFlowEnabledForGooglePay(connector)}>
      <FormRenderer.FieldRenderer
        labelClass={body.md.semibold}
        fieldWrapperClass="w-full flex justify-between items-center pl-2 pr-4"
        field={FormRenderer.makeFieldInfo(
          ~name={"metadata.google_pay.support_predecrypted_token"},
          ~label="Enable pre decrypted token",
          ~customInput=InputFields.switchInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
        )}
      />
    </RenderIf>
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
