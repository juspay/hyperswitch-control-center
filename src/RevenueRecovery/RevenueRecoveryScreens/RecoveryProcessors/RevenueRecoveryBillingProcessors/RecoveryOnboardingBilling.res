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
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let getURL = useGetURL()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let showToast = ToastAdapter.useShowToast()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=UserInfoTypes.V2,
  )

  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (screenState, setScreenState) = React.useState(_ => Success)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let connectorInfoDict = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->LogicUtils.getDictFromJsonObject,
  )
  let connectorTypeFromName =
    connector->getConnectorNameTypeFromString(~connectorType=ConnectorTypes.BillingProcessor)

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set(
      "connector_label",
      `${connector}_${activeBusinessProfile}`->JSON.Encode.string,
    )
    initialValuesToDict->Dict.set("connector_type", "billing_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)

    if !isLiveMode {
      RevenueRecoveryData.fillDummyData(
        ~connector,
        ~initialValuesToDict,
        ~merchantId,
        ~connectorID,
        ~connectorType=ConnectorTypes.BillingProcessor,
      )
    } else {
      // TODO: need to be removed when we have file upload on live
      let billingAccountReference = [(connectorID, connectorID->JSON.Encode.string)]->Dict.fromArray

      let revenueRecovery =
        [
          ("billing_connector_retry_threshold", 0->JSON.Encode.int),
          ("max_retry_count", 0->JSON.Encode.int),
          ("billing_account_reference", billingAccountReference->JSON.Encode.object),
        ]->Dict.fromArray

      initialValuesToDict->Dict.set(
        "feature_metadata",
        [("revenue_recovery", revenueRecovery->JSON.Encode.object)]
        ->Dict.fromArray
        ->JSON.Encode.object,
      )
    }

    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let handleAuthKeySubmit = async (values, _) => {
    mixpanelEvent(~eventName=currentStep->getMixpanelEventName)
    setInitialValues(_ => values)
    onNextClick(currentStep, setNextStep, isLiveMode)
    Nullable.null
  }

  let handleClick = () => {
    mixpanelEvent(~eventName=currentStep->getMixpanelEventName)
    onNextClick(currentStep, setNextStep, isLiveMode)->ignore
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    mixpanelEvent(~eventName=currentStep->getMixpanelEventName)
    let dict = values->getDictFromJsonObject
    let values = dict->JSON.Encode.object
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Put, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post, ~version=V2)
      setInitialValues(_ => response)
      fetchConnectorListResponse()->ignore
      setScreenState(_ => Success)

      handleClick()
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setNextStep(_ => defaultStepBilling)
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
  }, [connector])

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
    let valueDict = values->getDictFromJsonObject
    let revenue_recovery =
      valueDict->getDictfromDict("feature_metadata")->getDictfromDict("revenue_recovery")

    if currentStep->getSectionVariant == (#addAPlatform, #processorSetUp) {
      let billing_connector_retry_threshold =
        revenue_recovery->getInt("billing_connector_retry_threshold", 0)
      let max_retry_count = revenue_recovery->getInt("max_retry_count", 0)

      if !isLiveMode {
        if billing_connector_retry_threshold === 0 {
          Dict.set(
            errors,
            "billing_connector_retry_threshold",
            `Please enter start retry count`->JSON.Encode.string,
          )
        } else if billing_connector_retry_threshold > 15 {
          Dict.set(
            errors,
            "billing_connector_retry_threshold",
            `Start retry count should be less than 15`->JSON.Encode.string,
          )
        }

        if max_retry_count === 0 {
          Dict.set(
            errors,
            "max_retry_count",
            `Please enter max retry count count`->JSON.Encode.string,
          )
        } else if max_retry_count > 15 {
          Dict.set(
            errors,
            "max_retry_count",
            `Max retry count count should be less than 15`->JSON.Encode.string,
          )
        }
      }
    }

    if currentStep->getSectionVariant == (#addAPlatform, #processorSetUp) {
      let billing_account_reference =
        revenue_recovery->getObj("billing_account_reference", Dict.make())

      if billing_account_reference->getString(connectorID, "")->isEmptyString {
        Dict.set(
          errors,
          "billing_account_reference",
          `Please enter Processor Reference ID`->JSON.Encode.string,
        )
      }
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

  let authKeysSubmit = isLiveMode ? onSubmit : handleAuthKeySubmit

  <div>
    <Form onSubmit initialValues>
      {switch currentStep->getSectionVariant {
      | (#addAPlatform, #selectAPlatform) =>
        <PageWrapper
          title="Choose your Billing Platform"
          subTitle="Select your subscription management platform to get started.">
          <PaymentProcessorCards
            connectorsAvailableForIntegration={isLiveMode
              ? prodBillingConnectorList
              : billingConnectorList}
            configuredConnectors=[]
            connectorType=ConnectorTypes.BillingProcessor
            heading="Choose a platform"
            mixpanelEventPrefix="recovery_billing_connector_click"
            onCardClick={connectorName => {
              setConnectorName(_ => connectorName)
              handleClick()
            }}
          />
        </PageWrapper>
      | (#addAPlatform, #authenticateBilling) =>
        <BillingConnectorAuthKeys
          initialValues
          onSubmit=authKeysSubmit
          validateMandatoryField
          updatedInitialVal
          connectorInfoDict
          screenState
        />
      | (#addAPlatform, #processorSetUp) =>
        <BillingProcessorsSetUp
          initialValues
          validateMandatoryField
          connector={paymentConnectorName}
          billingConnector=connector
          onSubmit
          connector_account_reference_id=connectorID
        />
      | (#reviewDetails, _) => <BillingProcessorsReviewDetails />
      | _ => React.null
      }}
    </Form>
  </div>
}
