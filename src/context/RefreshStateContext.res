let defaultSetter = (_: int => int) => ()

let refreshStateContext = React.createContext((0, defaultSetter))

let make = React.Context.provider(refreshStateContext)

let useRefreshTrigger = () => {
  let (refreshData, _) = React.useContext(refreshStateContext)
  refreshData
}
