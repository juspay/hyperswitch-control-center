open RoutingTypes

module SimplePreview = {
  @react.component
  let make = (~gateways) => {
    let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
    <RenderIf condition={gateways->Array.length > 0}>
      <div
        className="w-full mb-6 p-4 px-6 bg-white dark:bg-gray-900 rounded-md border border-gray-300 dark:border-gray-800">
        <div
          className="flex flex-col mt-6 mb-4 rounded-md  border border-gray-250 dark:border-gray-800 divide-y divide-gray-250 dark:divide-gray-800">
          {gateways
          ->Array.mapWithIndex((item, i) => {
            <div
              className="h-12 flex flex-row items-center gap-4
             text-gray-800 dark:text-gray-50 px-3 ">
              <div
                className={`px-1.5 rounded-full ${primaryColor} text-white font-semibold text-sm`}>
                {React.string(Int.toString(i + 1))}
              </div>
              <div> {React.string(item)} </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </RenderIf>
  }
}

module GatewayView = {
  @react.component
  let make = (~gateways, ~connectorList=?) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let getGatewayName = name => {
      switch connectorList {
      | Some(list) =>
        (list->ConnectorTableUtils.getConnectorObjectFromListViaId(name)).connector_label
      | None => name
      }
    }

    <div className="flex flex-wrap gap-4 items-center">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        <div
          key={Int.toString(index)}
          className={`my-2 h-6 md:h-8 flex items-center rounded-md border border-gray-250 dark:border-gray-800 font-medium ${textColor.primaryNormal} hover:${textColor.primaryNormal} bg-gradient-to-b from-gray-25 to-gray-100 dark:from-gray-900 dark:to-gray-900 focus:outline-hidden px-2 gap-1`}>
          {ruleGateway.gateway_name->getGatewayName->React.string}
          {if ruleGateway.distribution !== 100 {
            <span className="text-gray-500 dark:text-gray-300 ml-1">
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
