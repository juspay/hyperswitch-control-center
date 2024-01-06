let headerTextStyle = "text-xl font-semibold text-grey-700"
let subTextStyle = "text-base font-normal text-grey-700 opacity-50"
let dividerColor = "bg-grey-700 bg-opacity-20 h-px w-full"

module ConnectorDetailsForm = {
  open ConnectorUtils
  @react.component
  let make = (
    ~connectorName,
    ~connectorDetails,
    ~isCheckboxSelected,
    ~setIsCheckboxSelected,
    ~setVerifyDone,
    ~verifyErrorMessage,
    ~checkboxText,
  ) => {
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)

    let (
      _,
      connectorAccountFields,
      connectorMetaDataFields,
      _,
      connectorWebHookDetails,
      connectorLabelDetailField,
    ) = getConnectorFields(connectorDetails)
    let connectorVariant = connectorName->getConnectorNameTypeFromString

    let selectedConnector = React.useMemo1(() => {
      connectorVariant->getConnectorInfo
    }, [connectorName])

    let (suggestedAction, suggestedActionExists) = ConnectorUtils.getSuggestedAction(
      ~verifyErrorMessage,
      ~connector={connectorName},
    )

    <div className="flex flex-col gap-6">
      <UIUtils.RenderIf condition={featureFlagDetails.businessProfile}>
        <div>
          <ConnectorAccountDetailsHelper.BusinessProfileRender
            isUpdateFlow=false selectedConnector={connectorName}
          />
        </div>
      </UIUtils.RenderIf>
      <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
        connectorAccountFields
        connector={connectorName->getConnectorNameTypeFromString}
        selectedConnector
        connectorMetaDataFields
        connectorWebHookDetails
        connectorLabelDetailField
      />
      <ConnectorAccountDetailsHelper.VerifyConnectorModal
        showVerifyModal
        setShowVerifyModal
        connector={connectorName}
        verifyErrorMessage
        suggestedActionExists
        suggestedAction
        setVerifyDone
      />
      <UIUtils.RenderIf condition={checkboxText->String.length > 0}>
        <div className="flex gap-2 items-center">
          <CheckBoxIcon
            isSelected=isCheckboxSelected
            setIsSelected={_ => setIsCheckboxSelected(_ => !isCheckboxSelected)}
          />
          <p className=subTextStyle>
            {connectorVariant->ProdOnboardingUtils.getCheckboxText->React.string}
          </p>
        </div>
      </UIUtils.RenderIf>
    </div>
  }
}

