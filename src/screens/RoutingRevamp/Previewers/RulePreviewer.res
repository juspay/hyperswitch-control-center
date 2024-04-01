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
          key={Int.toString(index)}
          className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 dark:border-jp-gray-960 font-medium text-blue-500 hover:text-blue-500 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950 focus:outline-none px-2 gap-1">
          {connectorStr->React.string}
          <UIUtils.RenderIf condition={percent->Option.isSome}>
            <span className="text-jp-gray-700 dark:text-jp-gray-600 ml-1">
              {(percent->Option.getOr(0)->Int.toString ++ "%")->React.string}
            </span>
          </UIUtils.RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}

module ThreedsTypeView = {
  @react.component
  let make = (~threeDsType) => {
    <div
      className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 font-medium text-blue-500 hover:text-blue-500 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200  focus:outline-none px-2 gap-1">
      {threeDsType->LogicUtils.capitalizeString->React.string}
    </div>
  }
}

module SurchargeCompressedView = {
  @react.component
  let make = (~surchargeType, ~surchargeTypeValue, ~surchargePercentage) => {
    <div
      className="my-2 h-6 md:h-8 flex items-center rounded-md border border-jp-gray-500 font-medium text-blue-500 hover:text-blue-500 bg-gradient-to-b from-jp-gray-250 to-jp-gray-200  focus:outline-none px-2 gap-1">
      {`${surchargeType} -> ${surchargeTypeValue->Float.toString} | Tax on Surcharge -> ${surchargePercentage
        ->Option.getOr(0.0)
        ->Float.toString}`
      ->LogicUtils.capitalizeString
      ->React.string}
    </div>
  }
}

@react.component
let make = (~ruleInfo: algorithmData, ~isFrom3ds=false, ~isFromSurcharge=false) => {
  open LogicUtils

  <div
    className=" bg-white border  flex flex-col divide-y  divide-jp-gray-600  border-jp-gray-600 ">
    <AddDataAttributes attributes=[("data-component", "rulePreviewer")]>
      <div>
        <div className="flex flex-col divide-y  divide-jp-gray-600  border-t  border-b">
          {ruleInfo.rules
          ->Array.mapWithIndex((rule, index) => {
            let statementsArr = rule.statements
            let headingText = `Rule ${Int.toString(index + 1)}`
            let marginStyle = index === ruleInfo.rules->Array.length - 1 ? "mt-2" : "my-2"
            let threeDsType = rule.connectorSelection.override_3ds->Option.getOr("")

            let surchargeType =
              rule.connectorSelection.surcharge_details->SurchargeUtils.getDefaultSurchargeType
            let surchargePercent = surchargeType.surcharge.value.percentage->Option.getOr(0.0)
            let surchargeAmount = surchargeType.surcharge.value.amount->Option.getOr(0.0)
            let surchargeTypeValue = if surchargeAmount > 0.0 {
              surchargeAmount
            } else {
              surchargePercent
            }
            <div key={Int.toString(index)} className="flex flex-col items-center w-full px-4 pb-6">
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

                    let logical = statement.logical->Option.getOr("")
                    let operator = getOperatorFromComparisonType(comparison, typeString)
                    let field = statement.lhs
                    let metadataDict =
                      statement.metadata
                      ->Option.getOr(Dict.make()->JSON.Encode.object)
                      ->getDictFromJsonObject

                    let value = switch statement.value.value->JSON.Classify.classify {
                    | Array(arr) => arr->Array.joinWithUnsafe(", ")
                    | String(str) => str
                    | Number(num) => num->Float.toString
                    | Object(obj) => obj->LogicUtils.getString("value", "")
                    | _ => ""
                    }

                    let metadataKeyValue = switch statement.value.value->JSON.Classify.classify {
                    | Object(obj) => obj->LogicUtils.getString("key", "")
                    | _ => ""
                    }

                    let metadataKey = metadataDict->getOptionString("key")
                    <div key={Int.toString(index)} className="flex flex-wrap items-center gap-2">
                      <UIUtils.RenderIf condition={index !== 0}>
                        <MakeRuleFieldComponent.TextView
                          str=logical fontColor="text-blue-500" fontWeight="font-semibold"
                        />
                      </UIUtils.RenderIf>
                      <MakeRuleFieldComponent.TextView str=field />
                      <UIUtils.RenderIf condition={typeString == "metadata_variant"}>
                        <MakeRuleFieldComponent.TextView str=metadataKeyValue />
                      </UIUtils.RenderIf>
                      <UIUtils.RenderIf condition={metadataKey->Option.isSome}>
                        <MakeRuleFieldComponent.TextView str={metadataKey->Option.getOr("")} />
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
                  <ThreedsTypeView threeDsType />
                </UIUtils.RenderIf>
                <UIUtils.RenderIf condition={!isFrom3ds}>
                  <GatewayView gateways={rule.connectorSelection.data->Option.getOr([])} />
                </UIUtils.RenderIf>
                <UIUtils.RenderIf condition={isFromSurcharge}>
                  <SurchargeCompressedView
                    surchargeType={surchargeType.surcharge.\"type"}
                    surchargeTypeValue
                    surchargePercentage={surchargeType.tax_on_surcharge.percentage}
                  />
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
