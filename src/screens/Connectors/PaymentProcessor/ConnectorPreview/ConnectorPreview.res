module InfoField = {
  @react.component
  let make = (~render, ~label) => {
    let str = render->Option.getOr("")

    <RenderIf condition={str->LogicUtils.isNonEmptyString}>
      <div>
        <h2 className="text-medium font-semibold"> {label->React.string} </h2>
        <h3 className="text-base text-grey-700 opacity-70 break-all overflow-scroll font-semibold">
          {str->React.string}
        </h3>
      </div>
    </RenderIf>
  }
}

module KeyAndCopyArea = {
  @react.component
  let make = (~copyValue) => {
    let showToast = ToastState.useShowToast()
    <div className="flex flex-col md:flex-row items-center">
      <p
        className="text-base text-grey-700 opacity-70 break-all overflow-scroll font-semibold w-89.5-per">
        {copyValue->React.string}
      </p>
      <div
        className="cursor-pointer"
        onClick={_ => {
          Clipboard.writeText(copyValue)
          showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
        }}>
        <Icon name="nd-copy" className="cursor-pointer" />
      </div>
    </div>
  }
}

module DeleteConnectorMenu = {
  @react.component
  let make = (~pageName="connector", ~connectorInfo: ConnectorTypes.connectorPayload) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let deleteConnector = async () => {
      try {
        let connectorID = connectorInfo.merchant_connector_id
        let url = getURL(~entityName=V1(CONNECTOR), ~methodType=Post, ~id=Some(connectorID))
        let _ = await updateDetails(url, Dict.make()->JSON.Encode.object, Delete)
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/connectors"))
      } catch {
      | _ => ()
      }
    }
    let showPopUp = PopUpState.useShowPopUp()
    let openConfirmationPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm Action ? ",
        description: `You are about to Delete this connector. This might impact your desired routing configurations. Please confirm to proceed.`->React.string,
        handleConfirm: {
          text: "Confirm",
          onClick: _ => deleteConnector()->ignore,
        },
        handleCancel: {text: "Cancel"},
      })
    }
    <AddDataAttributes attributes=[("data-testid", "delete-button"->String.toLowerCase)]>
      <div>
        <Button text="Delete" onClick={_ => openConfirmationPopUp()} />
      </div>
    </AddDataAttributes>
  }
}

// TODO: Remove this module - replaced by ConnectorPreviewHelper.EnableDisableConnectorToggle
module MenuOption = {
  open HeadlessUI
  @react.component
  let make = (
    ~updateStepValue=ConnectorTypes.IntegFields,
    ~disableConnector,
    ~isConnectorDisabled,
    ~pageName="connector",
  ) => {
    let showPopUp = PopUpState.useShowPopUp()
    let openConfirmationPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm Action ? ",
        description: `You are about to ${isConnectorDisabled
            ? "Enable"
            : "Disable"->String.toLowerCase} this connector. This might impact your desired routing configurations. Please confirm to proceed.`->React.string,
        handleConfirm: {
          text: "Confirm",
          onClick: _ => disableConnector(isConnectorDisabled)->ignore,
        },
        handleCancel: {text: "Cancel"},
      })
    }

    let connectorStatusAvailableToSwitch = isConnectorDisabled ? "Enable" : "Disable"

    <Popover \"as"="div" className="relative inline-block text-left">
      {_popoverProps => <>
        <Popover.Button> {_ => <Icon name="menu-option" size=28 />} </Popover.Button>
        <Popover.Panel className="absolute z-20 right-5 top-4">
          {panelProps => {
            <div
              id="neglectTopbarTheme"
              className="relative flex flex-col bg-white py-1 overflow-hidden rounded ring-1 ring-black ring-opacity-5 w-40">
              {<>
                <Navbar.MenuOption
                  text={connectorStatusAvailableToSwitch}
                  onClick={_ => {
                    panelProps["close"]()
                    openConfirmationPopUp()
                  }}
                />
              </>}
            </div>
          }}
        </Popover.Panel>
      </>}
    </Popover>
  }
}

