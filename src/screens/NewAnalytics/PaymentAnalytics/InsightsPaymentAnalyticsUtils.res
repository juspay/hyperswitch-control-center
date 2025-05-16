open LogicUtils

let getColor = index => {
  open InsightsUtils
  [blue, green]->Array.get(index)->Option.getOr(blue)
}

let getAmountValue = (data, ~id) => {
  switch data->getOptionFloat(id) {
  | Some(value) => value /. 100.0
  | _ => 0.0
  }
}

let getLineGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
  ~isAmount=false,
): LineGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    let dict = item->getDictFromJsonObject
    if isAmount {
      dict->getAmountValue(~id=key)
    } else {
      dict->getFloat(key, 0.0)
    }
  })
  let dataObj: LineGraphTypes.dataObj = {
    showInLegend: true,
    name,
    data,
    color,
  }
  dataObj
}

let getBarGraphData = (json: JSON.t, key: string, barColor: string): BarGraphTypes.data => {
  json
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let data =
      item
      ->getDictFromJsonObject
      ->getArrayFromDict("queryData", [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getFloat(key, 0.0)
      })
    let dataObj: BarGraphTypes.dataObj = {
      showInLegend: false,
      name: `Series ${(index + 1)->Int.toString}`,
      data,
      color: barColor,
    }
    dataObj
  })
}

let getSmartRetryMetricType = isSmartRetryEnabled => {
  open InsightsTypes
  switch isSmartRetryEnabled {
  | true => Smart_Retry
  | false => Default
  }
}

let getEntityForSmartRetry = isEnabled => {
  open InsightsTypes
  open APIUtilsTypes
  switch isEnabled {
  | Smart_Retry => ANALYTICS_PAYMENTS
  | Default => ANALYTICS_PAYMENTS_V2
  }
}
