open QuickStartTypes
open ConnectorTypes

@react.component
let make = (~connectProcessorValue: connectProcessor) => {
  open QuickStartUtils
  open APIUtils
  let updateDetails = useUpdateMethod()
  let usePostEnumDetails = EnumVariantHook.usePostEnumDetails()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {quickStartPageState, setQuickStartPageState, setDashboardPageState} = React.useContext(
    GlobalProvider.defaultContext,
  )
  let (key, setKey) = React.useState(_ => "")
  let enumDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.enumVariantAtom)
  let typedEnumValue = enumDetails->LogicUtils.safeParse->getTypedValueFromDict
  let activeBusinessProfile =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getValueFromBusinessProfile

  let (selectedConnector, setSelectedConnector) = React.useState(_ => UnknownConnector(""))
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->Js.Json.object_)
  let (connectorConfigureState, setConnectorConfigureState) = React.useState(_ => Select_processor)
  let (choiceState, setChoiceState) = React.useState(_ => #NotSelected)
  let (smartRoutingChoiceState, setSmartRoutingChoiceState) = React.useState(_ => #DefaultFallback)
  let (choiceStateForTestConnector, setChoiceStateForTestConnector) = React.useState(_ =>
    #TestApiKeys
  )

  let (connectorArray, setConnectorArray) = React.useState(_ =>
    typedEnumValue->getInitialValueForConnector
  )
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let updateEnumForRouting = async routingId => {
    try {
      let routingVal: routingType = {
        routing_id: routingId,
      }
      let enumVariant = quickStartPageState->variantToEnumMapper
      let _ = await RoutingType(routingVal)->usePostEnumDetails(enumVariant)
      setQuickStartPageState(_ => ConnectProcessor(CHECKOUT))
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to update!")
        Js.Exn.raiseError(err)
      }
    }
  }

  React.useEffect2(() => {
    setInitialValues(prevJson => {
      let prevJsonDict = prevJson->LogicUtils.getDictFromJsonObject
      prevJsonDict->Dict.set(
        "connector_label",
        `${selectedConnector->ConnectorUtils.getConnectorNameString}_${activeBusinessProfile.profile_name}`->Js.Json.string,
      )
      prevJsonDict->Js.Json.object_
    })

    None
  }, (selectedConnector, activeBusinessProfile.profile_name))

  let volumeBasedRoutingAPICall = async () => {
    try {
      open LogicUtils
      setButtonState(_ => Loading)
      let firstProcessorRoutingPayload: HSwitchSetupAccountUtils.routingData = {
        connector_name: typedEnumValue.firstProcessorConnected.processorName,
        merchant_connector_id: typedEnumValue.firstProcessorConnected.processorID,
      }
      let secondProcessorRoutingPayload: HSwitchSetupAccountUtils.routingData = {
        connector_name: typedEnumValue.secondProcessorConnected.processorName,
        merchant_connector_id: typedEnumValue.secondProcessorConnected.processorID,
      }
      let routingUrl = getURL(~entityName=ROUTING, ~methodType=Post, ~id=None, ())
      let body =
        activeBusinessProfile.profile_id->HSwitchSetupAccountUtils.routingPayload(
          firstProcessorRoutingPayload,
          secondProcessorRoutingPayload,
        )
      let routingResponse = await updateDetails(routingUrl, body, Post)
      let activatingId = routingResponse->getDictFromJsonObject->getString("id", "")
      let activateRuleURL = getURL(
        ~entityName=ROUTING,
        ~methodType=Post,
        ~id=Some(activatingId),
        (),
      )
      let _ = await updateDetails(activateRuleURL, Dict.make()->Js.Json.object_, Post)
      let _ = await updateEnumForRouting(activatingId)
      setButtonState(_ => Normal)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to update!")
        Js.Exn.raiseError(err)
      }
    }
  }

  let handleRouting = async () => {
    try {
      setButtonState(_ => Loading)
      if smartRoutingChoiceState === #DefaultFallback {
        let _ = await updateEnumForRouting("fallback")
      } else {
        let _ = await volumeBasedRoutingAPICall()
      }
      setButtonState(_ => Normal)
    } catch {
    | _ => setButtonState(_ => Normal)
    }
  }

  let updateEnumForMultipleConfigurationType = async connectorChoiceValue => {
    try {
      let configurationType = #ConfigurationType
      let _ = await StringEnumType(connectorChoiceValue)->usePostEnumDetails(configurationType)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to update!")
        Js.Exn.raiseError(err)
      }
    }
  }
  let handleConnectorChoiceClick = async () => {
    try {
      setButtonState(_ => Loading)
      if choiceState === #MultipleProcessorWithSmartRouting {
        let _ = await updateEnumForMultipleConfigurationType(
          #MultipleProcessorWithSmartRouting->connectorChoiceVariantToString,
        )
        setQuickStartPageState(_ =>
          typedEnumValue.firstProcessorConnected.processorID->String.length > 0
            ? ConnectProcessor(CONFIGURE_SECONDARY)
            : ConnectProcessor(CONFIGURE_PRIMARY)
        )
      } else {
        let _ = await updateEnumForMultipleConfigurationType(
          #SinglePaymentProcessor->connectorChoiceVariantToString,
        )
        setQuickStartPageState(_ =>
          typedEnumValue.firstProcessorConnected.processorID->String.length > 0
            ? ConnectProcessor(CHECKOUT)
            : ConnectProcessor(CONFIGURE_PRIMARY)
        )
      }
      setButtonState(_ => Normal)
    } catch {
    | _ => setButtonState(_ => Normal)
    }
  }

  let updateTestPaymentEnum = async (~paymentId) => {
    try {
      let paymentBody: paymentType = {
        payment_id: paymentId->Belt.Option.getWithDefault("pay_default"),
      }
      let _ = await PaymentType(paymentBody)->usePostEnumDetails(#TestPayment)
      setQuickStartPageState(_ => IntegrateApp(LANDING))
      RescriptReactRouter.replace("/quick-start")
      if paymentId->Option.isSome {
        mixpanelEvent(~eventName=`quickstart_checkout_pay`, ())
      } else {
        mixpanelEvent(~eventName=`quickstart_checkout_skip`, ())
      }
    } catch {
    | _ => ()
    }
  }

  React.useEffect0(() => {
    setKey(_ => Js.Date.now()->Js.Float.toString)
    None
  })

  <>
    {switch connectProcessorValue {
    | LANDING =>
      <div className="h-full flex-1 flex flex-col items-center justify-center">
        <QuickStartUIUtils.LandingPageChoice
          choiceState
          setChoiceState
          headerText="How would you like to configure Hyperswitch?"
          listChoices={connectorChoiceArray}
          nextButton={<Button
            buttonType=Primary
            text="Proceed"
            onClick={_ => {
              mixpanelEvent(~eventName=`quickstart_landing`, ())
              handleConnectorChoiceClick()->ignore
            }}
            buttonSize=Small
            buttonState
          />}
          backButton={<Button
            buttonType={PrimaryOutline}
            text="Exit to Homepage"
            onClick={_ => {
              setDashboardPageState(_ => #HOME)
              RescriptReactRouter.replace("/home")
            }}
            buttonSize=Small
          />}
        />
      </div>

    | CONFIGURE_PRIMARY | CONFIGURE_SECONDARY =>
      <div className="flex h-full">
        <HSSelfServeSidebar
          heading="Configure Control Centre"
          sidebarOptions={enumDetails->getSidebarOptionsForConnectProcessor(
            quickStartPageState,
            connectorConfigureState,
            choiceStateForTestConnector,
          )}
        />
        <div className="flex-1 flex flex-col items-center justify-center ml-12">
          <QuickStartConnectorFlow
            connectorConfigureState
            selectedConnector
            setSelectedConnector
            setConnectorConfigureState
            setInitialValues
            initialValues
            connectorArray
            setConnectorArray
            choiceStateForTestConnector
            setChoiceStateForTestConnector
          />
        </div>
      </div>

    | CONFIGURE_SMART_ROUTING =>
      <div className="flex h-full">
        <HSSelfServeSidebar
          heading="Configure Control Centre"
          sidebarOptions={enumDetails->getSidebarOptionsForConnectProcessor(
            quickStartPageState,
            connectorConfigureState,
            choiceStateForTestConnector,
          )}
        />
        <div className="flex-1 flex flex-col items-center justify-center ml-12">
          <QuickStartUIUtils.LandingPageChoice
            choiceState=smartRoutingChoiceState
            setChoiceState=setSmartRoutingChoiceState
            headerText="Configure Smart Routing"
            listChoices={getSmartRoutingConfigurationText}
            nextButton={<Button
              buttonType=Primary
              text="Proceed"
              onClick={_ => {
                mixpanelEvent(~eventName=`quickstart_configure_smart_routing`, ())
                handleRouting()->ignore
              }}
              buttonSize=Small
              buttonState
            />}
          />
        </div>
      </div>

    | CHECKOUT =>
      <div className="flex h-full">
        <HSSelfServeSidebar
          heading="Configure Control Centre"
          sidebarOptions={enumDetails->getSidebarOptionsForConnectProcessor(
            quickStartPageState,
            connectorConfigureState,
            choiceStateForTestConnector,
          )}
        />
        <div className="flex-1 flex flex-col items-center justify-center">
          <QuickStartUIUtils.BaseComponent
            headerText="Preview Checkout page"
            nextButton={<Button
              text="Skip this step"
              buttonSize={Small}
              buttonType={PrimaryOutline}
              customButtonStyle="!rounded-md"
              onClick={_ => {
                updateTestPaymentEnum(~paymentId=None)->ignore
              }}
            />}>
            <TestPayment
              initialValues={activeBusinessProfile->SDKPaymentUtils.initialValueForForm}
              returnUrl={`${HSwitchGlobalVars.hyperSwitchFEPrefix}/quick-start`}
              onProceed={updateTestPaymentEnum}
              keyValue=key
              sdkWidth="w-full"
              paymentStatusStyles="p-0"
            />
          </QuickStartUIUtils.BaseComponent>
        </div>
      </div>
    }}
  </>
}
