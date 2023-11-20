open HyperSwitchAuthTypes
let defaultSetter = (_: authStatus) => ()

let authStatusContext = React.createContext((LoggedOut, defaultSetter))

let make = React.Context.provider(authStatusContext)
