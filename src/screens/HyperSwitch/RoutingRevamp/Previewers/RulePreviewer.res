open AdvancedRoutingTypes
open AdvancedRoutingUtils

module GatewayView = {
  @react.component
  let make = (~gateways) => {
    <div className="flex flex-wrap gap-4 items-center">
      {gateways
      ->Array.mapWithIndex((ruleGateway, index) => {
        let (connectorStr, percent) = switch ruleGateway {
        | PriorityObject(obj) => (obj.connector, None)
        | VolumeObject(obj) => (obj.connector.connector, Some(obj.split))
        }
        <div
          key={Belt.Int.toString(index)}
          className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 dark:border-jp-gray-960 font-medium text-blue-800 hover:text-blue-900 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 focus:outline-none px-2 gap-1">
          {connectorStr->React.string}
          <UIUtils.RenderIf condition={percent->Belt.Option.isSome}>
            <span className="text-jp-gray-700 dark:text-jp-gray-600 ml-1">
              {(percent->Belt.Option.getWithDefault(0)->string_of_int ++ "%")->React.string}
            </span>
          </UIUtils.RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (~ruleInfo: algorithmData, ~isFrom3ds=false, ~isFromSurcharge=false) => {
  open LogicUtils

  <div
    className=" bg-white border border-jp-gray-600 flex flex-col divide-y  divide-jp-gray-600  border-jp-gray-600 ">
    <AddDataAttributes attributes=[("data-component", "rulePreviewer")]>
      <div>
        <div className="flex flex-col divide-y  divide-jp-gray-600  border-t  border-b">
          {ruleInfo.rules
          ->Array.mapWithIndex((rule, index) => {
            let statementsArr = rule.statements
            let headingText = `Rule ${string_of_int(index + 1)}`
            let marginStyle = index === ruleInfo.rules->Array.length - 1 ? "mt-2" : "my-2"
            let threeDsType = rule.connectorSelection.override_3ds->Belt.Option.getWithDefault("")

            let surchargeType =
              rule.connectorSelection.surcharge_details->SurchargeUtils.getDefaultSurchargeType
            let surchargePercent =
              surchargeType.surcharge.value.percentage->Option.getWithDefault(0.0)
            let surchargeAmount = surchargeType.surcharge.value.amount->Option.getWithDefault(0.0)
            let surchargeTypeValue = if surchargeAmount > 0.0 {
              surchargeAmount
            } else {
              surchargePercent
            }
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
                  {statementsArr
                  ->Array.mapWithIndex((statement, index) => {
                    let comparison = statement.comparison
                    let typeString = statement.value.\"type"

                    let logical = statement.logical->Belt.Option.getWithDefault("")
                    let operator = getOperatorFromComparisonType(comparison, typeString)
                    let field = statement.lhs
                    let metadataDict =
                      statement.metadata
                      ->Belt.Option.getWithDefault(Dict.make()->Js.Json.object_)
                      ->getDictFromJsonObject

                    let value = switch statement.value.value->Js.Json.classify {
                    | JSONArray(arr) => arr->Array.joinWith(", ")
                    | JSONString(str) => str
                    | JSONNumber(num) => num->Belt.Float.toString
                    | JSONObject(obj) => obj->LogicUtils.getString("value", "")
                    | _ => ""
                    }

                    let metadataKeyValue = switch statement.value.value->Js.Json.classify {
                    | JSONObject(obj) => obj->LogicUtils.getString("key", "")
                    | _ => ""
                    }

                    let metadataKey = metadataDict->getOptionString("key")
                    <div
                      key={Belt.Int.toString(index)} className="flex flex-wrap items-center gap-2">
                      <UIUtils.RenderIf condition={index !== 0}>
                        <MakeRuleFieldComponent.TextView
                          str=logical fontColor="text-blue-800" fontWeight="font-semibold"
                        />
                      </UIUtils.RenderIf>
                      <MakeRuleFieldComponent.TextView str=field />
                      <UIUtils.RenderIf condition={typeString == "metadata_variant"}>
                        <MakeRuleFieldComponent.TextView str=metadataKeyValue />
                      </UIUtils.RenderIf>
                      <UIUtils.RenderIf condition={metadataKey->Belt.Option.isSome}>
                        <MakeRuleFieldComponent.TextView
                          str={metadataKey->Belt.Option.getWithDefault("")}
                        />
                      </UIUtils.RenderIf>
                      <MakeRuleFieldComponent.TextView
                        str=operator fontColor="text-red-500" fontWeight="font-semibold"
                      />
                      <MakeRuleFieldComponent.TextView str=value />
                    </div>
                  })
                  ->React.array}
                </div>
                <UIUtils.RenderIf condition={rule.statements->Array.length > 0}>
                  <Icon size=14 name="arrow-right" className="mx-4 text-jp-gray-700" />
                </UIUtils.RenderIf>
                <UIUtils.RenderIf condition={isFrom3ds}>
                  <div
                    className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 font-medium text-blue-800 hover:text-blue-900 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200  focus:outline-none px-2 gap-1">
                    {threeDsType->LogicUtils.capitalizeString->React.string}
                  </div>
                </UIUtils.RenderIf>
                <UIUtils.RenderIf condition={!isFrom3ds}>
                  <GatewayView
                    gateways={rule.connectorSelection.data->Belt.Option.getWithDefault([])}
                  />
                </UIUtils.RenderIf>
                <UIUtils.RenderIf condition={isFromSurcharge}>
                  <div
                    className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 font-medium text-blue-800 hover:text-blue-900 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200  focus:outline-none px-2 gap-1">
                    {`${surchargeType.surcharge.\"type"} -> ${surchargeTypeValue->Belt.Float.toString} | Tax on Surcharge -> ${surchargeType.tax_on_surcharge.percentage
                      ->Option.getWithDefault(0.0)
                      ->Belt.Float.toString}`
                    ->LogicUtils.capitalizeString
                    ->React.string}
                  </div>
                </UIUtils.RenderIf>
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </AddDataAttributes>
  </div>
}
