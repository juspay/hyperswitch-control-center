/* Lists every payment processor registered against the billing connector's
   billing_account_reference and lets another one be connected. Creating the
   processor is not enough on its own: the new merchant connector account id has
   to be registered in billing_account_reference, otherwise recovery never
   retries through it. */
type sectionMode = ListProcessors | SelectProcessor | AuthenticateProcessor

@react.component
let make = (~billingConnectorId, ~billingConnectorName, ~merchantId) => {
  open APIUtils
  open LogicUtils
  open ConnectorUtils
  open PageLoaderWrapper
  open Typography

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=V2,
  )
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let (
    mitSupportedConnectors,
    isMitConnectorListLoading,
  ) = RevenueRecoveryHooks.useMitSupportedConnectors()

  /* ConnectorAuthKeys and friends read the connector from the url's name param,
   so selecting a card has to put it there for their fields to render */
  let setSelectedConnectorInUrl = connectorName => {
    let url =
      connectorName->isNonEmptyString
        ? `/v2/recovery/summary?name=${connectorName}`
        : `/v2/recovery/summary`
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))
  }

  let (mode, setMode) = React.useState(_ => ListProcessors)
  let (screenState, setScreenState) = React.useState(_ => Success)
  let (connector, setConnector) = React.useState(_ => "")
  let (billingAccountReference, setBillingAccountReference) = React.useState(_ => Dict.make())
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let activeBusinessProfile = getNameForId(#Profile)
  let paymentConnectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PaymentProcessor,
  )

  /* custom billing keys the reference by the connector id itself, every other
   biller expects the customer id configured in their platform */
  let isCustomBilling =
    billingConnectorName->getConnectorNameTypeFromString(~connectorType=BillingProcessor) ==
      BillingProcessor(CUSTOMBILLING)

  let fetchBillingAccountReference = async () => {
    try {
      setScreenState(_ => Loading)
      let url = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Get, ~id=Some(billingConnectorId))
      let response = await fetchDetails(url, ~version=V2)
      let reference =
        response
        ->getDictFromJsonObject
        ->getDictfromDict("feature_metadata")
        ->getDictfromDict("revenue_recovery")
        ->getObj("billing_account_reference", Dict.make())
      setBillingAccountReference(_ => reference)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch payment processors"))
    }
  }

  React.useEffect(() => {
    if billingConnectorId->isNonEmptyString {
      fetchBillingAccountReference()->ignore
    }
    None
  }, [billingConnectorId])

  let registeredProcessorIds = billingAccountReference->Dict.keysToArray

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        Window.getConnectorConfig(connector)
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(_) => Dict.make()->JSON.Encode.object
    }
  }, [connector])

  let updatedInitialVal = React.useMemo(() => {
    let valuesDict = initialValues->getDictFromJsonObject
    valuesDict->Dict.set("connector_name", connector->JSON.Encode.string)
    valuesDict->Dict.set(
      "connector_label",
      `${connector}_${activeBusinessProfile}`->JSON.Encode.string,
    )
    valuesDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    valuesDict->Dict.set("profile_id", profileId->JSON.Encode.string)

    if !isLiveMode {
      RevenueRecoveryData.fillDummyData(~connector, ~initialValuesToDict=valuesDict, ~merchantId)
    }

    let keys =
      connectorDetails
      ->getDictFromJsonObject
      ->Dict.keysToArray
      ->Array.filter(val => Array.includes(["credit", "debit"], val))

    let pmtype = keys->Array.flatMap(key => {
      connectorDetails
      ->getDictFromJsonObject
      ->getArrayFromDict(key, [])
      ->Array.map(
        val =>
          val
          ->getDictFromJsonObject
          ->ConnectorPaymentMethodV2Utils.getPaymentMethodDictV2(key, connector),
      )
    })
    let pmSubTypeDict =
      [
        ("payment_method_type", "card"->JSON.Encode.string),
        ("payment_method_subtypes", pmtype->Identity.genericTypeToJson),
      ]->Dict.fromArray
    valuesDict->Dict.set(
      "payment_methods_enabled",
      Array.make(~length=1, pmSubTypeDict)->Identity.genericTypeToJson,
    )
    valuesDict->JSON.Encode.object
  }, [connector, profileId])

  let connectorInfoDict = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->getDictFromJsonObject,
  )

  let registerReference = async (~paymentConnectorId, ~reference) => {
    let url = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Get, ~id=Some(billingConnectorId))
    let billingConnector = await fetchDetails(url, ~version=V2)
    let billingDict = billingConnector->getDictFromJsonObject
    let featureMetadata = billingDict->getObj("feature_metadata", Dict.make())->Dict.copy
    let revenueRecovery = featureMetadata->getObj("revenue_recovery", Dict.make())->Dict.copy
    let updatedReference =
      revenueRecovery->getObj("billing_account_reference", Dict.make())->Dict.copy

    updatedReference->Dict.set(paymentConnectorId, reference->JSON.Encode.string)
    revenueRecovery->Dict.set("billing_account_reference", updatedReference->JSON.Encode.object)
    featureMetadata->Dict.set("revenue_recovery", revenueRecovery->JSON.Encode.object)

    let body = billingDict->Dict.copy
    body->Dict.set("feature_metadata", featureMetadata->JSON.Encode.object)
    body->Dict.set("merchant_id", merchantId->JSON.Encode.string)
    body->Dict.delete("profile_id")
    body->Dict.delete("id")
    body->Dict.delete("connector_name")
    body->Dict.delete("connector_account_details")

    let updateUrl = getURL(
      ~entityName=V2(V2_CONNECTOR),
      ~methodType=Put,
      ~id=Some(billingConnectorId),
    )
    let _ = await updateAPIHook(updateUrl, body->JSON.Encode.object, Put, ~version=V2)
    updatedReference
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let valuesDict = values->getDictFromJsonObject
      let enteredReference = valuesDict->getString("processor_reference_id", "")
      valuesDict->Dict.delete("processor_reference_id")

      let createUrl = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Put, ~id=None)
      let response = await updateAPIHook(
        createUrl,
        valuesDict->JSON.Encode.object,
        Post,
        ~version=V2,
      )
      let paymentConnectorId = response->getDictFromJsonObject->getString("id", "")

      let reference = isCustomBilling ? paymentConnectorId : enteredReference
      let updatedReference = await registerReference(~paymentConnectorId, ~reference)

      setBillingAccountReference(_ => updatedReference)
      fetchConnectorListResponse()->ignore
      setConnector(_ => "")
      setSelectedConnectorInUrl("")
      setInitialValues(_ => Dict.make()->JSON.Encode.object)
      setMode(_ => ListProcessors)
      showToast(~message="Payment processor added", ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to add payment processor")
        showToast(
          ~message=err->safeParse->getDictFromJsonObject->getString("message", err),
          ~toastType=ToastState.ToastError,
        )
        setScreenState(_ => Success)
      }
    }
    Nullable.null
  }

  let {
    connectorAccountFields,
    connectorMetaDataFields,
    connectorWebHookDetails,
    connectorLabelDetailField,
  } = getConnectorFields(connectorDetails)

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)

    if (
      !isCustomBilling && valuesFlattenJson->getString("processor_reference_id", "")->isEmptyString
    ) {
      errors->Dict.set(
        "processor_reference_id",
        "Please enter the processor reference id"->JSON.Encode.string,
      )
    }

    validateConnectorRequiredFields(
      connector->getConnectorNameTypeFromString,
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  let processorRow = paymentConnectorId => {
    let details =
      paymentConnectorList->Array.find((item: ConnectorTypes.connectorPayloadCommonType) =>
        item.id === paymentConnectorId
      )
    let connectorName = switch details {
    | Some(item) => item.connector_name
    | None => ""
    }
    let reference = billingAccountReference->getString(paymentConnectorId, "")

    <div
      key={paymentConnectorId}
      className="grid grid-cols-3 px-2 py-4 border-b items-center last:border-b-0">
      <div className="flex gap-3 items-center">
        <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-7 h-7 rounded-sm" />
        <p className={body.md.medium}>
          {(
            connectorName->isNonEmptyString
              ? connectorName->getDisplayNameForConnector(~connectorType=ConnectorTypes.Processor)
              : paymentConnectorId
          )->React.string}
        </p>
      </div>
      <div className="flex flex-col gap-1">
        <h4 className="text-nd_gray-400"> {"Processor Reference"->React.string} </h4>
        <p className="!font-jetbrains-mono text-nd_gray-600"> {reference->React.string} </p>
      </div>
      <div className="flex flex-col gap-1">
        <h4 className="text-nd_gray-400"> {"Status"->React.string} </h4>
        {switch details {
        | Some(item) => <p className="text-nd_gray-600"> {item.status->React.string} </p>
        | None => <p className="text-nd_gray-400"> {"Not available"->React.string} </p>
        }}
      </div>
    </div>
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-7">
      <div className="flex justify-between border-b pb-4 px-2 items-end">
        <p className={heading.md.semibold}> {"Payment Processors"->React.string} </p>
        {switch mode {
        | ListProcessors =>
          <div
            className="flex gap-2 items-center cursor-pointer"
            onClick={_ => setMode(_ => SelectProcessor)}>
            <Icon name="nd-plus" size=14 />
            <a className="text-primary cursor-pointer"> {"Add processor"->React.string} </a>
          </div>
        | _ =>
          <Button
            text="Cancel"
            onClick={_ => {
              setConnector(_ => "")
              setSelectedConnectorInUrl("")
              setMode(_ => ListProcessors)
            }}
            buttonType={Secondary}
            buttonSize={Small}
            customButtonStyle="w-fit"
          />
        }}
      </div>
      {switch mode {
      | ListProcessors =>
        <div className="flex flex-col">
          <RenderIf condition={registeredProcessorIds->Array.length === 0}>
            <p className="text-nd_gray-400 px-2 py-4">
              {"No payment processors connected yet."->React.string}
            </p>
          </RenderIf>
          {registeredProcessorIds->Array.map(processorRow)->React.array}
        </div>
      | SelectProcessor =>
        <PageLoaderWrapper screenState={isMitConnectorListLoading ? Loading : Success}>
          <PaymentProcessorCards
            connectorsAvailableForIntegration=mitSupportedConnectors
            configuredConnectors=[]
            heading="Choose a processor"
            mixpanelEventPrefix="recovery_add_connector_click"
            onCardClick={connectorName => {
              setConnector(_ => connectorName)
              setSelectedConnectorInUrl(connectorName)
              setMode(_ => AuthenticateProcessor)
            }}
          />
        </PageLoaderWrapper>
      | AuthenticateProcessor =>
        <div className="flex flex-col gap-3 px-2 max-w-2xl">
          <Form onSubmit initialValues={updatedInitialVal} validate=validateMandatoryField>
            <ConnectorAuthKeys
              initialValues={updatedInitialVal} showVertically=true updateAccountDetails=isLiveMode
            />
            <ConnectorLabelV2 isInEditState=true connectorInfo={connectorInfoDict} />
            <ConnectorMetadataV2 isInEditState=true connectorInfo={connectorInfoDict} />
            <ConnectorWebhookDetails isInEditState=true connectorInfo={connectorInfoDict} />
            <RenderIf condition={!isCustomBilling}>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-hyperswitch_black"
                field={FormRenderer.makeFieldInfo(
                  ~label="Processor Reference ID",
                  ~name="processor_reference_id",
                  ~placeholder="Enter the customer id configured in your billing platform",
                  ~customInput=InputFields.textInput(~customStyle="border rounded-xl"),
                  ~isRequired=true,
                )}
              />
            </RenderIf>
            <FormRenderer.SubmitButton
              text="Add processor" buttonSize={Small} customSubmitButtonStyle="!w-full mt-8"
            />
          </Form>
        </div>
      }}
    </div>
  </PageLoaderWrapper>
}
