open LeastCostRoutingAnalyticsMetricsTypes
open LogicUtils
open RoutingAnalyticsUtils

let metricsQueryDataItemToObjMapper = dict => {
  {
    debit_routed_transaction_count: dict->getInt("debit_routed_transaction_count", 0),
    debit_routing_savings_in_usd: dict->getFloat("debit_routing_savings_in_usd", 0.0),
    is_issuer_regulated: dict->getOptionBool("is_issuer_regulated"),
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
    let regulatedPercentage = calculateTrafficPercentage(regulatedCount, totalCount)
    let unregulatedPercentage = calculateTrafficPercentage(unregulatedCount, totalCount)
    (regulatedPercentage, unregulatedPercentage)
  } else {
    (0.0, 0.0)
  }
}

let basicsMetricsMapper = data => {
  let savings = sumFloatField(data, "debit_routing_savings_in_usd")
  let transactions = sumIntField(data, "debit_routed_transaction_count")
  {
    debit_routing_savings_in_usd: savings,
    debit_routed_transaction_count: transactions,
    is_issuer_regulated: None,
  }
}
