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
        text="Proceed"
        onClick={_ => {
          setConnectorConfigureState(_ => Select_configuration_type)
          RescriptReactRouter.replace(`/${url.path->LogicUtils.getListHead}?name=${connectorName}`)
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
        connectorList={ConnectorUtils.connectorList->Js.Array2.filter(value =>
          !(connectorArray->Js.Array2.includes(value->ConnectorUtils.getConnectorNameString))
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
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    open ConnectorUtils
    let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString

    let connectorDetails = React.useMemo1(() => {
      try {
        if connectorName->Js.String2.length > 0 {
          Window.getConnectorConfig(connectorName)
        } else {
          Js.Dict.empty()->Js.Json.object_
        }
      } catch {
      | _ => Js.Dict.empty()->Js.Json.object_
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
      let body = ConnectorUtils.generateInitialValuesDict(
        ~values,
        ~connector=connectorName,
        ~bodyType,
        ~isPayoutFlow=false,
        ~isLiveMode={featureFlagDetails.isLiveMode},
        (),
      )
      setInitialValues(_ => body)
      setConnectorConfigureState(_ => Setup_payment_methods)
      Js.Nullable.null
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
        connectorName->getConnectorNameTypeFromString,
        valuesFlattenJson,
        connectorAccountFields,
        connectorMetaDataFields,
        connectorWebHookDetails,
        connectorLabelDetailField,
        errors->Js.Json.object_,
      )
    }
    let backButton = isBackButtonVisible
      ? <Button
          buttonType={PrimaryOutline}
          text="Back"
          onClick={_ => setConnectorConfigureState(_ => Select_configuration_type)}
          buttonSize=Small
        />
      : React.null

    <Form initialValues onSubmit validate={validateMandatoryField}>
      <QuickStartUIUtils.BaseComponent
        headerText={`Connect ${connectorName->LogicUtils.capitalizeString}`}
        customIcon={<GatewayIcon
          gateway={connectorName->Js.String2.toUpperCase} className="w-6 h-6 rounded-md"
        />}
        backButton
        nextButton={<FormRenderer.SubmitButton
          loadingText="Processing..." text="Proceed" buttonSize={Small}
        />}>
        <UIUtils.RenderIf condition={featureFlagDetails.businessProfile}>
          <ConnectorAccountDetails.BusinessProfileRender
            isUpdateFlow=false selectedConnector={connectorName}
          />
        </UIUtils.RenderIf>
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
    let {quickStartPageState} = React.useContext(GlobalProvider.defaultContext)
    let updateAPIHook = APIUtils.useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let usePostEnumDetails = EnumVariantHook.usePostEnumDetails()
    let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString

    let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
      Js.Dict.empty()->Js.Json.object_->ConnectorUtils.getPaymentMethodEnabled
    )
    let (metaData, setMetaData) = React.useState(_ => Js.Dict.empty()->Js.Json.object_)

    let updateDetails = value => {
      setPaymentMethods(_ => value->Js.Array2.copy)
    }

    let updateEnumForConnector = async connectorResponse => {
      open LogicUtils
      try {
        let processorVal: processorType = {
          processorID: connectorResponse->getString("merchant_connector_id", ""),
          processorName: connectorResponse->getString("connector_name", ""),
        }
        let enumVariant = quickStartPageState->variantToEnumMapper
        let _ = await ProcesorType(processorVal)->usePostEnumDetails(enumVariant)
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
        connectorArray->Array.push(connectorName)
        setConnectorArray(_ => connectorArray)
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
