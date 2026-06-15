open RoutingTypes
open Typography

module GatewayView = {
  @react.component
  let make = (~gateways, ~connectorList=?) => {
    let getConnectorObj = name => {
      switch connectorList {
      | Some(list) =>
        Some(list->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(name, ~version=V1))
      | None => None
      }
    }

    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-4 gap-4">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        let (connectorLabel, connectorName) = switch getConnectorObj(ruleGateway.gateway_name) {
        | Some(obj) => (obj.connector_label, obj.connector_name)
        | None => (ruleGateway.gateway_name, "")
        }

        <div
          key={Int.toString(index)}
          className="flex items-center gap-2 h-10 px-3 overflow-hidden bg-nd_gray-0 border border-nd_gray-300 rounded-10-px">
          <RenderIf condition={connectorName->LogicUtils.isNonEmptyString}>
            <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-6 h-6 shrink-0" />
          </RenderIf>
          <div className="flex-1 min-w-0">
            <ToolTip
              description=connectorLabel
              toolTipPosition=Top
              toolTipFor={<p className={`${body.md.medium} text-nd_gray-600 truncate w-full`}>
                {connectorLabel->React.string}
              </p>}
            />
          </div>
          <RenderIf condition={ruleGateway.distribution !== 100}>
            <span className={`${body.md.medium} text-nd_gray-400 shrink-0`}>
              {(ruleGateway.distribution->Int.toString ++ "%")->React.string}
            </span>
          </RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}
