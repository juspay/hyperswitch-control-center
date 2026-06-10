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

    <div className="flex flex-wrap gap-4 items-center">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        let (connectorLabel, connectorName) = switch getConnectorObj(ruleGateway.gateway_name) {
        | Some(obj) => (obj.connector_label, obj.connector_name)
        | None => (ruleGateway.gateway_name, "")
        }

        <div
          key={Int.toString(index)}
          className="flex items-center gap-2 h-10 px-3 bg-nd_gray-0 border border-nd_gray-300 rounded-[10px]">
          <RenderIf condition={connectorName->LogicUtils.isNonEmptyString}>
            <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-6 h-6" />
          </RenderIf>
          <p className={`${body.md.medium} text-nd_gray-600`}> {connectorLabel->React.string} </p>
          <RenderIf condition={ruleGateway.distribution !== 100}>
            <span className={`${body.md.medium} text-nd_gray-400`}>
              {(ruleGateway.distribution->Int.toString ++ "%")->React.string}
            </span>
          </RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}
