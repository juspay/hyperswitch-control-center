@react.component
let make = (~setCurrentStep, ~showMenuOption=true, ~getConnectorDetails=None) => {
  // open ConnectorUtils

  // let connectorInfo =
  //   connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  // let {merchantId} =
  //   CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)

  // let copyValueOfWebhookEndpoint = getWebhooksUrl(
  //   ~connectorName={connectorInfo.merchant_connector_id},
  //   ~merchantId,
  // )

  <div>
    <div className="flex justify-between p-2">
      <RecoveryConfigurationHelper.SubHeading
        title="Setup Webhook"
        subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
      />
    </div>
    // <div className="mt-5 mb-7 mx-2">
    //   <ConnectorPreview.KeyAndCopyArea copyValue={copyValueOfWebhookEndpoint} />
    // </div>
    <div className="flex justify-end items-center">
      <Button
        text="Next"
        customButtonStyle="rounded w-full"
        buttonType={Primary}
        onClick={_ => setCurrentStep(_ => ConnectorTypes.IntegFields)}
      />
    </div>
  </div>
}