module ConnectorSummaryGrid = {
  open CommonAuthHooks
  @react.component
  let make = (
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~connector,
    ~setCurrentStep,
    ~updateStepValue=None,
    ~getConnectorDetails=None,
  ) => {
    open ConnectorUtils
    open ConnectorPreviewTypes

    let url = RescriptReactRouter.useUrl()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let businessProfileRecoilVal =
      HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom

    let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
    let copyValueOfWebhookEndpoint = getWebhooksUrl(
      ~connectorName={connectorInfo.merchant_connector_id},
      ~merchantId,
    )
    let (processorType, _) =
      connectorInfo.connector_type
      ->connectorTypeTypedValueToStringMapper
      ->connectorTypeTuple
    let {connector_name: connectorName} = connectorInfo
    let (currentActiveSection, setCurrentActiveSection) = React.useState(_ => None)

    let connectorDetails = React.useMemo(() => {
      try {
        if connectorName->LogicUtils.isNonEmptyString {
          let dict = switch processorType {
          | PaymentProcessor => Window.getConnectorConfig(connectorName)
          | PayoutProcessor => Window.getPayoutConnectorConfig(connectorName)
          | AuthenticationProcessor => Window.getAuthenticationConnectorConfig(connectorName)
          | PMAuthProcessor => Window.getPMAuthenticationProcessorConfig(connectorName)
          | TaxProcessor => Window.getTaxProcessorConfig(connectorName)
          | BillingProcessor => BillingProcessorsUtils.getConnectorConfig(connectorName)
          | VaultProcessor => Window.getConnectorConfig(connectorName)
          | PaymentVas => JSON.Encode.null
          }
          dict
        } else {
          JSON.Encode.null
        }
      } catch {
      | Exn.Error(e) => {
          Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
          let _ = Exn.message(e)->Option.getOr("Something went wrong")
          JSON.Encode.null
        }
      }
    }, [connectorInfo.merchant_connector_id])
    let {connectorAccountFields} = getConnectorFields(connectorDetails)
    let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
    | list{_, "new"} => false
    | _ => true
    }

    let checkCurrentEditState = (section: connectorSummaryEditableSections) =>
      currentActiveSection->Option.mapOr(false, active => active == section)

    let handleConnectorDetailsUpdate = () => {
      setCurrentActiveSection(_ => None)
    }

