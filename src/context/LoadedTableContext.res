type infoData

external toInfoData: 'a => array<Js.Nullable.t<infoData>> = "%identity"

let arr: array<Js.Nullable.t<infoData>> = []

let loadedTableContext = React.createContext(arr)

let make = React.Context.provider(loadedTableContext)
