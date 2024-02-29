@react.component
let make = (~setCurrentStep, ~setInitialValues, ~initialValues, ~isUpdateFlow, ~isPayoutFlow) => {
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  open ConnectorAccountDetailsHelper
  let url = RescriptReactRouter.useUrl()
  let showToast = ToastState.useShowToast()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorID = url.path->List.toArray->Array.get(1)->Option.getOr("")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let updateDetails = useUpdateMethod(~showErrorToast=false, ())

  let (verifyDone, setVerifyDone) = React.useState(_ => ConnectorTypes.NoAttempt)
  let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)
  let (verifyErrorMessage, setVerifyErrorMessage) = React.useState(_ => None)
  let connectorTypeFromName = connector->getConnectorNameTypeFromString()

  let selectedConnector = React.useMemo1(() => {
    connectorTypeFromName->getConnectorInfo
  }, [connector])

  let defaultBusinessProfile = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)

  let activeBusinessProfile =
    defaultBusinessProfile->MerchantAccountUtils.getValueFromBusinessProfile

  let connectorDetails = React.useMemo1(() => {
    try {
      if connector->isNonEmptyString {
        let dict = isPayoutFlow
          ? Window.getPayoutConnectorConfig(connector)
          : Window.getConnectorConfig(connector)
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

  let (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
  ) = getConnectorFields(connectorDetails)

  let (showModal, setShowModal) = React.useState(_ => false)

  let updatedInitialVal = React.useMemo1(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject

    // TODO: Refactor for generic case
    if !isUpdateFlow {
      if (
        switch connectorTypeFromName {
        | Processors(PAYPAL) => true
        | _ => false
        } &&
        featureFlagDetails.paypalAutomaticFlow
      ) {
        initialValuesToDict->Dict.set(
          "connector_label",
          initialValues
          ->getDictFromJsonObject
          ->getString("connector_label", "")
          ->JSON.Encode.string,
        )
        initialValuesToDict->Dict.set(
          "profile_id",
          initialValuesToDict->getString("profile_id", "")->JSON.Encode.string,
        )
      } else if connector->isNonEmptyString {
        initialValuesToDict->Dict.set(
          "connector_label",
          `${connector}_${activeBusinessProfile.profile_name}`->JSON.Encode.string,
        )
        initialValuesToDict->Dict.set(
          "profile_id",
          activeBusinessProfile.profile_id->JSON.Encode.string,
        )
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
  }, [connector, activeBusinessProfile.profile_id])

  let onSubmitMain = async values => {
    open ConnectorTypes
    try {
      let body = generateInitialValuesDict(
        ~values,
        ~connector,
        ~bodyType,
        ~isPayoutFlow,
        ~isLiveMode={featureFlagDetails.isLiveMode},
        (),
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
                (),
              )
              setCurrentStep(_ => IntegFields)
              setScreenState(_ => Success)
            } else {
              showToast(
                ~message="Failed to Save the Configuration!",
                ~toastType=ToastState.ToastError,
                (),
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
          ~isPayoutFlow,
          ~isLiveMode={featureFlagDetails.isLiveMode},
          (),
        )->ignoreFields(connectorID, verifyConnectorIgnoreField)

      let url = APIUtils.getURL(
        ~entityName=CONNECTOR,
        ~methodType=Post,
        ~connector=Some(connector),
        (),
      )
      let _ = await updateDetails(url, body, Post, ())
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
  <PageLoaderWrapper screenState>
    <Form
      initialValues={updatedInitialVal}
      onSubmit={(values, _) =>
        onSubmit(
          ~values,
          ~onSubmitVerify,
          ~onSubmitMain,
          ~setVerifyDone,
          ~verifyDone,
          ~isVerifyConnector,
          ~isVerifyConnectorFeatureEnabled=featureFlagDetails.verifyConnector,
        )}
      validate={validateMandatoryField}
      formClass="flex flex-col ">
      <ConnectorHeaderWrapper
        connector
        headerButton={<AddDataAttributes attributes=[("data-testid", "connector-submit-button")]>
          <FormRenderer.SubmitButton loadingText="Processing..." text=buttonText />
        </AddDataAttributes>}
        handleShowModal>
        <UIUtils.RenderIf condition={featureFlagDetails.businessProfile}>
          <div className="flex flex-col gap-2 p-2 md:px-10">
            <ConnectorAccountDetailsHelper.BusinessProfileRender
              isUpdateFlow selectedConnector={connector}
            />
          </div>
        </UIUtils.RenderIf>
        <div
          className={`flex flex-col gap-2 p-2 md:${featureFlagDetails.businessProfile
              ? "px-10"
              : "p-10"}`}>
          <div className="grid grid-cols-2 flex-1">
            <ConnectorConfigurationFields
              connector={connectorTypeFromName}
              connectorAccountFields
              selectedConnector
              connectorMetaDataFields
              connectorWebHookDetails
              connectorLabelDetailField
            />
          </div>
          <IntegrationHelp.Render connector setShowModal showModal />
        </div>
        <FormValuesSpy />
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
