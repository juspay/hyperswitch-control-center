open ApplePayIntegrationTypesV2
let textInput = (
  ~applePayField: CommonWalletTypes.inputField,
  ~integrationType: applePayIntegrationType,
) => {
  let {placeholder, label, name, required} = applePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~name=`${ApplePayIntegrationUtilsV2.applePayNameMapper(~name, ~integrationType)}`,
    ~placeholder,
    ~customInput=InputFields.textInput(),
    ~isRequired=required,
    (),
  )
}

let selectStringInput = (
  ~applePayField: CommonWalletTypes.inputField,
  ~options,
  ~integrationType: applePayIntegrationType,
) => {
  let {label, name, required} = applePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name=`${ApplePayIntegrationUtilsV2.applePayNameMapper(~name, ~integrationType)}`,
    ~customInput=(~input) =>
      InputFields.selectInput(
        ~input={
          ...input,
          onChange: event => {
            let value = event->Identity.formReactEventToString
            input.onChange(value->Identity.anyTypeToReactEvent)
          },
        },
        ~options={options},
        ~buttonText="Select Value",
        (),
      ),
    (),
  )
}

let selectArrayInput = (
  ~applePayField: CommonWalletTypes.inputField,
  ~integrationType: applePayIntegrationType,
) => {
  let {label, name, required, options} = applePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name=`${ApplePayIntegrationUtilsV2.applePayNameMapper(~name, ~integrationType)}`,
    ~customInput=InputFields.selectInput(
      ~deselectDisable=true,
      ~fullLength=true,
      ~customStyle="max-h-48",
      ~customButtonStyle="pr-3",
      ~options={options->SelectBox.makeOptions},
      ~buttonText="Select Value",
      (),
    ),
    (),
  )
}

let paymentProcessingAtField = (
  ~name,
  ~label,
  ~options,
  ~setProcessingAt,
  ~form: ReactFinalForm.formApi,
  ~textColor,
  ~integrationType,
) => {
  FormRenderer.makeFieldInfo(
    ~name,
    ~label,
    ~customInput=(~input) =>
      InputFields.radioInput(
        ~input={
          ...input,
          onChange: event => {
            let value =
              event
              ->Identity.formReactEventToString
              ->ApplePayIntegrationUtilsV2.paymentProcessingMapper
            setProcessingAt(_ => value)
            if value === #Connector {
              form.change(
                `${ApplePayIntegrationUtilsV2.applePayNameMapper(
                    ~name="payment_processing_certificate",
                    ~integrationType,
                  )}`,
                JSON.Encode.null,
              )
              form.change(
                `${ApplePayIntegrationUtilsV2.applePayNameMapper(
                    ~name="payment_processing_certificate_key",
                    ~integrationType,
                  )}`,
                JSON.Encode.null,
              )
            }
            input.onChange(event)
          },
        },
        ~options=options->SelectBox.makeOptions,
        ~buttonText="",
        ~isHorizontal=true,
        ~customStyle="cursor-pointer gap-2",
        ~fill={`${textColor}`},
        (),
      ),
    (),
  )
}

