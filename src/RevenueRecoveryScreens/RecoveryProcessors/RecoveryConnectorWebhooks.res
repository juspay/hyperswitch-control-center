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
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="v2/recovery/connectors"))
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
let make = (~connectorInfo, ~setCurrentStep, ~showMenuOption=true, ~getConnectorDetails=None) => {
  open ConnectorUtils

  let connectorInfo =
    connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  let {merchantId} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)

  let copyValueOfWebhookEndpoint = getWebhooksUrl(
    ~connectorName={connectorInfo.merchant_connector_id},
    ~merchantId,
  )

  <div>
    <div className="flex justify-between p-2">
      <RecoveryConfigurationHelper.SubHeading
        title="Setup Webhook"
        subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
      />
    </div>
    <div className="mt-5 mb-7 mx-2">
      <ConnectorPreview.KeyAndCopyArea copyValue={copyValueOfWebhookEndpoint} />
    </div>
    <div className="flex justify-end items-center">
      <Button
        text="Next"
        customButtonStyle="rounded w-full"
        buttonType={Primary}
        onClick={_ => setCurrentStep(_ => ConnectorTypes.SummaryAndTest)}
      />
    </div>
  </div>
}
