@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  open ConnectorUtils
  open PageLoaderWrapper
  open RecoveryConnectorTypes
  open RecoveryConnectorUtils

  let getURL = useGetURL()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => Success)
  let {profileId, merchantId} = getUserInfoData()
  let showToast = ToastState.useShowToast()

  let connectorInfo = initialValues->LogicUtils.getDictFromJsonObject
  let connectorInfoDict = ConnectorInterface.mapDictToConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    connectorInfo,
  )

  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: (#AuthenticateProcessor: sectionType :> string),
    subSectionId: None,
  })
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->getConnectorNameTypeFromString
  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->getConnectorInfo
  }, [connector])
  let connectorName = connector->getDisplayNameForConnector
  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

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

  let handleAuthKeySubmit = async (_, _) => {
    onNextClick()
    Nullable.null
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Put, ~id=None)
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
            sectionId: (#AuthenticateProcessor: sectionType :> string),
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

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/connectors"))
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
  let recoveryTitleElement =
    <>
      <GatewayIcon gateway={`${connector}`->String.toUpperCase} />
      <h1 className="text-medium font-semibold text-gray-600">
        {`Setup ${connectorName}`->React.string}
      </h1>
    </>

  <div className="flex flex-row gap-x-6">
    <VerticalStepIndicator titleElement=recoveryTitleElement sections currentStep backClick />
    {switch currentStep->getSectionVariant {
    | #AuthenticateProcessor =>
      <div className="flex flex-col w-1/2 px-10 ">
        <PageUtils.PageHeading
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
                customSumbitButtonStyle="!w-full mt-8"
                tooltipForWidthClass="w-full"
              />
            </div>
            <FormValuesSpy />
          </Form>
        </PageLoaderWrapper>
      </div>
    | #SetupPmts =>
      <div className="flex flex-col w-1/2 px-10 ">
        <PageUtils.PageHeading
          title="Payment Methods"
          subTitle="Configure your PaymentMethods."
          customSubTitleStyle="font-500 font-normal text-nd_gray-700"
        />
        <PageLoaderWrapper screenState>
          <Form onSubmit initialValues validate=validateMandatoryField>
            <div className="flex flex-col mb-5 gap-3 ">
              <ConnectorPaymentMethodV2 initialValues isInEditState=true />
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
    | #SetupWebhook =>
      <div className="flex flex-col w-1/2 px-10">
        <PageUtils.PageHeading
          title="Setup Webhook"
          subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
          customSubTitleStyle="font-medium text-nd_gray-700"
        />
        <ConnectorWebhookPreview
          merchantId
          connectorName=connectorInfoDict.id
          textCss="border border-nd_gray-300 font-[700] rounded-xl px-4 py-2 mb-6 mt-6  text-nd_gray-400"
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
    | #ReviewAndConnect => <RecoveryProceesorReview connectorInfo=initialValues />
    }}
  </div>
}
