open ApplePayIntegrationTypesV2

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
  ~integrationType: option<applePayIntegrationType>=None,
  ~merchantBusinessCountry: array<SelectBox.dropdownOption>=[],
  (),
) => {
  open ApplePayIntegrationHelperV2
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

module Verified = {
  @react.component
  let make = (
    ~verifiedDomainList,
    ~changeIntegrationType,
    ~appleIntegrationType,
    ~setApplePayIntegrationSteps,
    ~setShowWalletConfigurationModal,
  ) => {
    open ApplePayIntegrationHelperV2
    open ApplePayIntegrationTypesV2
    <>
      <div className="p-6 m-2 cursor-pointer">
        <p className="text-xs	font-medium	mt-4"> {" Web Domains"->React.string} </p>
        {verifiedDomainList
        ->Array.mapWithIndex((domainUrl, index) => {
          <div
            key={Int.toString(index)}
            className="mt-4 cursor-pointer"
            onClick={_e => changeIntegrationType(Some(#manual))}>
            <div className={`relative w-full  p-6 rounded flex flex-col justify-between border `}>
              <div className="flex justify-between">
                <div className={`font-medium text-base text-hyperswitch_black `}>
                  {domainUrl->React.string}
                </div>
                <div>
                  {switch appleIntegrationType {
                  | #simplified =>
                    <CustomTag
                      tagText="Verified"
                      tagSize=4
                      tagLeftIcon=Some("ellipse-green")
                      tagCustomStyle="bg-hyperswitch_green_trans"
                    />
                  | #manual =>
                    <Icon
                      onClick={_ev => setApplePayIntegrationSteps(_ => Configure)}
                      name={"arrow-right"}
                      size={15}
                    />
                  }}
                </div>
              </div>
            </div>
          </div>
        })
        ->React.array}
        <div className={`flex gap-2 justify-end mt-4`}>
          <Button
            text="Reconfigure"
            buttonType={Secondary}
            onClick={_ev => {
              setApplePayIntegrationSteps(_ => Landing)
            }}
          />
          <Button
            onClick={_ev => {
              setShowWalletConfigurationModal(_ => false)
            }}
            text="Proceed"
            buttonType={Primary}
          />
        </div>
      </div>
    </>
  }
}

module Landing = {
  @react.component
  let make = (
    ~connector,
    ~changeIntegrationType,
    ~appleIntegrationType,
    ~setShowWalletConfigurationModal,
    ~setApplePayIntegrationSteps,
  ) => {
    open WalletHelper
    <>
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
      | Processors(STRIPE)
      | Processors(BANKOFAMERICA)
      | Processors(CYBERSOURCE)
      | Processors(ADYEN) =>
        <div
          className="p-6 m-2 cursor-pointer"
          onClick={_e => changeIntegrationType(Some(#simplified))}>
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
      <div className="p-6 m-2 cursor-pointer" onClick={_e => changeIntegrationType(Some(#manual))}>
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
            changeIntegrationType(None)
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
  let make = (
    ~applePayFields,
    ~appleIntegrationType: option<applePayIntegrationType>,
    ~merchantBusinessCountry,
    ~setApplePayIntegrationSteps,
    ~setVefifiedDomainList,
    ~update,
  ) => {
    open LogicUtils
    open ApplePayIntegrationUtilsV2
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let onSubmit = () => {
      form.change("metadata.apple_pay_combined.simplified", JSON.Encode.null)
      let data =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getDictfromDict("apple_pay_combined")
        ->manual
      let domainName = data.session_token_data.initiative_context->Option.getOr("")

      let metadata =
        formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object

      setVefifiedDomainList(_ => [domainName])
      let _ = update(metadata)
      setApplePayIntegrationSteps(_ => ApplePayIntegrationTypesV2.Verify)
      Nullable.null->Promise.resolve
    }
    let applePayManualFields =
      applePayFields
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
                ~integrationType=appleIntegrationType,
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
}
module ZenApplePay = {
  @react.component
  let make = (
    ~applePayFields,
    ~update,
    ~setShowWalletConfigurationModal,
    ~onCloseClickCustomFun,
  ) => {
    open LogicUtils
    open ApplePayIntegrationUtilsV2
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let onSubmit = () => {
      let metadata =
        formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
      let _ = update(metadata)
      onCloseClickCustomFun()
      Nullable.null->Promise.resolve
    }
    let applePayManualFields =
      applePayFields
      ->Array.mapWithIndex((field, index) => {
        let applePayField = field->convertMapObjectToDict->CommonWalletUtils.inputFieldMapper
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
            setShowWalletConfigurationModal(_ => false)
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
}
module Simplified = {
  @react.component
  let make = (
    ~applePayFields,
    ~appleIntegrationType,
    ~merchantBusinessCountry,
    ~setApplePayIntegrationSteps,
    ~setVefifiedDomainList,
    ~update,
  ) => {
    open LogicUtils
    open APIUtils
    open ApplePayIntegrationHelperV2
    open ApplePayIntegrationUtilsV2
    let getURL = useGetURL()
    let updateAPIHook = useUpdateMethod(~showErrorToast=false, ())
    let fetchApi = AuthHooks.useApiFetcher()
    let showToast = ToastState.useShowToast()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let url = RescriptReactRouter.useUrl()
    let form = ReactFinalForm.useForm()
    let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
    let merchantDetailsValue = HSwitchUtils.useMerchantDetailsValue()
    let merchantId = merchantDetailsValue.merchant_id
    let onSubmit = async () => {
      try {
        let (body, domainName) = formState.values->constructVerifyApplePayReq(connectorID)
        let verifyAppleUrl = getURL(~entityName=VERIFY_APPLE_PAY, ~methodType=Post, ())
        // let _ = await updateAPIHook(`${verifyAppleUrl}/${merchantId}`, body, Post, ())

        form.change("metadata.apple_pay_combined.manual", JSON.Encode.null)
        let data =
          formState.values
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getDictfromDict("apple_pay_combined")
          ->simplified
        let domainName = data.session_token_data.initiative_context->Option.getOr("")

        let metadata =
          formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object

        let _ = update(metadata)
        setVefifiedDomainList(_ => [domainName])
        setApplePayIntegrationSteps(_ => ApplePayIntegrationTypesV2.Verify)
      } catch {
      | _ => showToast(~message="Failed to Verify", ~toastType=ToastState.ToastError, ())
      }
      Nullable.null
    }

    let downloadApplePayCert = () => {
      open Promise
      fetchApi(HSwitchGlobalVars.urlToDownloadApplePayCertificate, ~method_=Get, ())
      ->then(Fetch.Response.blob)
      ->then(content => {
        DownloadUtils.download(
          ~fileName=`apple-developer-merchantid-domain-association`,
          ~content,
          ~fileType="text/plain",
        )
        showToast(~toastType=ToastSuccess, ~message="File download complete", ())

        resolve()
      })
      ->catch(_ => {
        showToast(
          ~toastType=ToastError,
          ~message="Oops, something went wrong with the download. Please try again.",
          (),
        )
        resolve()
      })
      ->ignore
    }

    let downloadAPIKey =
      <div className="mt-4">
        <Button
          text={"Download File"}
          buttonType={Primary}
          buttonSize={Small}
          customButtonStyle="!px-2 rounded-lg"
          onClick={_ => downloadApplePayCert()}
          buttonState={Normal}
        />
      </div>

    let applePaySimplifiedFields =
      applePayFields
      ->Array.filter(field => {
        let typedData = field->convertMapObjectToDict->CommonWalletUtils.inputFieldMapper
        !(ignoreFieldsonSimplified->Array.includes(typedData.name))
      })
      ->Array.mapWithIndex((field, index) => {
        let applePayField = field->convertMapObjectToDict->CommonWalletUtils.inputFieldMapper
        <div key={index->Int.toString}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={applePayValueInput(
              ~applePayField,
              ~merchantBusinessCountry,
              ~integrationType={appleIntegrationType},
              (),
            )}
          />
        </div>
      })
      ->React.array
    <>
      <SimplifiedHelper
        customElement={Some(applePaySimplifiedFields)}
        heading="Provide your sandbox domain where the verification file will be hosted"
        subText=Some(
          "Input the top-level domain (example.com) or sub-domain (checkout.example.com) where you wish to enable Apple Pay",
        )
        stepNumber="1"
      />
      <hr className="w-full" />
      <SimplifiedHelper
        heading="Download domain verification file"
        stepNumber="2"
        customElement=Some(downloadAPIKey)
      />
      <hr className="w-full" />
      <SimplifiedHelper
        heading="Host sandbox domain association file"
        subText=Some(
          "Host the downloaded verification file at your sandbox domain in the following location :-",
        )
        stepNumber="3"
        customElement=Some(
          <HostURL
            prefix={`${ApplePayIntegrationUtilsV2.applePayNameMapper(
                ~name="initiative_context",
                ~integrationType=Some(#simplified),
              )}`}
          />,
        )
      />
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
          buttonState={formState.values->validateSimplifedFlow}
        />
      </div>
    </>
  }
}

@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~onCloseClickCustomFun, ~update) => {
  open LogicUtils
  open ApplePayIntegrationUtilsV2
  open WalletHelper
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()
  let (appleIntegrationType, setApplePayIntegrationType) = React.useState(_ => #manual)
  let (applePayIntegrationStep, setApplePayIntegrationSteps) = React.useState(_ => Landing)
  let (merchantBusinessCountry, setMerchantBusinessCountry) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (verifiedDomainList, setVefifiedDomainList) = React.useState(_ => [])
  let initalFormValue =
    formState.values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay_combined")
  let (initalData, _setInitalData) = React.useState(_ => initalFormValue)
  let applePayFields = React.useMemo1(() => {
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

  let setFormData = (~applePayIntegrationType=None, ()) => {
    open ConnectorUtils
    open ConnectorTypes

    let value = switch connector->getConnectorNameTypeFromString() {
    | Processors(ZEN) => applePay(initalData, connector, ())
    | _ => applePay(initalData, connector, ~applePayIntegrationType, ())
    }
    Js.log(value)
    switch value {
    | Zen(data) => form.change("metadata.apple_pay", data->Identity.genericTypeToJson)
    | ApplePayCombined(data) => form.change("metadata", data->Identity.genericTypeToJson)
    }
  }

  let changeIntegrationType = intType => {
    let integrationType =
      intType->Option.isNone
        ? Some(
            initalData
            ->Dict.keysToArray
            ->Array.at(0)
            ->Option.getOr((#manual: applePayIntegrationType :> string))
            ->applePayIntegrationTypeMapper,
          )
        : intType
    let _ = setFormData(~applePayIntegrationType=integrationType, ())
    let _ = setApplePayIntegrationType(_ => integrationType->Option.getOr(#manual))
  }

  React.useEffect1(() => {
    if connector->String.length > 0 {
      {
        let applePayIntegrationType = Some(
          initalData
          ->Dict.keysToArray
          ->Array.at(0)
          ->Option.getOr((#manual: applePayIntegrationType :> string))
          ->applePayIntegrationTypeMapper,
        )
        setFormData(~applePayIntegrationType, ())
        switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
        | Processors(STRIPE)
        | Processors(BANKOFAMERICA)
        | Processors(CYBERSOURCE)
        | Processors(ADYEN) =>
          setApplePayIntegrationType(_ => #simplified)
        | _ => setApplePayIntegrationType(_ => #manual)
        }
      }

      getProcessorDetails()->ignore
    }
    None
  }, [connector])

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
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
      | Processors(ZEN) =>
        <ZenApplePay applePayFields update setShowWalletConfigurationModal onCloseClickCustomFun />
      | _ =>
        switch applePayIntegrationStep {
        | Landing =>
          <Landing
            connector
            changeIntegrationType
            setShowWalletConfigurationModal
            setApplePayIntegrationSteps
            appleIntegrationType
          />
        | Configure =>
          switch appleIntegrationType {
          | #simplified =>
            <Simplified
              applePayFields
              merchantBusinessCountry
              setApplePayIntegrationSteps
              setVefifiedDomainList
              update
              appleIntegrationType=Some(appleIntegrationType)
            />
          | #manual =>
            <Manual
              applePayFields
              merchantBusinessCountry
              setApplePayIntegrationSteps
              setVefifiedDomainList
              update
              appleIntegrationType=Some(appleIntegrationType)
            />
          }
        | Verify =>
          <Verified
            verifiedDomainList
            changeIntegrationType
            setShowWalletConfigurationModal
            setApplePayIntegrationSteps
            appleIntegrationType
          />
        }
      }}
    </div>
  </PageLoaderWrapper>
}
