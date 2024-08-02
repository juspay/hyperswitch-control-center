open PerformanceMonitorTypes
let getFilterForConnectorPerformance = (~dimensions, ~status: array<status>) => {
  let filters = Dict.make()
  let connector =
    PerformanceMonitorEntity.getSpecificDimension(dimensions, #connector).values->Array.map(v =>
      v->JSON.Encode.string
    )
  let status = status->Array.map(v => (v: status :> string)->JSON.Encode.string)
  filters->Dict.set("connector", connector->JSON.Encode.array)
  filters->Dict.set("status", status->JSON.Encode.array)
  filters->JSON.Encode.object
}

let getGroupByForConnectorPerformance = (~dimensions: array<dimension>) => {
  dimensions->Array.map(v => (v: dimension :> string)->JSON.Encode.string)->JSON.Encode.array
}
