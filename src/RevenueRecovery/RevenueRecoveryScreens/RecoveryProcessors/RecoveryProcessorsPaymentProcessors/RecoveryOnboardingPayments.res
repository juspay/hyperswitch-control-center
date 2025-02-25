@react.component
let make = (
  ~currentStep,
  ~setConnectorID,
  ~connector,
  ~setConnectorName,
  ~setNextStep,
  ~profileId,
  ~merchantId,
  ~activeBusinessProfile,
) => {
  open APIUtils
  open LogicUtils
  open ConnectorUtils
  open PageLoaderWrapper
  open RevenueRecoveryOnboardingUtils

  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (screenState, setScreenState) = React.useState(_ => Success)

  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let connectorInfoDict =
    initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let connectorTypeFromName = connector->getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->getConnectorInfo
  }, [connector])

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
    initialValuesToDict->Dict.set("test_mode", !featureFlagDetails.isLiveMode->JSON.Encode.bool)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let handleAuthKeySubmit = async (_, _) => {
    onNextClick(currentStep, setNextStep)
    Nullable.null
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post)
      setInitialValues(_ => response)
      let connectorInfoDict =
        response->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
      setConnectorID(_ => connectorInfoDict.merchant_connector_id)
      fetchConnectorListResponse()->ignore
      setScreenState(_ => Success)
      onNextClick(currentStep, setNextStep)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setNextStep(_ => RevenueRecoveryOnboardingUtils.defaultStep)
          setScreenState(_ => Success)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
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

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setConnectorName(_ => value)
    },
    onFocus: _ => (),
    value: connector->JSON.Encode.string,
    checked: true,
  }

  let options = (featureFlagDetails.isLiveMode ? connectorListForLive : connectorList)->getOptions

  <div>
    {switch currentStep->RevenueRecoveryOnboardingUtils.getSectionVariant {
    | (#connectProcessor, #selectProcessor) =>
      <PageWrapper
        title="Authenticate Processor"
        subTitle="Configure your credentials from your processor dashboard. Hyperswitch encrypts and stores these credentials securely.">
        <div className="-m-1 mb-10 flex flex-col gap-7 w-540-px">
          <PageLoaderWrapper screenState>
            <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText="Select Processor"
                input
                deselectDisable=true
                customButtonStyle="!rounded-xl h-[45px] pr-2"
                options
                hideMultiSelectButtons=true
                addButton=false
                searchable=true
                customStyle="!w-full"
                customDropdownOuterClass="!border-none"
                fullLength=true
                shouldDisplaySelectedOnTop=true
                searchInputPlaceHolder="Search Processor"
              />
              <RenderIf condition={connector->isNonEmptyString}>
                <div className="flex flex-col mb-5 mt-7 gap-3 w-full ">
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
              </RenderIf>
              <FormValuesSpy />
            </Form>
          </PageLoaderWrapper>
        </div>
      </PageWrapper>
    | (#connectProcessor, #activePaymentMethods) =>
      <PageWrapper title="Payment Methods" subTitle="Configure your PaymentMethods.">
        <div className="-m-1 mb-10 flex flex-col gap-7 w-540-px">
          <PageLoaderWrapper screenState>
            <Form onSubmit initialValues validate=validateMandatoryField>
              <div className="flex flex-col mb-5 gap-3 ">
                <ConnectorPaymentMethodV3 initialValues isInEditState=true />
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
      </PageWrapper>
    | (#connectProcessor, #setupWebhookProcessor) =>
      <PageWrapper
        title="Setup Webhook"
        subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor">
        <div className="-m-1 mb-10 flex flex-col gap-7 w-540-px">
          <ConnectorWebhookPreview
            merchantId
            connectorName=connectorInfoDict.merchant_connector_id
            textCss="border border-nd_gray-300 font-[700] rounded-xl px-4 py-2 mb-6 mt-6  text-nd_gray-400 w-full"
            containerClass="flex flex-row items-center justify-between"
            displayTextLength=46
            hideLabel=true
            showFullCopy=true
          />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
            customButtonStyle="w-full mt-8"
          />
        </div>
      </PageWrapper>

    | (_, _) => React.null
    }}
  </div>
}