    <>
      <div className="grid grid-cols-4 border-b md:px-10 py-8">
        <h4 className="text-lg font-semibold"> {"Integration status"->React.string} </h4>
        <AddDataAttributes attributes=[("data-testid", "connector_status"->String.toLowerCase)]>
          <div
            className={`text-black font-semibold text-sm ${connectorInfo.status->ConnectorInterfaceTableEntity.connectorStatusStyle}`}>
            {connectorInfo.status->String.toUpperCase->React.string}
          </div>
        </AddDataAttributes>
      </div>
      <div className="grid grid-cols-4 border-b md:px-10 py-8">
        <div className="flex items-start">
          <h4 className="text-lg font-semibold"> {"Webhook Endpoint"->React.string} </h4>
          <ToolTip
            height=""
            description="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
            toolTipFor={<Icon name="tooltip_info" className={`mt-1 ml-1`} />}
            toolTipPosition=Top
            tooltipWidthClass="w-fit"
          />
        </div>
        <div className="col-span-3">
          <KeyAndCopyArea copyValue={copyValueOfWebhookEndpoint} />
        </div>
      </div>
      <div className="grid grid-cols-4 border-b  md:px-10 py-8">
        <h4 className="text-lg font-semibold"> {"Profile"->React.string} </h4>
        <div className="col-span-3 font-semibold text-base text-grey-700 opacity-70">
          {`${businessProfileRecoilVal.profile_name} - ${connectorInfo.profile_id}`->React.string}
        </div>
      </div>
      <div className="grid grid-cols-4 border-b  md:px-10">
        <div className="flex items-start">
          <h4 className="text-lg font-semibold py-8"> {"Credentials"->React.string} </h4>
        </div>
        <div className="flex flex-col gap-6  col-span-3">
          <div className="flex gap-12">
            <RenderIf condition={!checkCurrentEditState(AuthenticationKeys)}>
              <div className="flex flex-col gap-6 w-5/6  py-8">
                <ConnectorPreviewHelper.PreviewCreds
                  connectorAccountFields connectorInfo showLabelAndFieldVertically=true
                />
              </div>
            </RenderIf>
            <RenderIf condition={isUpdateFlow}>
              <RenderIf condition={!checkCurrentEditState(AuthenticationKeys)}>
                <div
                  className="cursor-pointer py-8"
                  onClick={_ => {
                    mixpanelEvent(~eventName=`processor_update_creds_${connectorName}`)
                    setCurrentActiveSection(_ => Some(AuthenticationKeys))
                  }}>
                  <ToolTip
                    height=""
                    description={`Update the ${connectorName} creds`}
                    toolTipFor={<Icon size=18 name="edit" className={`mt-1 ml-1`} />}
                    toolTipPosition=Top
                    tooltipWidthClass="w-fit"
                  />
                </div>
              </RenderIf>
              <RenderIf condition={checkCurrentEditState(AuthenticationKeys)}>
                <ConnectorUpdateAuthCreds
                  connectorInfo
                  getConnectorDetails
                  handleConnectorDetailsUpdate
                  setCurrentActiveSection
                />
              </RenderIf>
            </RenderIf>
          </div>
          <RenderIf
            condition={connectorInfo.connector_name->getConnectorNameTypeFromString ==
              Processors(FIUU)}>
            <div
              className="flex border items-start bg-blue-800 border-blue-810 text-sm rounded-md gap-2 px-4 py-3">
              <Icon name="info-vacent" size=18 />
              <div>
                <p className="mb-3">
                  {"To ensure mandates work correctly with Fiuu, please verify that the Source Verification Key for webhooks is set accurately in your configuration. Without the correct Source Verification Key, mandates may not function as expected."->React.string}
                </p>
                <p>
                  {"Please review your webhook settings and confirm that the Source Verification Key is properly configured to avoid any integration issues."->React.string}
                </p>
              </div>
            </div>
          </RenderIf>
        </div>
        <div />
      </div>
      {switch updateStepValue {
      | Some(state) =>
        <div className="grid grid-cols-4 border-b md:px-10 py-8">
          <div className="flex items-start">
            <h4 className="text-lg font-semibold"> {"PMTs"->React.string} </h4>
          </div>
          <div className="flex flex-col gap-6 col-span-3">
            <div className="flex gap-12">
              <div className="flex flex-col gap-6 col-span-3 w-5/6">
                {connectorInfo.payment_methods_enabled
                ->Array.mapWithIndex((field, index) => {
                  <InfoField
                    key={index->Int.toString}
                    label={field.payment_method->LogicUtils.snakeToTitle}
                    render={Some(
                      field.payment_method_types
                      ->Array.map(item => item.payment_method_type->LogicUtils.snakeToTitle)
                      ->Array.reduce([], (acc, curr) => {
                        if !(acc->Array.includes(curr)) {
                          acc->Array.push(curr)
                        }
                        acc
                      })
                      ->Array.joinWith(", "),
                    )}
                  />
                })
                ->React.array}
              </div>
              <RenderIf condition={isUpdateFlow}>
                <div
                  className="cursor-pointer"
                  onClick={_ => {
                    mixpanelEvent(~eventName=`processor_update_payment_methods_${connector}`)

                    setCurrentStep(_ => state)
                  }}>
                  <ToolTip
                    height=""
                    description={`Update the ${connector} payment methods`}
                    toolTipFor={<Icon size=18 name="edit" className={` ml-2`} />}
                    toolTipPosition=Top
                    tooltipWidthClass="w-fit"
                  />
                </div>
              </RenderIf>
            </div>
            <div
              className="flex border items-start bg-blue-800 border-blue-810 text-sm rounded-md gap-2 px-4 py-3">
              <Icon name="info-vacent" size=18 />
              <p>
                {"Improve conversion rate by conditionally managing PMTs visibility on checkout . Visit Settings >"->React.string}
                <a
                  onClick={_ =>
                    RescriptReactRouter.push(
                      GlobalVars.appendDashboardPath(~url="/configure-pmts"),
                    )}
                  target="_blank"
                  className="text-primary underline cursor-pointer">
                  {"Configure PMTs at Checkout"->React.string}
                </a>
              </p>
            </div>
          </div>
        </div>

      | None => React.null
      }}
    </>
  }
}

