open LeastCostRoutingAnalyticsMetricsTypes
open LogicUtils

let metricsQueryDataItemToObjMapper = dict => {
  {
    debit_routed_transaction_count: dict->getInt("debit_routed_transaction_count", 0),
    debit_routing_savings_in_usd: dict->getFloat("debit_routing_savings_in_usd", 0.0),
    is_issuer_regulated: dict->getOptionBool("is_issuer_regulated"),
  }
}

let metricsResponseItemToObjMapper = dict => {
  {
    queryData: dict
    ->getJsonObjectFromDict("queryData")
    ->getArrayDataFromJson(metricsQueryDataItemToObjMapper),
  }
}

let calculateRegulatedPercentages = (queryData: array<metricsQueryDataResponse>) => {
  let (regulatedCount, unregulatedCount) = queryData->Array.reduce((0, 0), (
    (regCount, unregCount),
    item,
  ) => {
    switch item.is_issuer_regulated {
    | Some(true) => (regCount + item.debit_routed_transaction_count, unregCount)
    | Some(false) => (regCount, unregCount + item.debit_routed_transaction_count)
    | None => (regCount, unregCount)
    }
  })

  let totalCount = regulatedCount + unregulatedCount

  if totalCount > 0 {
    let regulatedPercentage = regulatedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0
    let unregulatedPercentage = unregulatedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0
    (regulatedPercentage, unregulatedPercentage)
  } else {
    (0.0, 0.0)
  }
}
