open RoutingAnalyticsTypes

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

let generateFilterObject = (~globalFilters, ~localFilters=None) => {
  let filters = Dict.make()

  let globalFiltersList = globalFilter->Array.map(filter => {
    (filter: filters :> string)
  })

  let parseValue = value => {
    switch value->JSON.Classify.classify {
    | Array(arr) =>
      arr->Array.map(item => item->JSON.Decode.string->Option.getOr("")->JSON.Encode.string)
    | String(str) => str->String.split(",")->Array.map(JSON.Encode.string)
    | _ => []
    }
  }

  globalFilters
  ->Dict.toArray
  ->Array.forEach(item => {
    let (key, value) = item
    if globalFiltersList->Array.includes(key) && value->parseValue->Array.length > 0 {
      filters->Dict.set(key, value->parseValue->JSON.Encode.array)
    }
  })

  switch localFilters {
  | Some(dict) =>
    dict
    ->Dict.toArray
    ->Array.forEach(item => {
      let (key, value) = item
      filters->Dict.set(key, value)
    })
  | None => ()
  }

  filters->JSON.Encode.object
}
