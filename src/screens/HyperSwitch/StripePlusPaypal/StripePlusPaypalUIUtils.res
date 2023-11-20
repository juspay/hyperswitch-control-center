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
    let updateAPIHook = APIUtils.useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let postEnumDetails = EnumVariantHook.usePostEnumDetails()
    let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString
    let fetchUpdatedConnectorList = ConnectorUtils.useFetchConnectorList()

    let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
      Js.Dict.empty()->Js.Json.object_->ConnectorUtils.getPaymentMethodEnabled
    )
    let (metaData, setMetaData) = React.useState(_ => Js.Dict.empty()->Js.Json.object_)

    let updateDetails = value => {
      setPaymentMethods(_ => value->Js.Array2.copy)
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
        if enums.firstProcessorConnected.processorID->Js.String2.length === 0 {
          let _resp = await body->postEnumDetails(#FirstProcessorConnected)
          enumRecoilUpdateArr->Array.push((body, #FirstProcessorConnected))
        } else if enums.secondProcessorConnected.processorID->Js.String2.length === 0 {
          let _resp = await body->postEnumDetails(#SecondProcessorConnected)
          enumRecoilUpdateArr->Array.push((body, #SecondProcessorConnected))
        }

        if selectedConnector === STRIPE {
          enumRecoilUpdateArr->Array.push((body, #StripeConnected))
        } else if selectedConnector === PAYPAL {
          enumRecoilUpdateArr->Array.push((body, #PaypalConnected))
        }
        let _res = updateEnumInRecoil(enumRecoilUpdateArr)
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
        let connectorUrl = APIUtils.getURL(
          ~entityName=CONNECTOR,
          ~methodType=Post,
          ~id=None,
          (),
        )

        let response = await updateAPIHook(connectorUrl, body, Post)
        let _updatedConnectorList = await fetchUpdatedConnectorList()
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
        _ => (),
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
        gateway={connectorName->Js.String2.toUpperCase} className="w-6 h-6 rounded-md"
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

    let updateTestPaymentEnum = async _ => {
      try {
        let _resp = await Boolean(true)->postEnumDetails(#SPTestPayment)
      } catch {
      | _ => ()
      }
    }

    let sptestPaymentProceed = async (~paymentId as _) => {
      setStepInView(_ => COMPLETED_STRIPE_PAYPAL)
      updateTestPaymentEnum()->ignore
    }

    <QuickStartUIUtils.BaseComponent
      headerText="Preview Checkout page"
      nextButton={<Button
        text="Skip this step"
        buttonSize={Small}
        buttonType={PrimaryOutline}
        customButtonStyle="!rounded-md"
        onClick={_ => {
          setStepInView(_ => COMPLETED_STRIPE_PAYPAL)
          updateTestPaymentEnum()->ignore
        }}
      />}>
      <TestPayment
        amount=100
        returnUrl={`${HSwitchGlobalVars.hyperSwitchFEPrefix}/stripe-plus-paypal`}
        onProceed={sptestPaymentProceed}
      />
    </QuickStartUIUtils.BaseComponent>
  }
}
