let defaultSetter = (_: int => int) => ()

let refreshStateContext = React.createContext((0, defaultSetter))

let make = React.Context.provider(refreshStateContext)
