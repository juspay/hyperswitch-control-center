open LogicUtils

let getColor = index => {
  open NewAnalyticsUtils
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

let getGroupValue = (~itemDict, ~groupByKey) =>
  if groupByKey === "payment_method,payment_method_type" {
    let paymentMethod = itemDict->getString("payment_method", "")
    let paymentMethodType = itemDict->getString("payment_method_type", "")
    `${paymentMethod},${paymentMethodType}`
  } else {
    itemDict->getString(groupByKey, "")
  }

let aggregateItem = (~itemDict, ~existingItem, ~aggregatableFields) => {
  let existingDict = existingItem->getDictFromJsonObject
  aggregatableFields->Array.forEach(field => {
    let existingValue = existingDict->getFloat(field, 0.0)
    let newValue = itemDict->getFloat(field, 0.0)
    existingDict->Dict.set(field, (existingValue +. newValue)->JSON.Encode.float)
  })
  let totalCount = existingDict->getFloat("payment_count", 0.0)
  if totalCount > 0.0 {
    let successCount = existingDict->getFloat("payment_success_count", 0.0)
    let failedCount = totalCount -. successCount
    let successRate = successCount /. totalCount *. 100.0
    let failureRate = failedCount /. totalCount *. 100.0
    let rateFields = [
      ("payment_success_rate", successRate),
      ("payment_failure_rate", failureRate),
      ("payments_success_rate_distribution", successRate),
      ("payments_failure_rate_distribution", failureRate),
      ("payments_success_rate_distribution_without_smart_retries", successRate),
      ("payments_failure_rate_distribution_without_smart_retries", failureRate),
    ]
    rateFields->Array.forEach(((field, value)) =>
      existingDict->Dict.set(field, value->JSON.Encode.float)
    )
  }
  existingDict
}

let aggregateSampleDataByGroupBy = (data: array<JSON.t>, groupByKey: string) => {
  let aggregatedDict = Dict.make()
  let aggregatableFields = [
    "payment_count",
    "payment_success_count",
    "payment_processed_amount",
    "payment_processed_amount_in_usd",
    "payment_processed_count",
    "failure_reason_count",
    "failure_reason_count_without_smart_retries",
  ]

  data->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let groupValue = getGroupValue(~itemDict, ~groupByKey)

    if groupValue->isNonEmptyString {
      switch aggregatedDict->Dict.get(groupValue) {
      | Some(existingItem) =>
        let updatedDict = aggregateItem(~itemDict, ~existingItem, ~aggregatableFields)
        aggregatedDict->Dict.set(groupValue, updatedDict->JSON.Encode.object)
      | None => aggregatedDict->Dict.set(groupValue, item)
      }
    }
  })

  aggregatedDict->Dict.valuesToArray
}