@react.component
let make = (~selectedConnector, ~pageView, ~setPageView, ~setConnectorID) => {
  open LogicUtils
  open ProdOnboardingTypes
  open ConnectorUtils
  open APIUtils
  let showToast = ToastState.useShowToast()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isCheckboxSelected, setIsCheckboxSelected) = React.useState(_ => false)
  let connectorVariant = connectorName->getConnectorNameTypeFromString
  // TODO: Change the state to memo
  let (connectorDetails, setConnectorDetails) = React.useState(_ => Js.Json.null)
  let (isLoading, setIsLoading) = React.useState(_ => false)
  let merchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")
  let (initialValues, setInitialValues) = React.useState(_ => Js.Json.null)

  let getDetails = async () => {
    try {
      let _ = await Window.connectorWasmInit()
      let val = connectorName->Window.getConnectorConfig
      setConnectorDetails(_ => val)
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let (showVerifyModal, setShowVerifyModal) = React.useState(_ => false)
  let (verifyErrorMessage, setVerifyErrorMessage) = React.useState(_ => None)
  let (verifyDone, setVerifyDone) = React.useState(_ => ConnectorTypes.NoAttempt)

  let connectorID = url.path->Belt.List.toArray->Belt.Array.get(1)->Belt.Option.getWithDefault("")
  let checkboxText = connectorVariant->ProdOnboardingUtils.getCheckboxText
  let (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
  ) = getConnectorFields(connectorDetails)
  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile

  let (suggestedAction, suggestedActionExists) = getSuggestedAction(
    ~verifyErrorMessage,
    ~connector={connectorName},
  )

  React.useEffect1(() => {
    setInitialValues(prevJson => {
      let prevJsonDict = prevJson->LogicUtils.getDictFromJsonObject
      prevJsonDict->Dict.set(
        "connector_label",
        `${selectedConnector->ConnectorUtils.getConnectorNameString}_${defaultBusinessProfile.profile_name}`->Js.Json.string,
      )
      prevJsonDict->Dict.set("profile_id", defaultBusinessProfile.profile_id->Js.Json.string)
      prevJsonDict->Js.Json.object_
    })

    None
  }, [selectedConnector])

  let {profile_id} =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getValueFromBusinessProfile

  let updateSetupConnectorCredentials = async connectorId => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#MERCHANT_DATA, ~methodType=Post, ())
      let body = ProdOnboardingUtils.getProdApiBody(
        ~parentVariant=#SetupProcessor,
        ~connectorId,
        (),
      )
      let _ = await updateDetails(url, body, Post)
      setPageView(_ => pageView->ProdOnboardingUtils.getPageView)
    } catch {
    | _ => ()
    }
  }

  let onSubmitMain = async (values: Js.Json.t) => {
    try {
      setIsLoading(_ => true)
      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ())
      let dict = Window.getConnectorConfig(connectorName)->getDictFromJsonObject
      let creditCardNetworkArray =
        dict->getArrayFromDict("credit", [])->Js.Json.array->getPaymentMethodMapper
      let debitCardNetworkArray =
        dict->getArrayFromDict("debit", [])->Js.Json.array->getPaymentMethodMapper

      let paymentMethodsEnabledArray: array<ConnectorTypes.paymentMethodEnabled> = [
        {
          payment_method: "card",
          payment_method_type: "credit",
          provider: [],
          card_provider: creditCardNetworkArray,
        },
        {
          payment_method: "card",
          payment_method_type: "debit",
          provider: [],
          card_provider: debitCardNetworkArray,
        },
      ]

      let requestPayload: ConnectorTypes.wasmRequest = {
        payment_methods_enabled: paymentMethodsEnabledArray,
        connector: connectorName,
        metadata: Dict.make()->Js.Json.object_,
      }

      let payload = generateInitialValuesDict(
        ~values,
        ~connector=connectorName,
        ~bodyType,
        ~isLiveMode={featureFlagDetails.isLiveMode},
        (),
      )

      let body = requestPayload->ConnectorUtils.constructConnectorRequestBody(payload)

      let res = await updateDetails(url, body, Post)
      let connectorId = res->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorID(_ => connectorId)
      connectorId->updateSetupConnectorCredentials->ignore
      setIsLoading(_ => false)
    } catch {
    | Js.Exn.Error(e) => {
        setIsLoading(_ => false)
        setShowVerifyModal(_ => false)
        setVerifyDone(_ => ConnectorTypes.NoAttempt)
        setPageView(_ => SELECT_PROCESSOR)
        switch Js.Exn.message(e) {
        | Some(message) =>
          if message->String.includes("HE_01") {
            showToast(
              ~message="This configuration already exists for the connector. Please try with a different country or label under advanced settings.",
              ~toastType=ToastState.ToastError,
              (),
            )
            setScreenState(_ => Success)
          } else {
            showToast(
              ~message="Failed to Save the Configuration!",
              ~toastType=ToastState.ToastError,
              (),
            )
            setScreenState(_ => Error(message))
          }

        | None => setScreenState(_ => Error("Failed to Fetch!"))
        }
      }
    }
  }
  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)

    validateConnectorRequiredFields(
      connectorName->getConnectorNameTypeFromString,
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->Js.Json.object_,
    )
  }

  let onSubmitVerify = async values => {
    try {
      setIsLoading(_ => true)
      let body =
        generateInitialValuesDict(
          ~values,
          ~connector={connectorName},
          ~bodyType,
          ~isPayoutFlow=false,
          ~isLiveMode={featureFlagDetails.isLiveMode},
          (),
        )->ignoreFields(connectorID, verifyConnectorIgnoreField)

      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ~connector=Some(connectorName), ())
      let _ = await updateDetails(url, body, Post)
      setShowVerifyModal(_ => false)
      onSubmitMain(values)->ignore
      setIsLoading(_ => false)
    } catch {
    | Js.Exn.Error(e) =>
      setIsLoading(_ => false)
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

  React.useEffect0(() => {
    getDetails()->ignore
    None
  })
  let getHeaderTextofPage = () =>
    switch pageView {
    | SETUP_CREDS => `Setup ${connectorName->capitalizeString} credentials`
    | SETUP_WEBHOOK_PROCESSOR => `Setup Webhooks on ${connectorName->capitalizeString}`
    | _ => ""
    }
  let getSubTextOfPage = () =>
    switch pageView {
    | SETUP_CREDS => "Start by providing your live credentials"
    | SETUP_WEBHOOK_PROCESSOR =>
      `Enable relevant webhooks on your ${connectorName->capitalizeString} account`
    | _ => ""
    }

  let getComponentToRender = () => {
    let warningBlock = connectorVariant->ProdOnboardingUtils.getWarningBlockForConnector
    switch pageView {
    | SETUP_CREDS =>
      <>
        <UIUtils.RenderIf condition={warningBlock->Belt.Option.isSome}>
          <ProdOnboardingUIUtils.WarningBlock customComponent={warningBlock} />
        </UIUtils.RenderIf>
        <ConnectorDetailsForm
          connectorName
          connectorDetails
          isCheckboxSelected
          setIsCheckboxSelected
          setVerifyDone
          verifyErrorMessage
          checkboxText
        />
      </>
    | SETUP_WEBHOOK_PROCESSOR =>
      <ProdOnboardingUIUtils.SetupWebhookProcessor
        connectorName
        headerSectionText="Hyperswitch Webhook Endpoint"
        subtextSectionText="Configure this endpoint in the processors dashboard under webhook settings for us to receive events"
        customRightSection={<HelperComponents.KeyAndCopyArea
          copyValue={getWebhooksUrl(~connectorName, ~merchantId)}
          shadowClass="shadow shadow-hyperswitch_box_shadow !w-full"
        />}
      />
    | _ => <> </>
    }
  }

  let onSubmit = values => {
    let dict = values->getDictFromJsonObject
    dict->Dict.set("profile_id", profile_id->Js.Json.string)

    ConnectorUtils.onSubmit(
      ~values={dict->Js.Json.object_},
      ~onSubmitVerify,
      ~onSubmitMain,
      ~setVerifyDone,
      ~verifyDone,
      ~isVerifyConnector,
      ~isVerifyConnectorFeatureEnabled=featureFlagDetails.verifyConnector,
    )->ignore
  }

  let handleSubmit = (values, _) => {
    switch pageView {
    | SETUP_WEBHOOK_PROCESSOR => values->onSubmit
    | _ => setPageView(_ => pageView->ProdOnboardingUtils.getPageView)
    }
    Js.Nullable.null->Promise.resolve
  }

  let buttonText = switch verifyDone {
  | NoAttempt => "Connect and Proceed"
  | Failure => "Try Again"
  | _ => "Loading..."
  }

  <PageLoaderWrapper screenState>
    <Form initialValues onSubmit={handleSubmit} validate={validateMandatoryField}>
      <div className="flex flex-col h-full w-full ">
        <div className="flex justify-between px-11 py-8 flex-wrap gap-4">
          <div className="flex gap-4 items-center">
            <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-8 h-8" />
            <p className=headerTextStyle> {connectorName->capitalizeString->React.string} </p>
          </div>
          <div className="flex gap-4">
            <Button
              text="Back"
              buttonSize={Small}
              buttonState={isLoading ? Disabled : Normal}
              buttonType={PrimaryOutline}
              customButtonStyle="!rounded-md"
              onClick={_ => {
                setPageView(_ => pageView->ProdOnboardingUtils.getBackPageView)
              }}
            />
            <FormRenderer.SubmitButton
              text=buttonText
              customSumbitButtonStyle="!rounded-md"
              loadingText={isLoading ? "Loading ..." : ""}
              disabledParamter={checkboxText->String.length > 0 && !isCheckboxSelected}
            />
          </div>
        </div>
        <div className={`${dividerColor}`} />
        <div className="flex flex-col gap-8 p-11 ">
          <div className="flex flex-col gap-2 ">
            <p className=headerTextStyle> {getHeaderTextofPage()->React.string} </p>
            <p className=subTextStyle> {getSubTextOfPage()->React.string} </p>
          </div>
          {getComponentToRender()}
        </div>
      </div>
      <ConnectorAccountDetailsHelper.VerifyConnectorModal
        showVerifyModal
        setShowVerifyModal
        connector={connectorName}
        verifyErrorMessage
        suggestedActionExists
        suggestedAction
        setVerifyDone
      />
      <FormValuesSpy />
    </Form>
  </PageLoaderWrapper>
}
