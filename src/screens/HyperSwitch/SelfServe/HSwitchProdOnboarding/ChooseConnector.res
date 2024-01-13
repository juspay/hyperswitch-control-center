let headerTextStyle = "text-xl font-semibold text-grey-700"
let subTextStyle = "text-base font-normal text-grey-700 opacity-50"
let subheaderText = "text-base font-semibold text-grey-700"
@react.component
let make = (~selectedConnector, ~setSelectedConnector, ~pageView, ~setPageView) => {
  let getBlockColor = connector =>
    selectedConnector === connector ? "border border-blue-700 bg-blue-700 bg-opacity-10 " : "border"
  <div className="flex flex-col gap-16 w-full p-10">
    <div className="flex justify-between items-center flex-wrap gap-4">
      <div>
        <p className=headerTextStyle> {"Select a processor to continue"->React.string} </p>
        <p className=subTextStyle>
          {"Additional processors can be added under Home > Processors"->React.string}
        </p>
      </div>
      <Button
        text="Proceed"
        buttonSize={Small}
        buttonType={Primary}
        customButtonStyle="!rounded-md"
        onClick={_ => {
          setPageView(_ => pageView->ProdOnboardingUtils.getPageView)
        }}
      />
    </div>
    <div className="grid grid-cols-1 gap-4 md:grid-cols-3 md:gap-8">
      {ConnectorUtils.connectorListForLive
      ->Array.mapWithIndex((connector, index) => {
        let connectorInfo = connector->ConnectorUtils.getConnectorInfo
        let connectorName = connector->ConnectorUtils.getConnectorNameString
        <div
          key={index->string_of_int}
          className={`py-4 px-6 flex flex-col gap-4 rounded-md cursor-pointer ${connector->getBlockColor}`}
          onClick={_ => setSelectedConnector(_ => connector)}>
          <div className="flex justify-between items-center">
            <div className="flex gap-2 items-center ">
              <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-8 h-8" />
              <p className=subheaderText>
                {connectorName->LogicUtils.capitalizeString->React.string}
              </p>
            </div>
            <Icon
              name={connector === selectedConnector ? "selected" : "nonselected"}
              size=20
              className="cursor-pointer !text-blue-800"
            />
          </div>
          <p className=subTextStyle> {connectorInfo.description->React.string} </p>
        </div>
      })
      ->React.array}
    </div>
  </div>
}
