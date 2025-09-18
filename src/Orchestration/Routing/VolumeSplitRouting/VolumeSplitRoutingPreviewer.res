open RoutingTypes

module GatewayView = {
  @react.component
  let make = (~gateways, ~connectorList=?) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let getGatewayName = name => {
      switch connectorList {
      | Some(list) =>
        (
          list->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(name, ~version=V1)
        ).connector_label
      | None => name
      }
    }

    <div className="flex flex-wrap gap-4 items-center">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        <div
          key={Int.toString(index)}
          className={`my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 dark:border-jp-gray-960 font-medium ${textColor.primaryNormal} hover:${textColor.primaryNormal} bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 focus:outline-none px-2 gap-1`}>
          {ruleGateway.gateway_name->getGatewayName->React.string}
          {if ruleGateway.distribution !== 100 {
            <span className="text-jp-gray-700 dark:text-jp-gray-600 ml-1">
              {(ruleGateway.distribution->Int.toString ++ "%")->React.string}
            </span>
          } else {
            React.null
          }}
        </div>
      })
      ->React.array}
    </div>
  }
}
