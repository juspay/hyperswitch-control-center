@react.component
let make = (
  ~currentStep,
  ~connectorID,
  ~connector,
  ~paymentConnectorName,
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

  let connectorInfoDict = ConnectorInterface.mapDictToConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->LogicUtils.getDictFromJsonObject,
  )
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

  let handleAuthKeySubmit = async (values, _) => {
    setInitialValues(_ => values)
    onNextClick(currentStep, setNextStep)
    Nullable.null
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    let dict = values->getDictFromJsonObject
    dict->Dict.set("connector_name", "stripe"->JSON.Encode.string)
    let values = dict->JSON.Encode.object

    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Put)
      setInitialValues(_ => response)
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
        let dict = BillingProcessorsUtils.getConnectorConfig(connector)
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

  <div>
    <Form onSubmit initialValues>
      {switch currentStep->RevenueRecoveryOnboardingUtils.getSectionVariant {
      | (#addAPlatform, #selectAPlatform) =>
        <BillingConnectorAuthKeys
          initialValues
          setConnectorName
          connector
          handleAuthKeySubmit
          validateMandatoryField
          updatedInitialVal
          connectorInfoDict
          screenState
        />
      | (#addAPlatform, #configureRetries) =>
        <BillingProcessorsConfigureRetry initialValues handleAuthKeySubmit validateMandatoryField />
      | (#addAPlatform, #connectProcessor) =>
        <BillingProcessorsConnectProcessor
          connector={paymentConnectorName}
          initialValues
          onSubmit={handleAuthKeySubmit}
          validateMandatoryField
          connector_account_reference_id=connectorID
        />
      | (#addAPlatform, #setupWebhookPlatform) =>
        <BillingProcessorsWebhooks
          initialValues merchantId onNextClick={_ => onNextClick(currentStep, setNextStep)->ignore}
        />
      | (#reviewDetails, _) => <BillingProcessorsReviewDetails connectorInfo={initialValues} />
      | _ => React.null
      }}
    </Form>
  </div>
}
