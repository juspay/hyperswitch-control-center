module SelectProcessor = {
  open QuickStartTypes
  @react.component
  let make = (
    ~setSelectedConnector,
    ~selectedConnector,
    ~setConnectorConfigureState,
    ~connectorArray,
  ) => {
    let url = RescriptReactRouter.useUrl()
    let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString
    <QuickStartUIUtils.BaseComponent
      headerText="Select Processor"
      customCss="show-scrollbar"
      nextButton={<Button
        buttonType=Primary
        text="Proceed"
        buttonState={switch selectedConnector {
        | UnknownConnector(_) => Button.Disabled
        | _ => Button.Normal
        }}
        onClick={_ => {
          setConnectorConfigureState(_ => Configure_keys)
          RescriptReactRouter.replace(`/${url.path->LogicUtils.getListHead}?name=${connectorName}`)
        }}
        buttonSize=Small
      />}>
      <QuickStartUIUtils.SelectConnectorGrid
        selectedConnector
        setSelectedConnector
        connectorList={ConnectorUtils.connectorList->Array.filter(value =>
          !(connectorArray->Array.includes(value->ConnectorUtils.getConnectorNameString))
        )}
      />
    </QuickStartUIUtils.BaseComponent>
  }
}

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
    open QuickStartUtils
    let updateEnumInRecoil = EnumVariantHook.useUpdateEnumInRecoil()
    let enumDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.enumVariantAtom)
    let updateAPIHook = APIUtils.useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let postEnumDetails = EnumVariantHook.usePostEnumDetails()
    let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString

    let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
      Dict.make()->Js.Json.object_->ConnectorUtils.getPaymentMethodEnabled
    )
    let (metaData, setMetaData) = React.useState(_ => Dict.make()->Js.Json.object_)

    let updateDetails = value => {
      setPaymentMethods(_ => value->Array.copy)
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
        }

        if enums.configurationType->String.length === 0 {
          let _ =
            await StringEnumType(
              #MultipleProcessorWithSmartRouting->connectorChoiceVariantToString,
            )->postEnumDetails(#ConfigurationType)
          enumRecoilUpdateArr->Array.push((
            StringEnumType(#MultipleProcessorWithSmartRouting->connectorChoiceVariantToString),
            #ConfigurationType,
          ))
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

        let response = await updateAPIHook(connectorUrl, body, Post)
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
