module SelectProcessor = {
  open QuickStartTypes
  @react.component
  let make = (
    ~setSelectedConnector,
    ~selectedConnector,
    ~setConnectorConfigureState,
    ~connectorArray,
  ) => {
    open ConnectorUtils
    let url = RescriptReactRouter.useUrl()
    let basePath = url.path->List.toArray->Array.joinWithUnsafe("/")
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let connectorName = selectedConnector->getConnectorNameString
    let {setQuickStartPageState} = React.useContext(GlobalProvider.defaultContext)

    <QuickStartUIUtils.BaseComponent
      headerText="Select Processor"
      customCss="show-scrollbar"
      nextButton={<Button
        buttonType=Primary
        buttonState={switch selectedConnector {
        | UnknownConnector(_) => Button.Disabled
        | _ => Button.Normal
        }}
        showBtnTextToolTip={switch selectedConnector {
        | UnknownConnector(_) => true
        | _ => false
        }}
        tooltipText={switch selectedConnector {
        | UnknownConnector(_) => "Please select one of the processor"
        | _ => ""
        }}
        text="Proceed"
        onClick={_ => {
          setConnectorConfigureState(_ => Select_configuration_type)
          mixpanelEvent(~eventName=`quickstart_select_processor`)
          RescriptReactRouter.replace(`/${basePath}?name=${connectorName}`)
        }}
        buttonSize=Small
      />}
      backButton={<Button
        buttonType={PrimaryOutline}
        buttonState={Button.Normal}
        text="Back"
        buttonSize=Small
        onClick={_ => {
          setQuickStartPageState(_ => ConnectProcessor(LANDING))
        }}
      />}>
      <QuickStartUIUtils.SelectConnectorGrid
        selectedConnector
        setSelectedConnector
        connectorList={connectorList->Array.filter(value =>
          !(connectorArray->Array.includes(value->getConnectorNameString))
        )}
      />
    </QuickStartUIUtils.BaseComponent>
  }
}
module ConfigureProcessor = {
  open QuickStartTypes
  @react.component
  let make = (
    ~selectedConnector,
    ~initialValues,
    ~setInitialValues,
    ~setConnectorConfigureState,
    ~isBackButtonVisible=true,
  ) => {
    open ConnectorUtils
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let connectorName = selectedConnector->getConnectorNameString

    let connectorDetails = React.useMemo(() => {
      try {
        if connectorName->LogicUtils.isNonEmptyString {
          Window.getConnectorConfig(connectorName)
        } else {
          Dict.make()->JSON.Encode.object
        }
      } catch {
      | _ => Dict.make()->JSON.Encode.object
      }
    }, [(connectorName, selectedConnector)])

    let (
      bodyType,
      connectorAccountFields,
      connectorMetaDataFields,
      _,
      connectorWebHookDetails,
      connectorLabelDetailField,
    ) = getConnectorFields(connectorDetails)

    let onSubmit = async (values, _) => {
      let body = generateInitialValuesDict(
        ~values,
        ~connector=connectorName,
        ~bodyType,
        ~isPayoutFlow=false,
        ~isLiveMode={featureFlagDetails.isLiveMode},
      )
      setInitialValues(_ => body)
      mixpanelEvent(~eventName=`quickstart_connector_configuration`)
      setConnectorConfigureState(_ => Setup_payment_methods)
      Nullable.null
    }

    let validateMandatoryField = values => {
      let errors = Dict.make()
      let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
      let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
      if profileId->String.length === 0 {
        Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
      }

      validateConnectorRequiredFields(
        connectorName->getConnectorNameTypeFromString,
        valuesFlattenJson,
        connectorAccountFields,
        connectorMetaDataFields,
        connectorWebHookDetails,
        connectorLabelDetailField,
        errors->JSON.Encode.object,
      )
    }
    let backButton =
      <RenderIf condition={isBackButtonVisible}>
        <Button
          buttonType={PrimaryOutline}
          text="Back"
          onClick={_ => setConnectorConfigureState(_ => Select_configuration_type)}
          buttonSize=Small
        />
      </RenderIf>

    <Form initialValues onSubmit validate={validateMandatoryField}>
      <QuickStartUIUtils.BaseComponent
        headerText={`Connect ${connectorName->ConnectorUtils.getDisplayNameForConnector}`}
        customIcon={<GatewayIcon
          gateway={connectorName->String.toUpperCase} className="w-6 h-6 rounded-md"
        />}
        backButton
        nextButton={<FormRenderer.SubmitButton
          loadingText="Processing..." text="Proceed" buttonSize={Small}
        />}>
        <SetupConnectorCredentials.ConnectorDetailsForm
          connectorName
          connectorDetails
          isCheckboxSelected=false
          setIsCheckboxSelected={_ => ()}
          setVerifyDone={_ => ()}
          verifyErrorMessage=None
          checkboxText=""
        />
      </QuickStartUIUtils.BaseComponent>
    </Form>
  }
}