module PaymentProcessingDetailsAt = {
  @react.component
  let make = (~integrationType) => {
    let form = ReactFinalForm.useForm()
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let (processingAt, setProcessingAt) = React.useState(_ => #Connector)
    <>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-hyperswitch_black"
        field={paymentProcessingAtField(
          ~name=`${ApplePayIntegrationUtilsV2.applePayNameMapper(
              ~name="payment_processing_details_at",
              ~integrationType,
            )}`,
          ~label="Processing At",
          ~options=[
            (#Connector: paymentProcessingState :> string),
            (#Hyperswitch: paymentProcessingState :> string),
          ],
          ~textColor={textColor.primaryNormal},
          ~setProcessingAt,
          ~form,
          ~integrationType,
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
                    ~integrationType,
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
                    ~integrationType,
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

let applePayValueInput = (
  ~applePayField: CommonWalletTypes.inputField,
  ~integrationType: applePayIntegrationType,
  ~merchantBusinessCountry,
) => {
  let {\"type", name} = applePayField

  {
    switch (\"type", name) {
    | (Text, _) => textInput(~applePayField, ~integrationType)
    | (Select, "merchant_business_country") =>
      selectStringInput(~applePayField, ~options={merchantBusinessCountry}, ~integrationType)
    | (Select, _) => selectArrayInput(~applePayField, ~integrationType)
    | _ => textInput(~applePayField, ~integrationType)
    }
  }
}

module Landing = {
  open WalletHelper
  @react.component
  let make = (
    ~connector,
    ~setApplePayIntegrationType,
    ~appleIntegrationType,
    ~setShowWalletConfigurationModal,
    ~setApplePayIntegrationSteps,
  ) => {
    <>
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
      | Processors(STRIPE) | Processors(BANKOFAMERICA) | Processors(CYBERSOURCE) =>
        <div
          className="p-6 m-2 cursor-pointer"
          onClick={_e => setApplePayIntegrationType(_ => #simplified)}>
          <Card heading="Web Domain" isSelected={appleIntegrationType === #simplified}>
            <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
              {"Get Apple Pay enabled on your web domains by hosting a verification file, that’s it."->React.string}
            </div>
            <div className="flex gap-2 mt-4">
              <CustomTag
                tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green")
              />
              <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            </div>
          </Card>
        </div>
      | _ => React.null
      }}
      <div
        className="p-6 m-2 cursor-pointer" onClick={_e => setApplePayIntegrationType(_ => #manual)}>
        <Card heading="iOS Certificate" isSelected={appleIntegrationType === #manual}>
          <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
            <CustomSubText />
          </div>
          <div className="flex gap-2 mt-4">
            <CustomTag tagText="For Web & Mobile" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            <CustomTag
              tagText="Additional Details Required" tagSize=4 tagLeftIcon=Some("ellipse-green")
            />
          </div>
        </Card>
      </div>
      <div className={`flex gap-2 justify-end m-2 p-6`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ev => {
            setShowWalletConfigurationModal(_ => false)
          }}
        />
        <Button
          onClick={_ev => setApplePayIntegrationSteps(_ => Configure)}
          text="Continue"
          buttonType={Primary}
        />
      </div>
    </>
  }
}

module Manual = {
  @react.component
  let make = (~applePayFileds, ~appleIntegrationType, ~merchantBusinessCountry) => {
    open LogicUtils
    applePayFileds
    ->Array.mapWithIndex((field, index) => {
      let applePayField = field->convertMapObjectToDict->CommonWalletUtils.inputFieldMapper
      let {name} = applePayField
      <div key={index->Int.toString}>
        {switch name {
        | "payment_processing_details_at" =>
          <PaymentProcessingDetailsAt integrationType={appleIntegrationType} />
        | _ =>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={applePayValueInput(
              ~applePayField,
              ~merchantBusinessCountry,
              ~integrationType={appleIntegrationType},
            )}
          />
        }}
      </div>
    })
    ->React.array
  }
}

@react.component
let make = (~connector, ~setShowWalletConfigurationModal) => {
  open LogicUtils
  open ApplePayIntegrationTypesV2
  open ApplePayIntegrationUtilsV2
  open WalletHelper
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (appleIntegrationType, setApplePayIntegrationType) = React.useState(_ => #manual)
  let (applePayIntegrationStep, setApplePayIntegrationSteps) = React.useState(_ => Landing)
  let (merchantBusinessCountry, setMerchantBusinessCountry) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let applePayFileds = React.useMemo1(() => {
    try {
      if connector->isNonEmptyString {
        let dict =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getArrayFromDict("apple_pay_v2", [])

        dict
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

  let getProcessorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let paymentMethoConfigUrl = getURL(~entityName=PAYMENT_METHOD_CONFIG, ~methodType=Get, ())
      let res = await fetchDetails(
        `${paymentMethoConfigUrl}?connector=${connector}&paymentMethodType=apple_pay`,
      )
      let countries =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("countries", [])
        ->Array.map(item => {
          let dict = item->getDictFromJsonObject
          let a: SelectBox.dropdownOption = {
            label: dict->getString("name", ""),
            value: dict->getString("code", ""),
          }
          a
        })

      setMerchantBusinessCountry(_ => countries)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Success)
    }
  }

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()

  React.useEffect1(() => {
    // Need to refactor
    if connector->String.length > 0 {
      {
        switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
        | Processors(STRIPE)
        | Processors(BANKOFAMERICA)
        | Processors(CYBERSOURCE) =>
          setApplePayIntegrationType(_ => #simplified)
        | _ => setApplePayIntegrationType(_ => #manual)
        }
      }

      getProcessorDetails()->ignore
    }
    None
  }, [connector])

  React.useEffect2(() => {
    if connector->isNonEmptyString {
      let initialGooglePayDict =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getDictfromDict("apple_pay")
      let value = applePay(initialGooglePayDict, appleIntegrationType)
      Js.log2(value, "value")
      form.change("metadata.apple_pay", value->Identity.genericTypeToJson)
    }
    None
  }, (connector, appleIntegrationType))
  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className={`animate-spin mb-1`}>
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    <div>
      <Heading />
      {switch applePayIntegrationStep {
      | Landing =>
        <Landing
          connector
          setApplePayIntegrationType
          setShowWalletConfigurationModal
          setApplePayIntegrationSteps
          appleIntegrationType
        />
      | Configure =>
        switch appleIntegrationType {
        // | #simplified =>
        //   <Simplified
        //     metadataInputs
        //     metaData
        //     update
        //     setApplePayIntegrationSteps
        //     setVefifiedDomainList
        //     merchantBusinessCountry
        //   />
        | #manual => <Manual applePayFileds appleIntegrationType merchantBusinessCountry />
        }
      }}
    </div>
  </PageLoaderWrapper>
}
