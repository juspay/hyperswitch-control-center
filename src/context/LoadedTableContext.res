type infoData

external toInfoData: 'a => array<Nullable.t<infoData>> = "%identity"

let arr: array<Nullable.t<infoData>> = []

let loadedTableContext = React.createContext(arr)

let make = React.Context.provider(loadedTableContext)
