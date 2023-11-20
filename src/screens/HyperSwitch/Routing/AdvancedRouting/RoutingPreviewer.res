open RoutingTypes
open RoutingUtils

module SimplePreview = {
  @react.component
  let make = (~gateways) => {
    if gateways->Js.Array2.length > 0 {
      <div
        className="w-full mb-6 p-4 px-6 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850">
        <div
          className="flex flex-col mt-6 mb-4 rounded-md  border border-jp-gray-500 dark:border-jp-gray-960 divide-y divide-jp-gray-500 dark:divide-jp-gray-960">
          {gateways
          ->Array.mapWithIndex((item, i) => {
            <div
              className="h-12 flex flex-row items-center gap-4
             text-jp-gray-900 dark:text-jp-gray-text_darktheme px-3 ">
              <div className="px-1.5 rounded-full bg-blue-800 text-white font-semibold text-sm">
                {React.string(string_of_int(i + 1))}
              </div>
              <div> {React.string(item)} </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    } else {
      React.null
    }
  }
}
module GatewayView = {
  @react.component
  let make = (~gateways, ~isEnforceGatewayPriority, ~connectorList=?) => {
    let getGatewayName = name => {
      switch connectorList {
      | Some(list) => (list->ConnectorTableUtils.getConnectorNameViaId(name)).connector_label
      | None => name
      }
    }
    let isDisableFallback = gateways->Js.Array2.some(ruleGateway => ruleGateway.disableFallback)
    <div className="flex flex-wrap gap-4 items-center">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        <AddDataAttributes
          key={Belt.Int.toString(index)}
          attributes=[("data-plc-text", ruleGateway.gateway_name->getGatewayName)]>
          <div
            key={Belt.Int.toString(index)}
            className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 dark:border-jp-gray-960 font-medium text-blue-800 hover:text-blue-900 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 focus:outline-none px-2 gap-1">
            {if ruleGateway.disableFallback {
              <CheckBoxIcon isSelected=ruleGateway.disableFallback isDisabled=false />
            } else {
              React.null
            }}
            {ruleGateway.gateway_name->getGatewayName->React.string}
            {if ruleGateway.distribution !== 100 {
              <span className="text-jp-gray-700 dark:text-jp-gray-600 ml-1">
                {(ruleGateway.distribution->string_of_int ++ "%")->React.string}
              </span>
            } else {
              React.null
            }}
          </div>
        </AddDataAttributes>
      })
      ->React.array}
      {if isEnforceGatewayPriority {
        <div className="flex flex-row gap-1 ml-5 items-center ">
          <CheckBoxIcon isSelected=isEnforceGatewayPriority isDisabled=false />
          <div> {"Enforce Gateway Priority"->React.string} </div>
        </div>
      } else {
        React.null
      }}
      {if isDisableFallback {
        <div className="flex flex-row gap-1 ml-5 items-center ">
          <CheckBoxIcon isSelected=isDisableFallback isDisabled=false />
          <div> {"Disable Fallback"->React.string} </div>
        </div>
      } else {
        React.null
      }}
    </div>
  }
}
module RulePreviewer = {
  @react.component
  let make = (~ruleInfo: ruleInfoType, ~isFrom3ds=false) => {
    open LogicUtils
    <div
      className=" bg-white border border-jp-gray-600 flex flex-col divide-y  divide-jp-gray-600  border-jp-gray-600 ">
      <AddDataAttributes attributes=[("data-component", "rulePreviewer")]>
        <div>
          <div className="flex flex-col divide-y  divide-jp-gray-600  border-t  border-b">
            {ruleInfo.rules
            ->Array.mapWithIndex((rule, index) => {
              let headingText = `Rule ${string_of_int(index + 1)}`
              let marginStyle = index === ruleInfo.rules->Js.Array2.length - 1 ? "mt-2" : "my-2"
              let threeDsType =
                rule.routingOutput->Belt.Option.getWithDefault(defaultThreeDsObjectValue)
              <div
                key={Belt.Int.toString(index)}
                className="flex flex-col items-center w-full px-4 pb-6">
                <div
                  style={ReactDOMStyle.make(~marginTop="-1.2rem", ())}
                  className="text-jp-gray-700 dark:text-jp-gray-700 text-base font-semibold p-1 px-3 bg-jp-gray-50 dark:bg-jp-gray-950 rounded-full border border-jp-gray-600 dark:border-jp-gray-850">
                  {headingText->React.string}
                </div>
                <div className={`w-full flex flex-wrap items-center ${marginStyle}`}>
                  <div className="flex flex-wrap gap-2">
                    {rule.conditions
                    ->RoutingUtils.filterEmptyValues
                    ->Array.mapWithIndex((condition, index) => {
                      let logical = logicalOperatorTypeToStringMapper(condition.logicalOperator)
                      let operator = operatorTypeToStringMapper(condition.operator)
                      let field = condition.field->Js.String2.length > 0 ? condition.field : ""

                      let value = switch condition.value {
                      | StringArray(arr) => arr->Js.Array2.joinWith(", ")
                      | String(str) => str
                      | Int(int) => int->Belt.Int.toString
                      }
                      let metadataKey = switch condition.metadata {
                      | Some(json) => json->getDictFromJsonObject->getOptionString("key")
                      | _ => None
                      }

                      <div
                        key={Belt.Int.toString(index)}
                        className="flex flex-wrap items-center gap-2">
                        <UIUtils.RenderIf condition={index !== 0}>
                          <MakeRuleFieldComponent.TextView
                            str=logical fontColor="text-blue-800" fontWeight="font-semibold"
                          />
                        </UIUtils.RenderIf>
                        <MakeRuleFieldComponent.TextView str=field />
                        {switch metadataKey {
                        | Some(key) => <MakeRuleFieldComponent.TextView str=key />
                        | None => React.null
                        }}
                        <MakeRuleFieldComponent.TextView
                          str=operator fontColor="text-red-500" fontWeight="font-semibold"
                        />
                        <MakeRuleFieldComponent.TextView str=value />
                      </div>
                    })
                    ->React.array}
                  </div>
                  <UIUtils.RenderIf condition={rule.conditions->Js.Array2.length > 0}>
                    <Icon size=14 name="arrow-right" className="mx-4 text-jp-gray-700" />
                  </UIUtils.RenderIf>
                  <UIUtils.RenderIf condition={isFrom3ds}>
                    <div
                      className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 font-medium text-blue-800 hover:text-blue-900 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200  focus:outline-none px-2 gap-1">
                      {threeDsType.override_3ds->LogicUtils.capitalizeString->React.string}
                    </div>
                  </UIUtils.RenderIf>
                  <UIUtils.RenderIf condition={!isFrom3ds}>
                    <GatewayView gateways=rule.gateways isEnforceGatewayPriority=false />
                  </UIUtils.RenderIf>
                </div>
              </div>
            })
            ->React.array}
          </div>
          <UIUtils.RenderIf condition={!isFrom3ds}>
            <div
              className="flex flex-col md:flex-row md:items-center gap-2 md:gap-6 mx-6 my-2 text-jp-gray-700">
              <div className="flex flex-row items-center gap-2 mt-4 md:mt-0">
                <Icon
                  name="arrow-rotate"
                  size=14
                  className="cursor-pointer text-jp-gray-700"
                  onClick={ev => ()}
                />
                <div>
                  {React.string("Default Processors")}
                  <span className="text-red-500"> {React.string(" *")} </span>
                </div>
              </div>
              <div className="flex flex-wrap items-center gap-4">
                {ruleInfo.default_gateways
                ->Array.mapWithIndex((gateway, index) => {
                  <div
                    key={Belt.Int.toString(index)}
                    className="flex flex-row items-center gap-2 my-2 md:my-4 text-jp-gray-700">
                    <div
                      className="px-1.5 md:px-2 rounded-full bg-jp-gray-300 dark:bg-jp-gray-900 text-jp-gray-700 dark:text-jp-gray-600 font-semibold text-sm md:text-md">
                      {React.string(string_of_int(index + 1))}
                    </div>
                    <div> {gateway->React.string} </div>
                    {if index !== ruleInfo.default_gateways->Js.Array2.length - 1 {
                      <Icon
                        name="chevron-right"
                        size=14
                        className="cursor-pointer text-jp-gray-700"
                        onClick={ev => ()}
                      />
                    } else {
                      React.null
                    }}
                  </div>
                })
                ->React.array}
              </div>
            </div>
          </UIUtils.RenderIf>
        </div>
      </AddDataAttributes>
    </div>
  }
}
