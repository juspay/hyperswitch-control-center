@react.component
let make = (
  ~connectorConfigureState,
  ~selectedConnector,
  ~setSelectedConnector,
  ~setConnectorConfigureState,
  ~setInitialValues,
  ~initialValues,
  ~connectorArray,
  ~setConnectorArray,
  ~choiceStateForTestConnector,
  ~setChoiceStateForTestConnector,
) => {
  open QuickStartUtils
  open APIUtils
  open ConnectorTypes
  open QuickStartTypes

  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let usePostEnumDetails = EnumVariantHook.usePostEnumDetails()
  let enumDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.enumVariantAtom)
  let typedEnumValue = enumDetails->LogicUtils.safeParse->getTypedValueFromDict

  let {quickStartPageState, setQuickStartPageState} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let activeBusinessProfile =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getValueFromBusinessProfile
  let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString

  // TO determine if the connector connected are multiple
  let multipleConfigurationArrayLength = 2

  let handleSummaryProceed = () => {
    mixpanelEvent(~eventName=`quickstart_connector_summary`, ())
    if (
      connectorArray->Array.length === multipleConfigurationArrayLength &&
        typedEnumValue.configurationType->connectorChoiceStringVariantMapper ===
          #MultipleProcessorWithSmartRouting
    ) {
      setQuickStartPageState(_ => ConnectProcessor(CONFIGURE_SMART_ROUTING))
    } else if (
      typedEnumValue.configurationType->connectorChoiceStringVariantMapper ===
        #SinglePaymentProcessor
    ) {
      setQuickStartPageState(_ => QuickStartTypes.ConnectProcessor(QuickStartTypes.CHECKOUT))
    } else {
      setSelectedConnector(_ => UnknownConnector(""))
      setInitialValues(_ => Dict.make()->Js.Json.object_)
      setConnectorConfigureState(_ => Select_processor)
      setQuickStartPageState(_ => ConnectProcessor(CONFIGURE_SECONDARY))
    }
    setChoiceStateForTestConnector(_ => #TestApiKeys)
  }
  let updateEnumForTestConnector = async connectorResponse => {
    open LogicUtils
    try {
      let processorVal: processorType = {
        processorID: connectorResponse->getString("merchant_connector_id", ""),
        processorName: connectorResponse->getString("connector_name", ""),
      }
      let enumVariant = quickStartPageState->variantToEnumMapper
      let _ = await ProcesorType(processorVal)->usePostEnumDetails(enumVariant)
      setButtonState(_ => Normal)
    } catch {
    | _ =>
      showToast(~message="Step already set", ~toastType=ToastError, ())
      setButtonState(_ => Normal)
    }
  }

  let handleTestConnector = async _ => {
    try {
      setButtonState(_ => Loading)
      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ())
      let connectorName =
        selectedConnector->QuickStartUtils.getTestConnectorName(quickStartPageState)
      let testConnectorBody = HSwitchSetupAccountUtils.constructBody(
        ~connectorName,
        ~json=connectorName->Window.getConnectorConfig,
        ~profileId=activeBusinessProfile.profile_id,
      )
      let res = await updateDetails(url, testConnectorBody, Post)
      connectorArray->Array.push(connectorName)
      setConnectorArray(_ => connectorArray)
      setInitialValues(_ => res)
      setSelectedConnector(_ => connectorName->ConnectorUtils.getConnectorNameTypeFromString)
      setConnectorConfigureState(_ => Summary)
      updateEnumForTestConnector(res->LogicUtils.getDictFromJsonObject)->ignore
      showToast(
        ~message=`${connectorName->LogicUtils.getFirstLetterCaps()} connected successfully!`,
        ~toastType=ToastSuccess,
        (),
      )
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      showToast(~message=err, ~toastType=ToastError, ())
      setButtonState(_ => Normal)
    }
  }

  let handleConnectorSubmit = () => {
    if choiceStateForTestConnector === #TestApiKeys {
      mixpanelEvent(~eventName=`quickstart_select_configuration_type_test`, ())
      handleTestConnector()->ignore
    } else {
      setConnectorConfigureState(_ => Configure_keys)
      mixpanelEvent(~eventName=`quickstart_select_configuration_type_keys`, ())
    }
  }

  React.useEffect1(() => {
    let defaultJsonOnNewConnector =
      [("profile_id", activeBusinessProfile.profile_id->Js.Json.string)]
      ->Dict.fromArray
      ->Js.Json.object_
    setInitialValues(_ => defaultJsonOnNewConnector)
    None
  }, [activeBusinessProfile.profile_id, connectorName])

  <div className="w-full h-full flex items-center justify-center">
    {switch connectorConfigureState {
    | Select_processor =>
      <SetupConnector.SelectProcessor
        selectedConnector setSelectedConnector setConnectorConfigureState connectorArray
      />
    | Select_configuration_type =>
      <QuickStartUIUtils.LandingPageChoice
        choiceState={choiceStateForTestConnector}
        setChoiceState={setChoiceStateForTestConnector}
        listChoices={selectedConnector->getTypeOfConfigurationArray}
        headerText={`Connect ${connectorName->LogicUtils.capitalizeString}`}
        isHeaderLeftIcon=false
        customIcon={<GatewayIcon
          gateway={connectorName->String.toUpperCase} className="w-6 h-6 rounded-md"
        />}
        nextButton={<Button
          buttonType=Primary
          text="Proceed"
          buttonState
          onClick={_ => {
            handleConnectorSubmit()
          }}
          buttonSize=Small
        />}
        backButton={<Button
          buttonType={PrimaryOutline}
          text="Back"
          onClick={_ => setConnectorConfigureState(_ => Select_processor)}
          buttonSize=Small
        />}
      />
    | Configure_keys =>
      <SetupConnector.ConfigureProcessor
        selectedConnector initialValues setInitialValues setConnectorConfigureState
      />
    | Setup_payment_methods =>
      <SetupConnector.SelectPaymentMethods
        initialValues
        selectedConnector
        setInitialValues
        setConnectorConfigureState
        setConnectorArray
        connectorArray
        buttonState
        setButtonState
      />
    | Summary =>
      <QuickStartUIUtils.BaseComponent
        headerText={connectorName->LogicUtils.capitalizeString}
        customIcon={<GatewayIcon
          gateway={connectorName->String.toUpperCase} className="w-6 h-6 rounded-md"
        />}
        customCss="show-scrollbar"
        nextButton={<Button
          text="Proceed"
          buttonSize=Small
          buttonState
          customButtonStyle="rounded-md"
          buttonType={Primary}
          onClick={_ => handleSummaryProceed()}
        />}>
        <ConnectorPreview.ConnectorSummaryGrid
          connectorInfo={initialValues
          ->LogicUtils.getDictFromJsonObject
          ->ConnectorTableUtils.getProcessorPayloadType}
          connector=connectorName
          setScreenState={_ => ()}
          isPayoutFlow=false
        />
      </QuickStartUIUtils.BaseComponent>
    }}
  </div>
}
