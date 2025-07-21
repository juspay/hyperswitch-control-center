@react.component
let make = (~initialValues, ~merchantId, ~onNextClick) => {
  let connectorInfoDict = ConnectorInterface.mapDictToIndividualConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->LogicUtils.getDictFromJsonObject,
  )

  <RevenueRecoveryOnboardingUtils.PageWrapper
    title="Setup Subscription Webhook"
    subTitle="Configure this endpoint in the subscription management system dashboard under webhook settings for us to pick up failed payments for recovery.">
    <div className="mb-10 flex flex-col gap-7">
      <div className="mb-10 flex flex-col gap-7 w-540-px">
        <ConnectorWebhookPreview
          merchantId
          connectorName=connectorInfoDict.id
          textCss="border border-nd_gray-400 font-medium rounded-xl px-4 py-2 mb-6 mt-6  text-nd_gray-400 w-full !font-jetbrain-mono"
          containerClass="flex flex-row items-center justify-between"
          displayTextLength=38
          hideLabel=true
          showFullCopy=true
        />
        <Button text="Next" buttonType=Primary onClick={onNextClick} customButtonStyle="w-full" />
      </div>
    </div>
  </RevenueRecoveryOnboardingUtils.PageWrapper>
}
