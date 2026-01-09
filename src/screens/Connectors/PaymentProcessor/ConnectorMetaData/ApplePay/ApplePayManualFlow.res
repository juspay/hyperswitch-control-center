open ApplePayIntegrationTypes

module PaymentProcessingDetailsAt = {
  @react.component
  let make = (~applePayField, ~connector) => {
    open LogicUtils
    open ApplePayIntegrationUtils
    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let initalFormValue =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
      ->getDictfromDict("apple_pay_combined")
      ->manual(connector)

    let initalProcessingAt =
      initalFormValue.session_token_data.payment_processing_details_at
      ->Option.getOr((#Connector: paymentProcessingState :> string))
      ->paymentProcessingMapper
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let (processingAt, setProcessingAt) = React.useState(_ => initalProcessingAt)

    let onChangeItem = (event: ReactEvent.Form.t) => {
      let value =
        event->Identity.formReactEventToString->ApplePayIntegrationUtils.paymentProcessingMapper
      setProcessingAt(_ => value)
      if value === #Connector {
        form.change(
          `${ApplePayIntegrationUtils.applePayNameMapper(
              ~name="payment_processing_certificate",
              ~integrationType=Some(#manual),
              ~connector,
            )}`,
          JSON.Encode.null,
        )
        form.change(
          `${ApplePayIntegrationUtils.applePayNameMapper(
              ~name="payment_processing_certificate_key",
              ~integrationType=Some(#manual),
              ~connector,
            )}`,
          JSON.Encode.null,
        )
      }
    }

    <>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-hyperswitch_black"
        field={CommonConnectorHelper.radioInput(
          ~field=applePayField,
          ~formName=`${ApplePayIntegrationUtils.applePayNameMapper(
              ~name=applePayField.name,
              ~integrationType=Some(#manual),
              ~connector,
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
                `${ApplePayIntegrationUtils.applePayNameMapper(
                    ~name="payment_processing_certificate",
                    ~integrationType=Some(#manual),
                    ~connector,
                  )}`
              },
              ~placeholder={`Enter Processing Certificate`},
              ~customInput=InputFields.textInput(),
              ~isRequired=true,
            )}
          />
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={FormRenderer.makeFieldInfo(
              ~label="Payment Processing Key",
              ~name={
                `${ApplePayIntegrationUtils.applePayNameMapper(
                    ~name="payment_processing_certificate_key",
                    ~integrationType=Some(#manual),
                    ~connector,
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
              ),
              ~isRequired=true,
            )}
          />
        </div>
      | _ => React.null
      }}
    </>
  }
}

module Initiative = {
  @react.component
  let make = (~applePayField, ~connector) => {
    open LogicUtils
    open ApplePayIntegrationUtils
    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let initalFormValue =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
      ->getDictfromDict("apple_pay_combined")
      ->manual(connector)

    let initalInitiative =
      initalFormValue.session_token_data.initiative
      ->Option.getOr((#ios: initiativeState :> string))
      ->initiativeMapper
    let (initiative, setInitiative) = React.useState(_ => initalInitiative)

    let onChangeItem = (event: ReactEvent.Form.t) => {
      let value = event->Identity.formReactEventToString->initiativeMapper
      setInitiative(_ => value)
      if value === #ios {
        form.change(
          `${ApplePayIntegrationUtils.applePayNameMapper(
              ~name="initiative_context",
              ~integrationType=Some(#manual),
              ~connector,
            )}`,
          JSON.Encode.null,
        )
      }
    }
    let domainValues = [
      [("label", "IOS/WEB"->JSON.Encode.string), ("value", "web"->JSON.Encode.string)]
      ->Dict.fromArray
      ->JSON.Encode.object,
      [("label", "IOS"->JSON.Encode.string), ("value", "ios"->JSON.Encode.string)]
      ->Dict.fromArray
      ->JSON.Encode.object,
    ]
    let initiativeOptions = domainValues->Array.map(item => {
      let dict = item->getDictFromJsonObject
      let a: SelectBox.dropdownOption = {
        label: dict->getString("label", ""),
        value: dict->getString("value", ""),
      }
      a
    })
    <>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-hyperswitch_black"
        field={CommonConnectorHelper.selectInput(
          ~field={applePayField},
          ~formName={
            ApplePayIntegrationUtils.applePayNameMapper(
              ~name="initiative",
              ~integrationType=Some(#manual),
              ~connector,
            )
          },
          ~onItemChange=onChangeItem,
          ~opt=Some(initiativeOptions),
        )}
      />
      {switch initiative {
      | #web =>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={CommonConnectorHelper.textInput(
            ~field={applePayField},
            ~formName={
              ApplePayIntegrationUtils.applePayNameMapper(
                ~name="initiative_context",
                ~integrationType=Some(#manual),
                ~connector,
              )
            },
          )}
        />
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
  ~connector,
  ~appleIntegrationType,
) => {
  open LogicUtils
  open ApplePayIntegrationUtils
  open ApplePayIntegrationHelper
  open Typography

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
    let value = applePayCombined(initalFormValue, #manual, connector)
    form.change("metadata.apple_pay_combined", value->Identity.genericTypeToJson)
  }

  React.useEffect(() => {
    setFormData()
    None
  }, [])

  let onSubmit = () => {
    let data =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
      ->getDictfromDict("apple_pay_combined")
      ->manual(connector)

    let domainName = data.session_token_data.initiative_context->Option.getOr("")
    setVefifiedDomainList(_ => [domainName])
    setApplePayIntegrationSteps(_ => ApplePayIntegrationTypes.Verify)
    Nullable.null->Promise.resolve
  }
  let applePayManualFields =
    applePayFields
    ->Array.mapWithIndex((field, index) => {
      let applePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      let {name} = applePayField
      <div key={index->Int.toString}>
        {switch name {
        | "payment_processing_details_at" => <PaymentProcessingDetailsAt applePayField connector />
        | "initiative" => <Initiative applePayField connector />
        | "initiative_context" => React.null
        | "merchant_business_country" =>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={CommonConnectorHelper.selectInput(
              ~field={applePayField},
              ~opt={Some(merchantBusinessCountry)},
              ~formName={
                ApplePayIntegrationUtils.applePayNameMapper(
                  ~name="merchant_business_country",
                  ~integrationType=Some(#manual),
                  ~connector,
                )
              },
            )}
          />
        | _ =>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={applePayValueInput(~applePayField, ~integrationType=Some(#manual), ~connector)}
          />
        }}
      </div>
    })
    ->React.array
  <div className="flex flex-col gap-4 p-4 ">
    <div className="flex gap-2 px-2">
      <Icon
        size=16
        name="nd-arrow-left"
        className={"cursor-pointer"}
        onClick={_ => {
          setApplePayIntegrationSteps(_ => Landing)
        }}
      />
      <span className={body.lg.semibold}>
        {appleIntegrationType->getHeadingBasedOnApplePayFlow->React.string}
      </span>
    </div>
    <div> {applePayManualFields} </div>
    <div className="w-full flex gap-2 justify-end">
      <Button
        text="Go Back"
        buttonType={Secondary}
        onClick={_ => {
          setApplePayIntegrationSteps(_ => Landing)
        }}
        customButtonStyle="w-full"
      />
      <Button
        text="Verify & Enable"
        buttonType={Primary}
        onClick={_ => {
          onSubmit()->ignore
        }}
        customButtonStyle="w-full"
        buttonState={formState.values->validateManualFlow(~connector)}
      />
    </div>
  </div>
}
