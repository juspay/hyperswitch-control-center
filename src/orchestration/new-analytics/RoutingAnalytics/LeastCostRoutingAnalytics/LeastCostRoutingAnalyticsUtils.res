open LeastCostRoutingAnalyticsTypes

let filterDict =
  [
    (
      (#routing_approach: requestPayloadMetrics :> string),
      [(#debit_routing: requestPayloadMetrics :> string)->JSON.Encode.string]->JSON.Encode.array,
    ),
    (
      (#is_debit_routed: requestPayloadMetrics :> string),
      [true->JSON.Encode.bool]->JSON.Encode.array,
    ),
  ]->LogicUtils.getJsonFromArrayOfJson
