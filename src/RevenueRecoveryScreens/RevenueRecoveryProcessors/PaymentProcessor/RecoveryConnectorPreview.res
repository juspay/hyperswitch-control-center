module DeleteConnectorMenu = {
  @react.component
  let make = (~pageName="connector", ~connectorInfo: ConnectorTypes.connectorPayload) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let deleteConnector = async () => {
      try {
        let connectorID = connectorInfo.merchant_connector_id
        // TODO: need refactor
        let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=Some(connectorID))
        let _ = await updateDetails(url, Dict.make()->JSON.Encode.object, Delete)
        RescriptReactRouter.push(
          GlobalVars.appendDashboardPath(~url="v2/recovery/payment-processors"),
        )
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
  let connectorInfo =
    connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let connectorCount =
    HyperswitchAtom.connectorListAtom
    ->Recoil.useRecoilValueFromAtom
    ->getProcessorsListFromJson(~removeFromList=ConnectorTypes.FRMPlayer)
    ->Array.length
  let isFeedbackModalToBeOpen =
    feedback && !isUpdateFlow && connectorCount <= HSwitchUtils.feedbackModalOpenCountForConnectors

  let isConnectorDisabled = connectorInfo.disabled
  let disableConnector = async isConnectorDisabled => {
    try {
      let connectorID = connectorInfo.merchant_connector_id
      let disableConnectorPayload = getDisableConnectorPayload(
        connectorInfo.connector_type->connectorTypeTypedValueToStringMapper,
        isConnectorDisabled,
      )
      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=Some(connectorID))
      let res = await updateDetails(url, disableConnectorPayload->JSON.Encode.object, Post)
      fetchConnectorListResponse()->ignore
      setInitialValues(_ => res)
      showToast(~message=`Successfully Saved the Changes`, ~toastType=ToastSuccess)
    } catch {
    | Exn.Error(_) => showToast(~message=`Failed to Disable connector!`, ~toastType=ToastError)
    }
  }

  let connectorStatusStyle = connectorStatus =>
    switch connectorStatus {
    | false => "border bg-green-600 bg-opacity-40 border-green-700 text-green-700"
    | _ => "border bg-red-600 bg-opacity-40 border-red-400 text-red-500"
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
              <div
                className={`px-4 py-2 rounded-full w-fit font-medium text-sm !text-black ${isConnectorDisabled->connectorStatusStyle}`}>
                {(isConnectorDisabled ? "DISABLED" : "ENABLED")->React.string}
              </div>
              <RenderIf condition={showMenuOption}>
                {switch (connector->getConnectorNameTypeFromString, paypalAutomaticFlow) {
                | (Processors(PAYPAL), true) =>
                  <RecoveryMenuOptionForPayPal
                    setCurrentStep
                    disableConnector
                    isConnectorDisabled
                    updateStepValue={ConnectorTypes.PaymentMethods}
                    connectorInfoDict
                    setScreenState
                    isUpdateFlow
                    setInitialValues
                  />
                | (_, _) => <ConnectorPreview.MenuOption disableConnector isConnectorDisabled />
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
                RescriptReactRouter.push(
                  GlobalVars.appendDashboardPath(~url="v2/recovery/payment-processors"),
                )
              }}
              text="Done"
              buttonType={Primary}
            />
          }}
        </div>
      </div>
      <ConnectorPreview.ConnectorSummaryGrid
        connectorInfo
        connector
        setCurrentStep
        updateStepValue={Some(ConnectorTypes.PaymentMethods)}
        getConnectorDetails
      />
    </div>
  </PageLoaderWrapper>
}
