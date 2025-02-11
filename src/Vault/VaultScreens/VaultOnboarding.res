@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  open ConnectorUtils
  open CommonAuthHooks
  open VaultHomeUtils

  let getURL = useGetURL()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let {profileId} = getUserInfoData()
  let (_, setConnectorId) = React.useState(() => "")
  let showToast = ToastState.useShowToast()
  let connectorInfoDict =
    initialValues->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  Js.log2("connectorInfoDict", connectorInfoDict)
  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: "authenticate-processor",
    subSectionId: None,
  })
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString
  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])
  let connectorName = connectorInfoDict.connector_name->getDisplayNameForConnector
  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let activeBusinessProfile = getNameForId(#Profile)

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

    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setNextStep(_ => nextStep)
    | None => ()
    }
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post)
      setInitialValues(_ => response)
      let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorId(_ => connectorId)
      fetchConnectorListResponse()->ignore
      onNextClick()
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        errorCode === "HE_01"
          ? showToast(~message="Connector label already exist!", ~toastType=ToastError)
          : showToast(~message=errorMessage, ~toastType=ToastError)
        setScreenState(_ => PageLoaderWrapper.Error(`Failed to connect processor ${errorMessage}`))
      }
    }
    Nullable.null
  }

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/vault/onboarding"))
    setShowSideBar(_ => true)
  }
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

  let (
    _,
    connectorAccountFields,
    connectorMetaDataFields,
    _,
    connectorWebHookDetails,
    connectorLabelDetailField,
    _,
  ) = getConnectorFields(connectorDetails)

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

  <div className="flex flex-row gap-x-6">
    <VerticalStepIndicator
      title={`Setup ${connectorName} `}
      sections
      currentStep
      backClick
      customProcessorIcon={`${connectorInfoDict.connector_name}`}
    />
    {switch currentStep {
    | {sectionId: "authenticate-processor"} =>
      <div className="flex flex-col w-1/2 px-10 ">
        <PageUtils.PageHeading
          title="Authenticate Processor"
          subTitle="Configure your credentials from your processor dashboard. Hyperswitch encrypts and stores these credentials securely."
          customSubTitleStyle="font-500 font-normal text-nd_gray-700"
        />
        <PageLoaderWrapper screenState>
          <Form onSubmit initialValues validate=validateMandatoryField>
            <div className="flex flex-col mb-5 gap-3 ">
              <ConnectorAuthKeys
                initialValues={updatedInitialVal} setInitialValues showVertically=true
              />
              <ConnectorLabelV2 />
              <ConnectorMetadataV2 />
              <ConnectorWebhookDetails />
              <FormRenderer.SubmitButton
                text="Next"
                buttonSize={Small}
                customSumbitButtonStyle="!w-full mt-8"
                tooltipForWidthClass="w-full"
              />
            </div>
            <FormValuesSpy />
          </Form>
        </PageLoaderWrapper>
      </div>

    | {sectionId: "setup-webhook"} =>
      <div className="flex flex-col w-1/2 px-10">
        <PageUtils.PageHeading
          title="Setup Webhook"
          subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
          customSubTitleStyle="font-medium text-nd_gray-700"
        />
        <ConnectorWebhookPreview
          merchantId
          connectorName=connectorInfoDict.merchant_connector_id
          textCss="border border-gray-400 font-[700] rounded-xl px-4 py-2 mb-6 mt-6  text-nd_gray-400"
          containerClass="flex flex-row items-center justify-between"
          hideLabel=true
          showFullCopy=true
        />
        <Button
          text="Next"
          buttonType=Primary
          onClick={_ => onNextClick()->ignore}
          customButtonStyle="w-full mt-8"
        />
      </div>
    | {sectionId: "review-and-connect"} => <VaultProceesorReview connectorInfo=initialValues />
    | _ => React.null
    }}
  </div>
}
