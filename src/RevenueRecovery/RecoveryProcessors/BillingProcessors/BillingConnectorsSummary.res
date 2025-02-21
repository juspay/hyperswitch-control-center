type connectorSummarySection = AuthenticationKeys | Metadata | PMTs
@react.component
let make = () => {
  open ConnectorUtils
  open LogicUtils
  open APIUtils
  open PageLoaderWrapper
  let (currentActiveSection, setCurrentActiveSection) = React.useState(_ => None)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)

  let url = RescriptReactRouter.useUrl()
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")

  let removeFieldsFromRespose = json => {
    let dict = json->getDictFromJsonObject
    dict->Dict.delete("applepay_verified_domains")
    dict->Dict.delete("business_country")
    dict->Dict.delete("business_label")
    dict->Dict.delete("business_sub_label")
    dict->JSON.Encode.object
  }

  let getConnectorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID))
      //let json = await fetchDetails(connectorUrl)
      let json = {
        "connector_type": "payment_processor",
        "connector_name": "adyen",
        "connector_account_details": {
          "auth_type": "SignatureKey",
          "api_key": "asdfa",
          "api_secret": "asdfasd",
          "key1": "asdfasdf",
        },
        "metadata": {
          "status_url": "https://2753-2401-4900-1cb8-2ff9-24dd-1ccf-ed12-b464.in.ngrok.io/webhooks/merchant_1678699058/globalpay",
          "account_name": "transaction_processing",
          "pricing_type": "fixed_price",
          "acquirer_bin": "438309",
          "acquirer_merchant_id": "00002000000",
        },
        "connector_webhook_details": {
          "merchant_secret": "",
        },
        "feature_metadata": {
          "revenue_recovery": {
            "max_retry_count": 27,
            "billing_connector_retry_threshold": 16,
            "billing_account_reference": {
              "mca_stripe_123": "charge_123",
              "mca_adyen_123": "charge_124",
            },
          },
        },
        "profile_id": "pro_k8oS0c6doIkX0XXVMQOq",
      }->Identity.genericTypeToJson
      setInitialValues(_ => json->removeFieldsFromRespose)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch details"))
    }
  }

  React.useEffect(() => {
    getConnectorDetails()->ignore
    None
  }, [])

  let handleClick = (section: option<connectorSummarySection>) => {
    if section->Option.isNone {
      setInitialValues(_ => JSON.stringify(initialValues)->safeParse)
    }
    setCurrentActiveSection(_ => section)
  }

  let checkCurrentEditState = (section: connectorSummarySection) => {
    switch currentActiveSection {
    | Some(active) => active == section
    | _ => false
    }
  }

  let connectorInfodict =
    initialValues->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let {connector_name: connectorName} = connectorInfodict

  let connectorDetails = React.useMemo(() => {
    try {
      let (processorType, _) =
        connectorInfodict.connector_type
        ->connectorTypeTypedValueToStringMapper
        ->connectorTypeTuple
      if connectorName->LogicUtils.isNonEmptyString {
        let dict = switch processorType {
        | PaymentProcessor => Window.getConnectorConfig(connectorName)
        | PayoutProcessor => Window.getPayoutConnectorConfig(connectorName)
        | AuthenticationProcessor => Window.getAuthenticationConnectorConfig(connectorName)
        | PMAuthProcessor => Window.getPMAuthenticationProcessorConfig(connectorName)
        | TaxProcessor => Window.getTaxProcessorConfig(connectorName)
        | BillingProcessor => BillingProcessorsUtils.getConnectorConfig(connectorName)
        | PaymentVas => JSON.Encode.null
        }
        dict
      } else {
        JSON.Encode.null
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let _ = Exn.message(e)->Option.getOr("Something went wrong")
        JSON.Encode.null
      }
    }
  }, [connectorInfodict.merchant_connector_id])

  let (
    _,
    connectorAccountFields,
    connectorMetaDataFields,
    _,
    connectorWebHookDetails,
    connectorLabelDetailField,
    _,
  ) = getConnectorFields(connectorDetails)

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=Some(connectorID))
      let dict = values->getDictFromJsonObject
      switch currentActiveSection {
      | Some(AuthenticationKeys) => {
          dict->Dict.delete("profile_id")
          dict->Dict.delete("merchant_connector_id")
          dict->Dict.delete("connector_name")
        }
      | _ => {
          dict->Dict.delete("profile_id")
          dict->Dict.delete("merchant_connector_id")
          dict->Dict.delete("connector_name")
          dict->Dict.delete("connector_account_details")
        }
      }
      let response = await updateAPIHook(connectorUrl, dict->JSON.Encode.object, Post)
      setCurrentActiveSection(_ => None)
      setInitialValues(_ => response->removeFieldsFromRespose)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to update"))
    }
    Nullable.null
  }

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
    let profileId = valuesFlattenJson->getString("profile_id", "")
    if profileId->String.length === 0 {
      Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
    }
    let connectorTypeFromName = connectorName->getConnectorNameTypeFromString

    validateConnectorRequiredFields(
      connectorTypeFromName,
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  Js.log2(">>", connectorInfodict)

  let revenueRecovery =
    connectorInfodict.revenue_recovery
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
  let max_retry_count = revenueRecovery->getInt("max_retry_count", 0)
  let billing_connector_retry_threshold =
    revenueRecovery->getInt("billing_connector_retry_threshold", 0)
  let paymentConnectors =
    revenueRecovery->getObj("billing_account_reference", Dict.make())->Dict.toArray

  <PageLoaderWrapper screenState>
    <Form onSubmit initialValues validate=validateMandatoryField>
      <div className="flex flex-col gap-10 p-6">
        <div>
          <div className="flex flex-row gap-4 items-center">
            <GatewayIcon
              gateway={"chargebee"->String.toUpperCase} className=" w-10 h-10 rounded-sm"
            />
            <p className={`text-2xl font-semibold break-all`}>
              {`Chargebee Summary`->React.string}
            </p>
          </div>
        </div>
        <div className="flex flex-col gap-12">
          <div className="flex gap-10 max-w-3xl flex-wrap px-2">
            <ConnectorWebhookPreview
              merchantId connectorName=connectorInfodict.merchant_connector_id
            />
            <div className="flex flex-col gap-0.5-rem ">
              <h4 className="text-nd_gray-400 "> {"Profile"->React.string} </h4>
              {connectorInfodict.profile_id->React.string}
            </div>
            <div className="flex flex-col gap-0.5-rem ">
              <h4 className="text-nd_gray-400 "> {"Processor status"->React.string} </h4>
              <div className="flex flex-row gap-2 items-center ">
                <ConnectorHelperV2.ProcessorStatus connectorInfo=connectorInfodict />
              </div>
            </div>
          </div>
          <div className="flex gap-10 max-w-3xl flex-wrap px-2">
            <div className="flex flex-col gap-0.5-rem ">
              <h4 className="text-nd_gray-400 "> {"Connector_retry_threshold"->React.string} </h4>
              {billing_connector_retry_threshold->Int.toString->React.string}
            </div>
            <div className="flex flex-col gap-0.5-rem ">
              <h4 className="text-nd_gray-400 "> {"Max Retry Count"->React.string} </h4>
              {max_retry_count->Int.toString->React.string}
            </div>
          </div>
          <div className="flex flex-col gap-4">
            <div className="flex justify-between border-b pb-4 px-2 items-end">
              <p className="text-lg font-semibold text-nd_gray-600">
                {"Payment Connectors"->React.string}
              </p>
            </div>
            <div className="flex gap-10 max-w-3xl flex-wrap px-2">
              {paymentConnectors
              ->Array.map(item => {
                let (key, value) = item
                <div>
                  <h4 className="text-nd_gray-400 "> {key->React.string} </h4>
                  <div> {value->JSON.Decode.string->Option.getOr("")->React.string} </div>
                </div>
              })
              ->React.array}
            </div>
          </div>
          <div className="flex flex-col gap-4">
            <div className="flex justify-between border-b pb-4 px-2 items-end">
              <p className="text-lg font-semibold text-nd_gray-600">
                {"Authentication keys"->React.string}
              </p>
              <div className="flex gap-4">
                {if checkCurrentEditState(AuthenticationKeys) {
                  <>
                    <Button
                      text="Cancel"
                      onClick={_ => handleClick(None)}
                      buttonType={Secondary}
                      buttonSize={Small}
                      customButtonStyle="w-fit"
                    />
                    <FormRenderer.SubmitButton
                      text="Save" buttonSize={Small} customSumbitButtonStyle="w-fit"
                    />
                  </>
                } else {
                  <div
                    className="flex gap-2 items-center cursor-pointer"
                    onClick={_ => handleClick(Some(AuthenticationKeys))}>
                    <Icon name="nd-edit" size=14 />
                    <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
                  </div>
                }}
              </div>
            </div>
            {if checkCurrentEditState(AuthenticationKeys) {
              <ConnectorAuthKeys initialValues showVertically=false />
            } else {
              <ConnectorHelperV2.PreviewCreds
                connectorInfo=connectorInfodict
                connectorAccountFields
                customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl "
                customElementStyle="px-2 "
              />
            }}
          </div>
          <div className="flex flex-col gap-4">
            <div className="flex justify-between border-b pb-4 px-2 items-end">
              <p className="text-lg font-semibold text-nd_gray-600"> {"Metadata"->React.string} </p>
              <div className="flex gap-4">
                {if checkCurrentEditState(Metadata) {
                  <>
                    <Button
                      text="Cancel"
                      onClick={_ => handleClick(None)}
                      buttonType={Secondary}
                      buttonSize={Small}
                      customButtonStyle="w-fit"
                    />
                    <FormRenderer.SubmitButton
                      text="Save" buttonSize={Small} customSumbitButtonStyle="w-fit"
                    />
                  </>
                } else {
                  <div
                    className="flex gap-2 items-center cursor-pointer"
                    onClick={_ => handleClick(Some(Metadata))}>
                    <Icon name="nd-edit" size=14 />
                    <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
                  </div>
                }}
              </div>
            </div>
            <div className="grid grid-cols-2 gap-10 flex-wrap max-w-3xl">
              <ConnectorLabelV2
                labelClass="font-normal"
                labelTextStyleClass="text-nd_gray-400"
                isInEditState={checkCurrentEditState(Metadata)}
                connectorInfo=connectorInfodict
              />
              <ConnectorMetadataV2
                labelTextStyleClass="text-nd_gray-400"
                labelClass="font-normal"
                isInEditState={checkCurrentEditState(Metadata)}
                connectorInfo=connectorInfodict
              />
              <ConnectorWebhookDetails
                labelTextStyleClass="text-nd_gray-400"
                labelClass="font-normal"
                isInEditState={checkCurrentEditState(Metadata)}
                connectorInfo=connectorInfodict
              />
            </div>
          </div>
        </div>
      </div>
      <FormValuesSpy />
    </Form>
  </PageLoaderWrapper>
}
