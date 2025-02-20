@react.component
let make = (~initialValues, ~merchantId) => {
  let connectorInfoDict =
    initialValues->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  open RevenueRecoveryOnboardingUtils
  <PageWrapper
    title="Setup Webhook"
    subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor">
    <div className="mb-10 flex flex-col gap-7">
      <ConnectorWebhookPreview
        merchantId
        connectorName=connectorInfoDict.merchant_connector_id
        textCss="border border-nd_gray-300 font-[700] rounded-xl text-nd_gray-400 px-3 py-2 w-full"
        containerClass="flex flex-row items-center justify-between"
        hideLabel=true
        showFullCopy=true
      />
    </div>
  </PageWrapper>
}
