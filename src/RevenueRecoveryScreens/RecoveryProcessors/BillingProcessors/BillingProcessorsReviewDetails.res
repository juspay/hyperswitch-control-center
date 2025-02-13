@react.component
let make = (~initialValues, ~connectorDetails) => {
  open RevenueRecoveryOnboardingUtils

  open CommonAuthHooks
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)

  let connectorInfoDict =
    initialValues->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  let (_, connectorAccountFields, _, _, _, _, _) = ConnectorFragmentUtils.getConnectorFields(
    connectorDetails,
  )

  <PageWrapper
    title="Review and Connect"
    subTitle="Review your configured processor details, enabled payment methods and associated settings.">
    <div className="mb-10 flex flex-col gap-7">
      <div className=" flex flex-col py-4 gap-4">
        <div className="flex flex-col gap-0.5-rem ">
          <h4 className="text-nd_gray-400 "> {"Profile"->React.string} </h4>
          {connectorInfoDict.profile_id->React.string}
        </div>
        <div className="flex flex-col">
          <ConnectorHelperV2.PreviewCreds connectorInfo=connectorInfoDict connectorAccountFields />
        </div>
        <ConnectorWebhookPreview
          merchantId connectorName=connectorInfoDict.merchant_connector_id textCss="w-full"
        />
      </div>
    </div>
  </PageWrapper>
}
