@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  open ConnectorUtils
  open CommonAuthHooks
  open PaymentConnectorUtils
  open PageLoaderWrapper

  let getURL = useGetURL()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let {profileId} = getUserInfoData()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=V2,
  )
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (screenState, setScreenState) = React.useState(_ => Success)
  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: (#authenticateProcessor: PaymentConnectorTypes.paymentConnectorSections :> string),
    subSectionId: None,
  })

  let connectorInfoDict = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->LogicUtils.getDictFromJsonObject,
  )

  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->getConnectorNameTypeFromString
  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->getConnectorInfo
  }, [connector])
  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let activeBusinessProfile = getNameForId(#Profile)

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        Dict.make()->JSON.Encode.object
      }
    }
  }, [selectedConnector])

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set(
      "connector_label",
      `${connector}_${activeBusinessProfile}`->JSON.Encode.string,
    )
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    let keys =
      connectorDetails
      ->getDictFromJsonObject
      ->Dict.keysToArray
      ->Array.filter(val => Array.includes(["credit", "debit"], val))

    let pmtype = keys->Array.flatMap(key => {
      let paymentMethodType = connectorDetails->getDictFromJsonObject->getArrayFromDict(key, [])
      let updatedData = paymentMethodType->Array.map(
        val => {
          let wasmDict = val->getDictFromJsonObject
          let existingData =
            wasmDict->ConnectorPaymentMethodV2Utils.getPaymentMethodDictV2(key, connector)
          existingData
        },
      )
      updatedData
    })
    let pmSubTypeDict =
      [
        ("payment_method_type", "card"->JSON.Encode.string),
        ("payment_method_subtypes", pmtype->Identity.genericTypeToJson),
      ]->Dict.fromArray
    let pmArr = Array.make(~length=1, pmSubTypeDict)
    initialValuesToDict->Dict.set("payment_methods_enabled", pmArr->Identity.genericTypeToJson)

    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let onNextClick = () => {
    mixpanelEvent(~eventName=currentStep->getPaymentConnectorMixPanelEvent)
    switch getNextStep(currentStep) {
    | Some(nextStep) => setNextStep(_ => nextStep)
    | None => ()
    }
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post, ~version=V2)
      setInitialValues(_ => response)
      fetchConnectorListResponse()->ignore
      setScreenState(_ => Success)
      onNextClick()
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setNextStep(_ => {
            sectionId: "authenticate-processor",
            subSectionId: None,
          })
          setScreenState(_ => Success)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
  }

  let handleAuthKeySubmit = async (_, _) => {
    onNextClick()
    Nullable.null
  }

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/orchestration/connectors"))
    setShowSideBar(_ => true)
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
    let profileId = valuesFlattenJson->getString("profile_id", "")
    if profileId->String.length === 0 {
      Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
    }

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

  let titleElement =
    <>
      <GatewayIcon gateway={`${connector}`->String.toUpperCase} className="w-6 h-6" />
      <h1 className="text-medium font-semibold text-gray-600 ">
        {`Setup ${connector->capitalizeString}`->React.string}
      </h1>
    </>

  <div className="flex flex-col gap-10">
    <div className="flex h-full">
      <div className="flex flex-col ">
        <VerticalStepIndicator titleElement sections currentStep backClick />
      </div>
      {switch currentStep.sectionId->stringToSectionVariantMapper {
      | #authenticateProcessor =>
        <div className="flex flex-col w-1/2 px-10 mt-8 overflow-y-auto">
          <PageUtils.PageHeading
            showPermLink=false
            title="Authenticate Processor"
            subTitle="Configure your credentials from your processor dashboard. Hyperswitch encrypts and stores these credentials securely."
            customSubTitleStyle="font-500 font-normal text-nd_gray-700"
          />
          <PageLoaderWrapper screenState>
            <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
              <div className="flex flex-col mb-5 gap-3 ">
                <ConnectorAuthKeys initialValues={updatedInitialVal} showVertically=true />
                <ConnectorLabelV2 isInEditState=true connectorInfo={connectorInfoDict} />
                <ConnectorMetadataV2 isInEditState=true connectorInfo={connectorInfoDict} />
                <ConnectorWebhookDetails isInEditState=true connectorInfo={connectorInfoDict} />
                <FormRenderer.SubmitButton
                  text="Next"
                  buttonSize={Small}
                  customSubmitButtonStyle="!w-full mt-8"
                  tooltipForWidthClass="w-full"
                />
              </div>
            </Form>
          </PageLoaderWrapper>
        </div>

      | #setupPMTS =>
        <div className="flex flex-col w-1/2 px-10 mt-8 overflow-y-auto">
          <PageUtils.PageHeading
            showPermLink=false
            title="Payment Methods"
            subTitle="Configure your PaymentMethods."
            customSubTitleStyle="font-500 font-normal text-nd_gray-700"
          />
          <PageLoaderWrapper screenState>
            <Form onSubmit initialValues validate=validateMandatoryField>
              <div className="flex flex-col mb-5 gap-3">
                <ConnectorPaymentMethodV2 initialValues isInEditState=true />
                <FormRenderer.SubmitButton
                  text="Next"
                  buttonSize={Small}
                  customSubmitButtonStyle="!w-full mt-8"
                  tooltipForWidthClass="w-full"
                />
              </div>
            </Form>
          </PageLoaderWrapper>
        </div>

      | #setupWebhook =>
        <div className="flex flex-col w-1/2 px-10 mt-8 overflow-y-auto">
          <PageUtils.PageHeading
            showPermLink=false
            title="Setup Webhook"
            subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
            customSubTitleStyle="font-medium text-nd_gray-700"
          />
          <ConnectorWebhookPreview
            merchantId
            connectorName=connectorInfoDict.id
            textCss="border border-nd_gray-300 font-[700] rounded-xl px-4 py-2 mb-6 mt-6 text-nd_gray-400 font-jetbrains-mono text-sm min-w-0 truncate"
            containerClass="flex flex-col lg:flex-row items-center"
            hideLabel=true
            showFullCopy=true
            displayTextLength=42
          />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick()->ignore}
            customButtonStyle="w-full mt-8"
          />
        </div>

      | #reviewAndConnect => <PaymentConnectorReview connectorInfo=initialValues />
      | _ => React.null
      }}
    </div>
  </div>
}
