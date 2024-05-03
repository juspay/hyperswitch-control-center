open StripePlusPaypalUtils
module SelectPaymentMethods = {
  open QuickStartTypes
  open ConnectorTypes

  @react.component
  let make = (
    ~selectedConnector,
    ~initialValues,
    ~setInitialValues,
    ~setConnectorConfigureState,
    ~setButtonState: (Button.buttonState => Button.buttonState) => unit,
    ~buttonState,
  ) => {
    let updateEnumInRecoil = EnumVariantHook.useUpdateEnumInRecoil()
    let enumDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.enumVariantAtom)
    let enums = enumDetails->LogicUtils.safeParse->QuickStartUtils.getTypedValueFromDict
    let updateAPIHook = APIUtils.useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let postEnumDetails = EnumVariantHook.usePostEnumDetails()
    let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString

    let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
      Dict.make()->JSON.Encode.object->ConnectorUtils.getPaymentMethodEnabled
    )
    let (metaData, setMetaData) = React.useState(_ => Dict.make()->JSON.Encode.object)

    let updateDetails = value => {
      setPaymentMethods(_ => value->Array.copy)
    }

    let updateEnumForMultipleConfigurationType = async connectorChoiceValue => {
      try {
        let configurationType = #ConfigurationType
        let _ = await StringEnumType(connectorChoiceValue)->postEnumDetails(configurationType)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Failed to update!")
          Exn.raiseError(err)
        }
      }
    }

    let updateEnumForConnector = async connectorResponse => {
      open LogicUtils
      let enums = enumDetails->LogicUtils.safeParse->QuickStartUtils.getTypedValueFromDict

      try {
        let processorVal: processorType = {
          processorID: connectorResponse->getString("merchant_connector_id", ""),
          processorName: connectorResponse->getString("connector_name", ""),
        }
        let body = ProcesorType(processorVal)

        let enumRecoilUpdateArr = []
        if enums.firstProcessorConnected.processorID->String.length === 0 {
          let _ = await body->postEnumDetails(#FirstProcessorConnected)
          enumRecoilUpdateArr->Array.push((body, #FirstProcessorConnected))
        } else if enums.secondProcessorConnected.processorID->String.length === 0 {
          let _ = await body->postEnumDetails(#SecondProcessorConnected)
          enumRecoilUpdateArr->Array.push((body, #SecondProcessorConnected))
        }

        {
          switch selectedConnector {
          | Processors(STRIPE) => enumRecoilUpdateArr->Array.push((body, #StripeConnected))
          | Processors(PAYPAL) => enumRecoilUpdateArr->Array.push((body, #PaypalConnected))
          | _ => ()
          }
        }

        let _ = updateEnumInRecoil(enumRecoilUpdateArr)
      } catch {
      | _ => setButtonState(_ => Button.Normal)
      }
    }

    let onSubmitMain = async () => {
      setButtonState(_ => Loading)
      try {
        let obj: ConnectorTypes.wasmRequest = {
          connector: connectorName,
          payment_methods_enabled: paymentMethodsEnabled,
          metadata: metaData,
        }
        let body = ConnectorUtils.constructConnectorRequestBody(obj, initialValues)
        let connectorUrl = APIUtils.getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None, ())
        if enums.configurationType->String.length === 0 && connectorName === "stripe" {
          let _ = await updateEnumForMultipleConfigurationType(
            #MultipleProcessorWithSmartRouting->QuickStartUtils.connectorChoiceVariantToString,
          )
        }
        let response = await updateAPIHook(connectorUrl, body, Post, ())
        setInitialValues(_ => response)
        response->LogicUtils.getDictFromJsonObject->updateEnumForConnector->ignore
        setConnectorConfigureState(_ => Summary)
        showToast(
          ~message=`${connectorName->LogicUtils.getFirstLetterCaps()} connected successfully!`,
          ~toastType=ToastSuccess,
          (),
        )
        setButtonState(_ => Button.Normal)
      } catch {
      | _ => setButtonState(_ => Button.Normal)
      }
    }

    React.useEffect1(() => {
      initialValues
      ->ConnectorUtils.getConnectorPaymentMethodDetails(
        setPaymentMethods,
        setMetaData,
        false,
        false,
        connectorName,
        updateDetails,
      )
      ->ignore

      None
    }, [connectorName])

    <QuickStartUIUtils.BaseComponent
      headerText="Connect payment methods"
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
        onClick={_ => onSubmitMain()->ignore}
      />}
      backButton={<Button
        buttonType={PrimaryOutline}
        text="Back"
        onClick={_ => setConnectorConfigureState(_ => Configure_keys)}
        buttonSize=Small
      />}>
      <PaymentMethod.PaymentMethodsRender
        _showAdvancedConfiguration=false
        connector={connectorName}
        paymentMethodsEnabled
        updateDetails
        setMetaData
        metaData
        isPayoutFlow=false
      />
    </QuickStartUIUtils.BaseComponent>
  }
}

module TestPayment = {
  @react.component
  let make = (~setStepInView) => {
    let postEnumDetails = EnumVariantHook.usePostEnumDetails()
    let (key, setKey) = React.useState(_ => "")
    let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
    let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile

    let updateTestPaymentEnum = async _ => {
      try {
        let _ = await Boolean(true)->postEnumDetails(#SPTestPayment)
        setStepInView(_ => COMPLETED_STRIPE_PAYPAL)
      } catch {
      | _ => ()
      }
    }

    let sptestPaymentProceed = async (~paymentId as _) => {
      updateTestPaymentEnum()->ignore
    }
    React.useEffect0(() => {
      setKey(_ => Date.now()->Float.toString)
      None
    })

    <QuickStartUIUtils.BaseComponent
      headerText="Preview Checkout page"
      nextButton={<Button
        text="Skip this step"
        buttonSize={Small}
        buttonType={PrimaryOutline}
        customButtonStyle="!rounded-md"
        onClick={_ => {
          updateTestPaymentEnum()->ignore
        }}
      />}>
      <TestPayment
        initialValues={defaultBusinessProfile->SDKPaymentUtils.initialValueForForm}
        returnUrl={`${HSwitchGlobalVars.getHostUrlWithBasePath}/stripe-plus-paypal`}
        onProceed={sptestPaymentProceed}
        keyValue={key}
        sdkWidth="w-full"
        paymentStatusStyles="p-0"
      />
    </QuickStartUIUtils.BaseComponent>
  }
}
