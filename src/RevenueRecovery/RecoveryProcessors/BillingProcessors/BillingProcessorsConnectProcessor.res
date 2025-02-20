@react.component
let make = (~connector) => {
  open RevenueRecoveryOnboardingUtils
  open ConnectorUtils

  let connectorName = connector->getDisplayNameForConnector

  <PageWrapper
    title="Connect Your Processor"
    subTitle="Choose one processor for now. You can connect more processors later">
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
      <div>
        <div className="text-nd_gray-700 font-medium"> {"Account ID"->React.string} </div>
        <div className="-m-1 -mt-3">
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={FormRenderer.makeFieldInfo(
              ~label="",
              ~name="billing_account_reference",
              ~toolTipPosition=Right,
              ~customInput=InputFields.textInput(~customStyle="border rounded-xl"),
              ~placeholder="Enter Account ID",
            )}
          />
        </div>
      </div>
    </div>
  </PageWrapper>
}
