@react.component
let make = (~initialValues, ~merchantId, ~onNextClick) => {
  let connectorInfoDict = ConnectorInterface.mapDictToConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->LogicUtils.getDictFromJsonObject,
  )

  <RevenueRecoveryOnboardingUtils.PageWrapper
    title="Setup Webhook"
    subTitle="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor">
    <div className="mb-10 flex flex-col gap-7">
      <div className="mb-10 flex flex-col gap-7 w-540-px">
        <ConnectorWebhookPreview
          merchantId
          connectorName=connectorInfoDict.id
          textCss="border border-nd_gray-300 font-[700] rounded-xl px-4 py-2 mb-6 mt-6  text-nd_gray-400 w-full"
          containerClass="flex flex-row items-center justify-between"
          displayTextLength=46
          hideLabel=true
          showFullCopy=true
        />
        <Button text="Next" buttonType=Primary onClick={onNextClick} customButtonStyle="w-full" />
      </div>
    </div>
  </RevenueRecoveryOnboardingUtils.PageWrapper>
}