@react.component
let make = (
  ~connectorInfo,
  ~currentStep: ConnectorTypes.steps,
  ~setCurrentStep,
  ~isUpdateFlow,
  ~showMenuOption=true,
  ~setInitialValues,
  ~getPayPalStatus,
  ~getConnectorDetails=None,
) => {
  open APIUtils
  open ConnectorUtils
  let {feedback, paypalAutomaticFlow} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let {setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let connectorInfoDict = connectorInfo->LogicUtils.getDictFromJsonObject

  let connectorInfo = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV1,
    connectorInfoDict,
  )

  let connectorCount = ConnectorListInterface.useFilteredConnectorList()->Array.length

  let isFeedbackModalToBeOpen =
    feedback && !isUpdateFlow && connectorCount <= HSwitchUtils.feedbackModalOpenCountForConnectors

  let isConnectorDisabled = connectorInfo.disabled
  let disableConnector = async isConnectorDisabled => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let connectorID = connectorInfo.merchant_connector_id
      let disableConnectorPayload = getDisableConnectorPayload(
        connectorInfo.connector_type->connectorTypeTypedValueToStringMapper,
        isConnectorDisabled,
      )
      let url = getURL(~entityName=V1(CONNECTOR), ~methodType=Post, ~id=Some(connectorID))
      let res = await updateDetails(url, disableConnectorPayload, Post)
      let _ = await fetchConnectorListResponse()
      setInitialValues(_ => res)
      setScreenState(_ => PageLoaderWrapper.Success)
      showToast(
        ~message=`Connector has been successfully ${isConnectorDisabled ? "Enabled" : "Disabled"}`,
        ~toastType=ToastSuccess,
      )
    } catch {
    | Exn.Error(_) => {
        showToast(~message=`Failed to Disable connector!`, ~toastType=ToastError)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    }
  }

  let mixpanelEventName = isUpdateFlow ? "processor_step3_onUpdate" : "processor_step3"

  <PageLoaderWrapper screenState>
    <div>
      <div className="flex justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon
            gateway={connectorInfo.connector_name->String.toUpperCase} className="w-14 h-14"
          />
          <h2 className="text-xl font-semibold">
            {connectorInfo.connector_name->getDisplayNameForConnector->React.string}
          </h2>
        </div>
        <div className="self-center">
          {switch (
            currentStep,
            connector->getConnectorNameTypeFromString,
            connectorInfo.status,
            paypalAutomaticFlow,
          ) {
          | (Preview, Processors(PAYPAL), "inactive", true) =>
            <Button text="Sync" buttonType={Primary} onClick={_ => getPayPalStatus()->ignore} />
          | (Preview, _, _, _) =>
            <div className="flex gap-6 items-center">
              <RenderIf condition={showMenuOption}>
                {switch (connector->getConnectorNameTypeFromString, paypalAutomaticFlow) {
                | (Processors(PAYPAL), true) =>
                  <MenuOptionForPayPal
                    setCurrentStep
                    disableConnector
                    isConnectorDisabled
                    updateStepValue={ConnectorTypes.PaymentMethods}
                    connectorInfoDict
                    setScreenState
                    isUpdateFlow
                    setInitialValues
                  />
                | (_, _) =>
                  <ConnectorPreviewHelper.EnableDisableConnectorToggle
                    disableConnector isConnectorDisabled
                  />
                }}
              </RenderIf>
            </div>

          | _ =>
            <Button
              onClick={_ => {
                mixpanelEvent(~eventName=mixpanelEventName)
                if isFeedbackModalToBeOpen {
                  setShowFeedbackModal(_ => true)
                }
                RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/connectors"))
              }}
              text="Done"
              buttonType={Primary}
            />
          }}
        </div>
      </div>
      <ConnectorSummaryGrid
        connectorInfo
        connector
        setCurrentStep
        updateStepValue={Some(ConnectorTypes.PaymentMethods)}
        getConnectorDetails
      />
    </div>
  </PageLoaderWrapper>
}
