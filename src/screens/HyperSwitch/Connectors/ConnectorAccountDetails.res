@react.component
let make = (~setCurrentStep, ~setInitialValues, ~initialValues, ~isUpdateFlow, ~isPayoutFlow) => {
  open ConnectorUtils
  open APIUtils
  open ConnectorAccountDetailsHelper
  let url = RescriptReactRouter.useUrl()
  let showToast = ToastState.useShowToast()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorID = url.path->Belt.List.toArray->Belt.Array.get(1)->Belt.Option.getWithDefault("")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let updateDetails = useUpdateMethod(~showErrorToast=false, ())

  let (verifyDone, setVerifyDone) = React.useState(_ => ConnectorTypes.NoAttempt)
  let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)
  let (verifyErrorMessage, setVerifyErrorMessage) = React.useState(_ => None)

  let selectedConnector = React.useMemo1(() => {
    connector->getConnectorNameTypeFromString->getConnectorInfo
  }, [connector])

  let defaultBusinessProfile = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)

  let activeBusinessProfile =
    defaultBusinessProfile->MerchantAccountUtils.getValueFromBusinessProfile

  React.useEffect1(() => {
    if !isUpdateFlow {
      let defaultJsonOnNewConnector =
        [("profile_id", activeBusinessProfile.profile_id->Js.Json.string)]
        ->Dict.fromArray
        ->Js.Json.object_
      setInitialValues(_ => defaultJsonOnNewConnector)
    }
    None
  }, [activeBusinessProfile.profile_id])

  let connectorDetails = React.useMemo1(() => {
    try {
      if connector->String.length > 0 {
        let dict = isPayoutFlow
          ? Window.getPayoutConnectorConfig(connector)
          : Window.getConnectorConfig(connector)
        setScreenState(_ => Success)
        dict
      } else {
        Dict.make()->Js.Json.object_
      }
    } catch {
    | Js.Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Dict.make()->Js.Json.object_
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
    let initialValuesToDict = initialValues->LogicUtils.getDictFromJsonObject
    if !isUpdateFlow {
      initialValuesToDict->Dict.set(
        "connector_label",
        `${connector}_${activeBusinessProfile.profile_name}`->Js.Json.string,
      )
    }
    if (
      connector
      ->getConnectorNameTypeFromString
      ->checkIsDummyConnector(featureFlagDetails.testProcessors) && !isUpdateFlow
    ) {
      let apiKeyDict = [("api_key", "test_key"->Js.Json.string)]->Dict.fromArray
      initialValuesToDict->Dict.set("connector_account_details", apiKeyDict->Js.Json.object_)

      initialValuesToDict->Js.Json.object_
    } else {
      initialValues
    }
  }, [connector])

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
    | Js.Exn.Error(e) => {
        setShowVerifyModal(_ => false)
        setVerifyDone(_ => ConnectorTypes.NoAttempt)
        switch Js.Exn.message(e) {
        | Some(message) => {
            let errMsg = message->parseIntoMyData
            if errMsg.code->Belt.Option.getWithDefault("")->String.includes("HE_01") {
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
      let _ = await updateDetails(url, body, Post)
      setShowVerifyModal(_ => false)
      onSubmitMain(values)->ignore
    } catch {
    | Js.Exn.Error(e) =>
      switch Js.Exn.message(e) {
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
    let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
    if profileId->String.length === 0 {
      Dict.set(errors, "Profile Id", `Please select your business profile`->Js.Json.string)
    }

    validateConnectorRequiredFields(
      connector->getConnectorNameTypeFromString,
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->Js.Json.object_,
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

  let (suggestedAction, suggestedActionExists) = ConnectorUtils.getSuggestedAction(
    ~verifyErrorMessage,
    ~connector,
  )

  <PageLoaderWrapper screenState>
    <Form
      initialValues={updatedInitialVal}
      onSubmit={(values, _) =>
        ConnectorUtils.onSubmit(
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
      <div className="flex items-center justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon gateway={connector->String.toUpperCase} />
          <h2 className="text-xl font-semibold">
            {connector->LogicUtils.capitalizeString->React.string}
          </h2>
        </div>
        <div className="flex flex-row mt-6 md:mt-0 md:justify-self-end h-min">
          <UIUtils.RenderIf
            condition={connectorsWithIntegrationSteps->Array.includes(
              connector->getConnectorNameTypeFromString,
            )}>
            <a
              className={`flex cursor-pointer px-4 py-3 flex text-sm text-blue-900 items-center mx-4`}
              target="_blank"
              onClick={_ => {
                setShowModal(_ => true)
              }}>
              {React.string("View integration steps")}
              <Icon name="external-link-alt" size=14 className="ml-2" />
            </a>
          </UIUtils.RenderIf>
          <FormRenderer.SubmitButton loadingText="Processing..." text=buttonText />
        </div>
      </div>
      <div className="flex flex-col gap-2 p-2 md:p-10">
        <UIUtils.RenderIf condition={connector->getConnectorNameTypeFromString === BRAINTREE}>
          <h1
            className="flex items-center leading-6 text-orange-950 bg-orange-100 border w-fit p-2 rounded-md ">
            <div className="flex items-center text-orange-950 font-bold text-fs-14 mx-2">
              <Icon name="hswitch-warning" size=18 className="mr-2" />
              {"Disclaimer:"->React.string}
            </div>
            <div>
              {"Please ensure the payment currency matches the Braintree-configured currency for the given Merchant Account ID."->React.string}
            </div>
          </h1>
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={featureFlagDetails.businessProfile}>
          <BusinessProfileRender isUpdateFlow selectedConnector={connector} />
        </UIUtils.RenderIf>
        <div className="flex ">
          <div className="grid grid-cols-2 flex-1">
            <ConnectorConfigurationFields
              connector={connector->getConnectorNameTypeFromString}
              connectorAccountFields
              selectedConnector
              connectorMetaDataFields
              connectorWebHookDetails
              isUpdateFlow
              connectorLabelDetailField
            />
          </div>
          <IntegrationHelp.Render connector setShowModal showModal />
        </div>
        <FormValuesSpy />
        <VerifyConnectorModal
          showVerifyModal
          setShowVerifyModal
          connector
          verifyErrorMessage
          suggestedActionExists
          suggestedAction
          setVerifyDone
        />
      </div>
    </Form>
  </PageLoaderWrapper>
}
