@react.component
let make = (~setCurrentStep, ~setInitialValues, ~initialValues, ~isUpdateFlow) => {
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  open ConnectorAccountDetailsHelper
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let updateDetails = useUpdateMethod(~showErrorToast=false)

  let (verifyDone, setVerifyDone) = React.useState(_ => ConnectorTypes.NoAttempt)
  let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)
  let (verifyErrorMessage, setVerifyErrorMessage) = React.useState(_ => None)
  let connectorTypeFromName =
    connector->getConnectorNameTypeFromString(~connectorType=PayoutProcessor)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getPayoutConnectorConfig(connector)
        setScreenState(_ => Success)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Dict.make()->JSON.Encode.object
      }
    }
  }, [connector])

  let {
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  } = getConnectorFields(connectorDetails)

  let (showModal, setShowModal) = React.useState(_ => false)

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject

    // TODO: Refactor for generic case
    if !isUpdateFlow {
      if connector->isNonEmptyString {
        initialValuesToDict->Dict.set(
          "connector_label",
          `${connector}_${businessProfileRecoilVal.profile_name}`->JSON.Encode.string,
        )
        initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
      }
    }
    if (
      connectorTypeFromName->checkIsDummyConnector(featureFlagDetails.testProcessors) &&
        !isUpdateFlow
    ) {
      let apiKeyDict = [("api_key", "test_key"->JSON.Encode.string)]->Dict.fromArray
      initialValuesToDict->Dict.set("connector_account_details", apiKeyDict->JSON.Encode.object)

      initialValuesToDict->JSON.Encode.object
    } else {
      initialValues
    }
  }, [connector, profileId])

  let onSubmitMain = async values => {
    open ConnectorTypes
    try {
      let body = generateInitialValuesDict(
        ~values,
        ~connector,
        ~bodyType,
        ~isLiveMode={featureFlagDetails.isLiveMode},
        ~connectorType=ConnectorTypes.PayoutProcessor,
      )
      setScreenState(_ => Loading)
      setCurrentStep(_ => PaymentMethods)
      setScreenState(_ => Success)
      setInitialValues(_ => body)
    } catch {
    | Exn.Error(e) => {
        setShowVerifyModal(_ => false)
        setVerifyDone(_ => ConnectorTypes.NoAttempt)
        switch Exn.message(e) {
        | Some(message) => {
            let errMsg = message->parseIntoMyData
            if errMsg.code->Option.getOr("")->String.includes("HE_01") {
              showToast(
                ~message="This configuration already exists for the connector. Please try with a different country or label under advanced settings.",
                ~toastType=ToastState.ToastError,
              )
              setCurrentStep(_ => IntegFields)
              setScreenState(_ => Success)
            } else {
              showToast(
                ~message="Failed to Save the Configuration!",
                ~toastType=ToastState.ToastError,
              )
              setScreenState(_ => Error(message))
            }
          }

        | None => setScreenState(_ => Error("Failed to Fetch!"))
        }
      }
    }
  }

  let onSubmitVerify = async values => {
    try {
      let body =
        generateInitialValuesDict(
          ~values,
          ~connector,
          ~bodyType,
          ~isLiveMode={featureFlagDetails.isLiveMode},
          ~connectorType=ConnectorTypes.PayoutProcessor,
        )->ignoreFields(connectorID, verifyConnectorIgnoreField)

      let url = getURL(~entityName=V1(CONNECTOR), ~methodType=Post, ~connector=Some(connector))
      let _ = await updateDetails(url, body, Post)
      setShowVerifyModal(_ => false)
      onSubmitMain(values)->ignore
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) => {
          let errorMessage = message->parseIntoMyData
          setVerifyErrorMessage(_ => errorMessage.message)
          setShowVerifyModal(_ => true)
          setVerifyDone(_ => Failure)
        }
      | None => setScreenState(_ => Error("Failed to Fetch!"))
      }
    }
  }

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

  let buttonText = switch verifyDone {
  | NoAttempt =>
    if !isUpdateFlow {
      "Connect and Proceed"
    } else {
      "Proceed"
    }
  | Failure => "Try Again"
  | _ => "Loading..."
  }

  let (suggestedAction, suggestedActionExists) = getSuggestedAction(~verifyErrorMessage, ~connector)
  let handleShowModal = () => {
    setShowModal(_ => true)
  }

  let mixpanelEventName = isUpdateFlow ? "processor_step1_onUpdate" : "processor_step1"

  <PageLoaderWrapper screenState>
    <Form
      initialValues={updatedInitialVal}
      onSubmit={(values, _) => {
        mixpanelEvent(~eventName=mixpanelEventName)
        onSubmit(
          ~values,
          ~onSubmitVerify,
          ~onSubmitMain,
          ~setVerifyDone,
          ~verifyDone,
          ~isVerifyConnector,
        )
      }}
      validate={validateMandatoryField}
      formClass="flex flex-col ">
      <ConnectorHeaderWrapper
        connector
        connectorType={PayoutProcessor}
        headerButton={<AddDataAttributes attributes=[("data-testid", "connector-submit-button")]>
          <FormRenderer.SubmitButton loadingText="Processing..." text=buttonText />
        </AddDataAttributes>}
        handleShowModal>
        <div className="flex flex-col gap-2 p-2 md:px-10">
          <ConnectorAccountDetailsHelper.BusinessProfileRender
            isUpdateFlow selectedConnector={connector}
          />
        </div>
        <div className={`flex flex-col gap-2 p-2 md:px-10`}>
          <div className="grid grid-cols-2 flex-1">
            <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
              connector={connector->getConnectorNameTypeFromString(~connectorType=PayoutProcessor)}
              connectorAccountFields
              selectedConnector={connector
              ->getConnectorNameTypeFromString(~connectorType=PayoutProcessor)
              ->getConnectorInfo}
              connectorMetaDataFields
              connectorWebHookDetails
              connectorLabelDetailField
              connectorAdditionalMerchantData
            />
          </div>
          <IntegrationHelp.Render connector setShowModal showModal />
        </div>
      </ConnectorHeaderWrapper>
      <VerifyConnectorModal
        showVerifyModal
        setShowVerifyModal
        connector
        verifyErrorMessage
        suggestedActionExists
        suggestedAction
        setVerifyDone
      />
    </Form>
  </PageLoaderWrapper>
}
