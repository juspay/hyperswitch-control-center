let headerTextStyle = "text-xl font-semibold text-grey-700"
let connectorNameStyle = "text-md font-semibold text-grey-700"
let subTextStyle = "text-base font-normal text-grey-700 opacity-50"
let subheaderText = "text-base font-semibold text-grey-700"
@react.component
let make = (~selectedConnector, ~setSelectedConnector, ~pageView, ~setPageView) => {
  let getBlockColor = connector => {
    open ConnectorTypes
    switch (selectedConnector, connector) {
    | (Processors(selectedConnector), Processors(connector))
      if selectedConnector === connector => "border border-blue-700 bg-blue-700 bg-opacity-10 "
    | (_, _) => "border"
    }
  }

  let selectedIconColor = connector => {
    open ConnectorTypes
    switch (selectedConnector, connector) {
    | (Processors(selectedConnector), Processors(connector))
      if selectedConnector === connector => "selected"
    | (_, _) => "nonselected"
    }
  }

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
        <AddDataAttributes attributes=[("data-testid", connectorName)]>
          <div
            key={index->Int.toString}
            className={`py-4 px-6 flex flex-col gap-4 rounded-md cursor-pointer ${connector->getBlockColor}`}
            onClick={_ => setSelectedConnector(_ => connector)}>
            <div className="flex flex-col justify-between items-start gap-4">
              <div className="flex w-full flex-col gap-2">
                <div className="flex w-full justify-between">
                  <GatewayIcon
                    gateway={connector->ConnectorUtils.getConnectorNameString->String.toUpperCase}
                    className="w-10 h-10"
                  />
                  <Icon
                    name={connector->selectedIconColor}
                    size=20
                    className="cursor-pointer !text-blue-800"
                  />
                </div>
                <p className=connectorNameStyle>
                  {connectorName->ConnectorUtils.getDisplayNameForConnector->React.string}
                </p>
              </div>
              <p className=subTextStyle> {connectorInfo.description->React.string} </p>
            </div>
          </div>
        </AddDataAttributes>
      })
      ->React.array}
    </div>
  </div>
}
