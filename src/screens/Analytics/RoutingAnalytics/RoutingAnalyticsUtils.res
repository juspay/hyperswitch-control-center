open RoutingAnalyticsTypes
open LogicUtils

let globalFilter: array<filters> = [
  #connector,
  #payment_method,
  #payment_method_type,
  #currency,
  #authentication_type,
  #status,
  #client_source,
  #client_version,
  #profile_id,
  #card_network,
  #merchant_id,
  #routing_approach,
]

let filterCurrencyFromDimensions = data =>
  data
  ->getDictFromJsonObject
  ->getArrayFromDict("dimensions", [])
  ->Array.filter(dim => {
    dim->getDictFromJsonObject->getString("name", "") !== "currency"
  })
