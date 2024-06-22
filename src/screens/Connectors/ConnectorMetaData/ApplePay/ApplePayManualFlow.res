open ApplePayIntegrationTypesV2

module PaymentProcessingDetailsAt = {
  @react.component
  let make = (~applePayField) => {
    open LogicUtils
    open ApplePayIntegrationUtilsV2
    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let initalFormValue =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
      ->getDictfromDict("apple_pay_combined")
      ->manual

    let initalProcessingAt =
      initalFormValue.session_token_data.payment_processing_details_at
      ->Option.getOr((#Connector: paymentProcessingState :> string))
      ->paymentProcessingMapper
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let (processingAt, setProcessingAt) = React.useState(_ => initalProcessingAt)

    let onChangeItem = (event: ReactEvent.Form.t) => {
      let value =
        event->Identity.formReactEventToString->ApplePayIntegrationUtilsV2.paymentProcessingMapper
      setProcessingAt(_ => value)
      if value === #Connector {
        form.change(
          `${ApplePayIntegrationUtilsV2.applePayNameMapper(
              ~name="payment_processing_certificate",
              ~integrationType=Some(#manual),
            )}`,
          JSON.Encode.null,
        )
        form.change(
          `${ApplePayIntegrationUtilsV2.applePayNameMapper(
              ~name="payment_processing_certificate_key",
              ~integrationType=Some(#manual),
            )}`,
          JSON.Encode.null,
        )
      }
    }

    <>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-hyperswitch_black"
        field={CommonMetaDataHelper.radioInput(
          ~field=applePayField,
          ~formName=`${ApplePayIntegrationUtilsV2.applePayNameMapper(
              ~name=applePayField.name,
              ~integrationType=Some(#manual),
            )}`,
          ~fill=textColor.primaryNormal,
          ~onItemChange=onChangeItem,
          (),
        )}
      />
      {switch processingAt {
      | #Hyperswitch =>
        <div>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={FormRenderer.makeFieldInfo(
              ~label="Payment Processing Certificate",
              ~name={
                `${ApplePayIntegrationUtilsV2.applePayNameMapper(
                    ~name="payment_processing_certificate",
                    ~integrationType=Some(#manual),
                  )}`
              },
              ~placeholder={`Enter Processing Certificate`},
              ~customInput=InputFields.textInput(),
              ~isRequired=true,
              (),
            )}
          />
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={FormRenderer.makeFieldInfo(
              ~label="Payment Processing Key",
              ~name={
                `${ApplePayIntegrationUtilsV2.applePayNameMapper(
                    ~name="payment_processing_certificate_key",
                    ~integrationType=Some(#manual),
                  )}`
              },
              ~placeholder={`Enter Processing Key`},
              ~customInput=InputFields.multiLineTextInput(
                ~rows=Some(10),
                ~cols=Some(100),
                ~isDisabled=false,
                ~customClass="",
                ~leftIcon=React.null,
                ~maxLength=10000,
                (),
              ),
              ~isRequired=true,
              (),
            )}
          />
        </div>
      | _ => React.null
      }}
    </>
  }
}

@react.component
let make = (
  ~applePayFields,
  ~merchantBusinessCountry,
  ~setApplePayIntegrationSteps,
  ~setVefifiedDomainList,
) => {
  open LogicUtils
  open ApplePayIntegrationUtilsV2
  open ApplePayIntegrationHelperV2
  let form = ReactFinalForm.useForm()
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let initalFormValue =
    formState.values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay_combined")
  let setFormData = () => {
    let value = applePayCombined(initalFormValue, #manual)
    form.change("metadata.apple_pay_combined", value->Identity.genericTypeToJson)
  }

  React.useEffect0(() => {
    let _ = setFormData()
    None
  })
  let onSubmit = () => {
    let data =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
      ->getDictfromDict("apple_pay_combined")
      ->manual
    let domainName = data.session_token_data.initiative_context->Option.getOr("")

    setVefifiedDomainList(_ => [domainName])
    setApplePayIntegrationSteps(_ => ApplePayIntegrationTypesV2.Verify)
    Nullable.null->Promise.resolve
  }
  let applePayManualFields =
    applePayFields
    ->Array.mapWithIndex((field, index) => {
      let applePayField = field->convertMapObjectToDict->CommonMetaDataUtils.inputFieldMapper
      let {name} = applePayField
      <div key={index->Int.toString}>
        {switch name {
        | "payment_processing_details_at" => <PaymentProcessingDetailsAt applePayField />
        | _ =>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={applePayValueInput(
              ~applePayField,
              ~integrationType=Some(#manual),
              ~merchantBusinessCountry,
              (),
            )}
          />
        }}
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
          setApplePayIntegrationSteps(_ => Landing)
        }}
      />
      <Button
        text="Verify & Enable"
        buttonType={Primary}
        onClick={_ev => {
          onSubmit()->ignore
        }}
        buttonState={formState.values->validateManualFlow}
      />
    </div>
  </>
}