module SelectPaymentMethods = {
  open QuickStartTypes
  open ConnectorTypes
  open QuickStartUtils
  @react.component
  let make = (
    ~selectedConnector,
    ~initialValues,
    ~setInitialValues,
    ~setConnectorConfigureState,
    ~setConnectorArray,
    ~connectorArray,
    ~setButtonState: (Button.buttonState => Button.buttonState) => unit,
    ~buttonState,
  ) => {
    open ConnectorUtils
    let {quickStartPageState} = React.useContext(GlobalProvider.defaultContext)
    let updateAPIHook = APIUtils.useUpdateMethod()
    let getURL = APIUtils.useGetURL()
    let showToast = ToastState.useShowToast()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let postEnumDetails = EnumVariantHook.usePostEnumDetails()
    let connectorName = selectedConnector->getConnectorNameString

    let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
      Dict.make()->JSON.Encode.object->getPaymentMethodEnabled
    )
    let (metaData, setMetaData) = React.useState(_ => Dict.make()->JSON.Encode.object)

    let updateDetails = value => {
      setPaymentMethods(_ => value->Array.copy)
    }

    let updateEnumForConnector = async connectorResponse => {
      open LogicUtils
      try {
        let processorVal: processorType = {
          processorID: connectorResponse->getString("merchant_connector_id", ""),
          processorName: connectorResponse->getString("connector_name", ""),
        }
        let enumVariant = quickStartPageState->variantToEnumMapper
        let _ = await ProcesorType(processorVal)->postEnumDetails(enumVariant)
      } catch {
      | _ => setButtonState(_ => Button.Normal)
      }
    }

    let onSubmitMain = async () => {
      setButtonState(_ => Loading)
      try {
        open LogicUtils
        let obj: ConnectorTypes.wasmRequest = {
          connector: connectorName,
          payment_methods_enabled: paymentMethodsEnabled,
          metadata: metaData,
        }
        let body = constructConnectorRequestBody(obj, initialValues)
        // Need to refactor
        let metaData = body->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
        let _ = ConnectorUtils.updateMetaData(~metaData)
        //
        let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)

        let response = await updateAPIHook(connectorUrl, body, Post)

        setInitialValues(_ => response)
        connectorArray->Array.push(connectorName)
        setConnectorArray(_ => connectorArray)
        response->LogicUtils.getDictFromJsonObject->updateEnumForConnector->ignore
        setConnectorConfigureState(_ => Summary)
        showToast(
          ~message=`${connectorName->LogicUtils.getFirstLetterCaps} connected successfully!`,
          ~toastType=ToastSuccess,
        )
        setButtonState(_ => Button.Normal)
        mixpanelEvent(~eventName=`quickstart_connector_payment_methods`)
      } catch {
      | _ => setButtonState(_ => Button.Normal)
      }
    }

    React.useEffect(() => {
      initialValues
      ->getConnectorPaymentMethodDetails(
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
      <Form initialValues={initialValues}>
        <PaymentMethod.PaymentMethodsRender
          _showAdvancedConfiguration=false
          connector={connectorName}
          paymentMethodsEnabled
          updateDetails
          setMetaData
          isPayoutFlow=false
          initialValues
          setInitialValues
        />
        <FormValuesSpy />
      </Form>
    </QuickStartUIUtils.BaseComponent>
  }
}
