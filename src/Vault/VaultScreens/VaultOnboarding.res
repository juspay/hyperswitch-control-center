@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  open CommonAuthHooks
  open ConnectorUtils

  let sections = [
    {
      id: "authenticate-processor",
      name: "Authenticate your processor",
      icon: "nd-shield",
      subSections: None,
    },
    {
      id: "setup-webhook",
      name: "Setup Webhook",
      icon: "nd-webhook",
      subSections: None,
    },
    {
      id: "review-and-connect",
      name: "Review and Connect",
      icon: "nd-flag",
      subSections: None,
    },
  ]

  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let {profileId} = getUserInfoData()
  let (connectorId, setConnectorId) = React.useState(() => "")
  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: "authenticate-processor",
    subSectionId: None,
  })
  let connectorLabelDetailField = Dict.fromArray([
    ("connector_label", "Connector label"->JSON.Encode.string),
  ])
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let getWebhooksUrl = (~connectorName, ~merchantId) => {
    `${Window.env.apiBaseUrl}/webhooks/${merchantId}/${connectorName}`
  }
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let connectorInfo = initialValues
  let connectorInfo =
    connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let copyValueOfWebhookEndpoint = getWebhooksUrl(
    ~connectorName={connectorInfo.merchant_connector_id},
    ~merchantId,
  )
  let getDisplayValueOfWebHookUrl = (~connectorName) => {
    `${Window.env.apiBaseUrl}.../${connectorName}`
  }
  let displayValueofWebHookUrl = getDisplayValueOfWebHookUrl(
    ~connectorName={connectorInfo.merchant_connector_id},
  )
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString
  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])
  let labelFieldDict = ConnectorAuthKeyUtils.connectorLabelDetailField
  let label = labelFieldDict->getString("connector_label", "")
  let defaultBusinessProfile = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)

  let connectorName = connectorInfo.connector_name->getDisplayNameForConnector
  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }
  let activeBusinessProfile =
    defaultBusinessProfile->MerchantAccountUtils.getValueFromBusinessProfile

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set(
      "connector_label",
      `${connector}_${activeBusinessProfile.profile_name}`->JSON.Encode.string,
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
  let handleWebHookCopy = copyValue => {
    Clipboard.writeText(copyValue)
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
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
        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
        }
        setScreenState(_ => PageLoaderWrapper.Error(`Failed to connect processor ${errorMessage}`))
      }
    }
    Nullable.null
  }

  let onSucessClick = () => {
    onNextClick()
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
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
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
      customProcessorIcon={`${connectorInfo.connector_name}`}
    />
    {switch currentStep {
    | {sectionId: "authenticate-processor"} =>
      <>
        <div className="flex flex-col w-1/2 px-10 ">
          <PageUtils.PageHeading
            title="Authenticate Processor"
            subTitle="Configure your credentials from your processor dashboard. Hyperswitch encrypts and stores these credentials securely."
            customSubTitleStyle="font-500 font-normal text-gray-800"
          />
          <PageLoaderWrapper screenState>
            <Form onSubmit initialValues validate=validateMandatoryField>
              <div className="mb-[24px] ">
                <ConnectorAuthKeys
                  initialValues={updatedInitialVal} setInitialValues showVertically=true
                />
                <div className="mt-[12px]">
                  <FormRenderer.FieldRenderer
                    labelClass="font-semibold"
                    field={FormRenderer.makeFieldInfo(
                      ~label,
                      ~name="connector_label",
                      ~placeholder="Enter Connector Label name",
                      ~customInput=InputFields.textInput(~customStyle="rounded-xl"),
                      ~isRequired=true,
                    )}
                  />
                  <ConnectorAuthKeysHelper.ErrorValidation
                    fieldName="connector_label"
                    validate={ConnectorAuthKeyUtils.validate(
                      ~selectedConnector,
                      ~dict=connectorLabelDetailField,
                      ~fieldName="connector_label",
                      ~isLiveMode={featureFlagDetails.isLiveMode},
                    )}
                  />
                </div>
                <ConnectorMetadataV2 />
              </div>
              <FormValuesSpy />
              <FormRenderer.SubmitButton
                text="Next" buttonSize={Small} customSumbitButtonStyle="w-full mt-8"
              />
            </Form>
          </PageLoaderWrapper>
        </div>
      </>
    | {sectionId: "setup-webhook"} =>
      <div className="flex flex-col w-1/2 px-10">
        <PageUtils.PageHeading
          title="Setup Webhook"
          subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
          customSubTitleStyle="font-500 font-normal text-gray-800"
        />
        <div className="flex flex-row items-center justify-between ">
          <div
            className="border border-gray-400 font-[700] rounded-xl px-4 py-2 mb-6 mt-6  text-gray-400">
            {displayValueofWebHookUrl->React.string}
          </div>
          <Button
            leftIcon={CustomIcon(<Icon name="nd-copy" />)}
            text="Copy"
            customButtonStyle=" ml-4 w-[2px]"
            onClick={_ => handleWebHookCopy(copyValueOfWebhookEndpoint)}
          />
        </div>
        <Button
          text="Next"
          buttonType=Primary
          onClick={_ => onSucessClick()->ignore}
          customButtonStyle="w-full mt-8"
        />
      </div>
    | {sectionId: "review-and-connect"} =>
      <>
        <VaultProceesorReview connectorInfo=initialValues copyValueOfWebhookEndpoint />
      </>
    | _ => React.null
    }}
  </div>
}
