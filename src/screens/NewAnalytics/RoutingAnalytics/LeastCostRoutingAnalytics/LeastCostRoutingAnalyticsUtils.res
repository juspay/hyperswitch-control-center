open LeastCostRoutingAnalyticsTypes

let filterDict = Dict.make()
Dict.set(
  filterDict,
  (#routing_approach: requestPayloadMetrics :> string),
  [(#debit_routing: requestPayloadMetrics :> string)->JSON.Encode.string]->JSON.Encode.array,
)
Dict.set(
  filterDict,
  (#is_debit_routed: requestPayloadMetrics :> string),
  [true->JSON.Encode.bool]->JSON.Encode.array,
)
