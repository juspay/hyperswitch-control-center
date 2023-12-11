external formEventToBool: ReactEvent.Form.t => bool = "%identity"

let connectorsWithIntegrationSteps: array<ConnectorTypes.connectorName> = [
  ADYEN,
  CHECKOUT,
  STRIPE,
  PAYPAL,
]

let mixpanelEventWrapper = (
  ~url: RescriptReactRouter.url,
  ~selectedConnector,
  ~actionName,
  ~hyperswitchMixPanel: HSMixPanel.functionType,
) => {
  if selectedConnector->Js.String2.length > 0 {
    [selectedConnector, "global"]->Js.Array2.forEach(ele =>
      hyperswitchMixPanel(
        ~pageName=url.path->LogicUtils.getListHead,
        ~contextName=ele,
        ~actionName,
        (),
      )
    )
  }
}

module BusinessProfileRender = {
  @react.component
  let make = (~isUpdateFlow: bool, ~selectedConnector) => {
    let url = RescriptReactRouter.useUrl()
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
    let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)

    let arrayOfBusinessProfile = businessProfiles->MerchantAccountUtils.getArrayOfBusinessProfile

    let (showModalFromOtherScreen, setShowModalFromOtherScreen) = React.useState(_ => false)

    let hereTextStyle = isUpdateFlow
      ? "text-grey-700 opacity-50 cursor-not-allowed"
      : "text-blue-900  cursor-pointer"
    let _onClickHandler = countryOrLabel => {
      if !isUpdateFlow {
        setShowModalFromOtherScreen(_ => true)
        mixpanelEventWrapper(
          ~url,
          ~selectedConnector,
          ~actionName=`add_new_${countryOrLabel}`,
          ~hyperswitchMixPanel,
        )
      }
      setDashboardPageState(_ => #HOME)
    }

    <>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-black"
        field={FormRenderer.makeFieldInfo(
          ~label="Profile",
          ~isRequired=true,
          ~name="profile_id",
          ~customInput=(~input, ~placeholder as _) =>
            InputFields.selectInput(
              ~input={
                ...input,
                onChange: {
                  ev => {
                    input.onChange(ev)
                    mixpanelEventWrapper(
                      ~url,
                      ~selectedConnector,
                      ~actionName=`settings_choose_country`,
                      ~hyperswitchMixPanel,
                    )
                  }
                },
              },
              ~deselectDisable=true,
              ~disableSelect=isUpdateFlow,
              ~customStyle="max-h-48",
              ~options={
                arrayOfBusinessProfile->MerchantAccountUtils.businessProfileNameDropDownOption
              },
              ~buttonText="Select Country",
              ~placeholder="",
              (),
            ),
          (),
        )}
      />
      <UIUtils.RenderIf condition={!isUpdateFlow}>
        <div className="text-gray-400 text-sm mt-3">
          <span> {"Manage your list of business units"->React.string} </span>
          <span
            className={`ml-1 ${hereTextStyle}`}
            onClick={_ => {
              setDashboardPageState(_ => #HOME)
              RescriptReactRouter.push("/business-profiles")
            }}>
            {React.string("here.")}
          </span>
        </div>
      </UIUtils.RenderIf>
      <BusinessProfile isFromSettings=false showModalFromOtherScreen setShowModalFromOtherScreen />
    </>
  }
}

module VerifyConnectoModal = {
  @react.component
  let make = (
    ~showVerifyModal,
    ~setShowVerifyModal,
    ~connector,
    ~verifyErrorMessage,
    ~suggestedActionExists,
    ~suggestedAction,
    ~setVerifyDone,
  ) => {
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    <Modal
      showModal={showVerifyModal}
      setShowModal={setShowVerifyModal}
      modalClass="w-full md:w-5/12 mx-auto top-1/3 relative"
      childClass="p-0 m-0 -mt-8"
      customHeight="border-0 h-fit"
      showCloseIcon=false
      modalHeading=" "
      headingClass="h-2 bg-orange-960 rounded-t-xl"
      onCloseClickCustomFun={_ => {
        setVerifyDone(_ => NoAttempt)
        setShowVerifyModal(_ => false)
      }}>
      <div>
        <div className="flex flex-col mb-2 p-2 m-2">
          <div className="flex p-3">
            <img
              className="w-12 h-12 my-auto border-gray-100 w-fit mt-0"
              src={`/icons/warning.svg`}
              alt="warning"
            />
            <div className="text-jp-gray-900">
              <div
                className="font-semibold ml-4 text-xl px-2 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
                {"Are you sure you want to proceed?"->React.string}
              </div>
              <div
                className="whitespace-pre-line break-all flex flex-col gap-1  p-2 ml-4 text-base dark:text-jp-gray-text_darktheme dark:text-opacity-50 font-medium leading-7 opacity-50">
                {`Received the following error from ${connector->LogicUtils.snakeToTitle}:`->React.string}
              </div>
              <div
                className="whitespace-pre-line break-all flex flex-col gap-1 p-4 ml-6 text-base dark:text-jp-gray-text_darktheme dark:text-opacity-50 bg-red-50 rounded-md font-semibold">
                {`${verifyErrorMessage->Belt.Option.getWithDefault("")}`->React.string}
              </div>
              <UIUtils.RenderIf condition={suggestedActionExists}>
                {suggestedAction}
              </UIUtils.RenderIf>
            </div>
          </div>
          <div className="flex flex-row justify-end gap-5 mt-4 mb-2 p-3">
            <FormRenderer.SubmitButton
              buttonType={Button.Secondary} loadingText="Processing..." text="Proceed Anyway"
            />
            <Button
              text="Cancel"
              onClick={_ => {
                hyperswitchMixPanel(
                  ~pageName=url.path->LogicUtils.getListHead,
                  ~contextName="verify_connector",
                  ~actionName="cancel_clicked",
                  (),
                )
                setVerifyDone(_ => ConnectorTypes.NoAttempt)
                setShowVerifyModal(_ => false)
              }}
              buttonType={Primary}
              buttonSize={Small}
            />
          </div>
        </div>
      </div>
    </Modal>
  }
}

@react.component
let make = (
  ~currentStep,
  ~setCurrentStep,
  ~setInitialValues,
  ~initialValues,
  ~isUpdateFlow,
  ~isPayoutFlow,
) => {
  open ConnectorUtils
  open APIUtils
  open ConnectorAccountDetailsHelper
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
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
    mixpanelEventWrapper(
      ~url,
      ~selectedConnector=connector,
      ~actionName=`${isUpdateFlow ? "settings_entry_updateflow" : "settings_entry"}`,
      ~hyperswitchMixPanel,
    )
    None
  }, [connector])

  React.useEffect1(() => {
    if !isUpdateFlow {
      let defaultJsonOnNewConnector =
        [("profile_id", activeBusinessProfile.profile_id->Js.Json.string)]
        ->Js.Dict.fromArray
        ->Js.Json.object_
      setInitialValues(_ => defaultJsonOnNewConnector)
    }
    None
  }, [activeBusinessProfile.profile_id])

  let connectorDetails = React.useMemo1(() => {
    try {
      if connector->Js.String2.length > 0 {
        let dict = isPayoutFlow
          ? Window.getPayoutConnectorConfig(connector)
          : Window.getConnectorConfig(connector)
        setScreenState(_ => Success)
        dict
      } else {
        Js.Dict.empty()->Js.Json.object_
      }
    } catch {
    | Js.Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Js.Dict.empty()->Js.Json.object_
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
    if (
      connector
      ->getConnectorNameTypeFromString
      ->checkIsDummyConnector(featureFlagDetails.testProcessors) && !isUpdateFlow
    ) {
      let initialValuesToDict = initialValues->LogicUtils.getDictFromJsonObject
      let apiKeyDict = [("api_key", "test_key"->Js.Json.string)]->Js.Dict.fromArray
      initialValuesToDict->Js.Dict.set("connector_account_details", apiKeyDict->Js.Json.object_)

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
      getMixpanelForConnectorOnSubmit(
        ~connectorName=connector,
        ~currentStep,
        ~isUpdateFlow,
        ~url,
        ~hyperswitchMixPanel,
      )
      setCurrentStep(_ => isPayoutFlow ? PaymentMethods : Webhooks)
      setScreenState(_ => Success)
      setInitialValues(_ => body)
    } catch {
    | Js.Exn.Error(e) => {
        setShowVerifyModal(_ => false)
        setVerifyDone(_ => ConnectorTypes.NoAttempt)
        switch Js.Exn.message(e) {
        | Some(message) => {
            let errMsg = message->parseIntoMyData
            if errMsg.code->Belt.Option.getWithDefault("")->Js.String2.includes("HE_01") {
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
          hyperswitchMixPanel(
            ~isApiFailure=true,
            ~apiUrl=`/verify_connector`,
            ~description=errorMessage->Js.Json.stringifyAny,
            (),
          )
        }

      | None => setScreenState(_ => Error("Failed to Fetch!"))
      }
    }
  }

  let validateMandatoryField = values => {
    let errors = Js.Dict.empty()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
    let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
    if profileId->Js.String2.length === 0 {
      Js.Dict.set(errors, "Profile Id", `Please select your business profile`->Js.Json.string)
    }

    validateConnectorRequiredFields(
      bodyType,
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
          ~hyperswitchMixPanel,
          ~path={url.path},
          ~isVerifyConnectorFeatureEnabled=featureFlagDetails.verifyConnector,
        )}
      validate={validateMandatoryField}
      formClass="flex flex-col ">
      <div className="flex items-center justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon gateway={connector->Js.String2.toUpperCase} />
          <h2 className="text-xl font-semibold">
            {connector->LogicUtils.capitalizeString->React.string}
          </h2>
        </div>
        <div className="flex flex-row mt-6 md:mt-0 md:justify-self-end h-min">
          <UIUtils.RenderIf
            condition={connectorsWithIntegrationSteps->Js.Array2.includes(
              connector->getConnectorNameTypeFromString,
            )}>
            <a
              className={`flex cursor-pointer px-4 py-3 flex text-sm text-blue-900 items-center mx-4`}
              target="_blank"
              onClick={_ => {
                hyperswitchMixPanel(
                  ~pageName=url.path->LogicUtils.getListHead,
                  ~contextName="integration_steps",
                  ~actionName="modal_open",
                  (),
                )
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
              bodyType
              isUpdateFlow
              connectorLabelDetailField
            />
          </div>
          <IntegrationHelp.Render connector setShowModal showModal />
        </div>
        <FormValuesSpy />
        <VerifyConnectoModal
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
