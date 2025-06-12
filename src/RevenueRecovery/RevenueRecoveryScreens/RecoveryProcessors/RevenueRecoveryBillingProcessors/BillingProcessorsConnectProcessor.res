module ConnectorConnect = {
  @react.component
  let make = (~connector_account_reference_id, ~autoFocus=false) => {
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black"
      field={FormRenderer.makeFieldInfo(
        ~label="",
        ~name=`feature_metadata.revenue_recovery.billing_account_reference.${connector_account_reference_id}`,
        ~toolTipPosition=Right,
        ~customInput=InputFields.textInput(~customStyle="border rounded-xl", ~autoFocus),
        ~placeholder="Enter Account ID",
      )}
    />
  }
}

module ConnectorConnectSummary = {
  @react.component
  let make = (~connector, ~connector_account_reference_id, ~autoFocus=false) => {
    let connectorName = connector->ConnectorUtils.getDisplayNameForConnector

    <div className="flex gap-7">
      <div className="flex gap-3 items-center">
        <GatewayIcon gateway={connector->String.toUpperCase} className="w-10" />
        <h1 className="text-medium font-semibold text-gray-600"> {connectorName->React.string} </h1>
      </div>
      <div className="w-full ml-5 mb-2">
        <ConnectorConnect connector_account_reference_id autoFocus />
      </div>
    </div>
  }
}

@react.component
let make = (
  ~connector,
  ~onSubmit,
  ~initialValues,
  ~validateMandatoryField,
  ~connector_account_reference_id,
) => {
  open RevenueRecoveryOnboardingUtils

  let connectorName = connector->ConnectorUtils.getDisplayNameForConnector

  <PageWrapper
    title="Configure your Processor"
    subTitle="Provide the reference ID of your payment processor as configured in the subscription management platform.">
    <div className="mb-10 flex flex-col gap-8">
      <div>
        <div className="text-nd_gray-700 font-medium mb-3">
          {"Selected processor"->React.string}
        </div>
        <div className="flex gap-4 items-center">
          <GatewayIcon gateway={connector->String.toUpperCase} className="w-10" />
          <h1 className="text-medium font-semibold text-gray-600">
            {connectorName->React.string}
          </h1>
        </div>
      </div>
      <Form onSubmit initialValues validate=validateMandatoryField>
        <div>
          <div className="text-nd_gray-700 font-medium">
            {"Processor Reference ID"->React.string}
            <span className="text-red-900 ml-0.5 mb-0.5"> {"*"->React.string} </span>
          </div>
          <div className="-m-1 -mt-3">
            <ConnectorConnect connector_account_reference_id />
            <FormRenderer.SubmitButton
              text="Next"
              buttonSize={Small}
              customSumbitButtonStyle="!w-full mt-8"
              tooltipForWidthClass="w-full"
            />
          </div>
        </div>
      </Form>
    </div>
  </PageWrapper>
}
