let defaultSetter = (_: option<AuthHooks.betaEndpoint>) => ()
let defaultValue: option<AuthHooks.betaEndpoint> = None
let betaEndPointConfig = React.createContext(defaultValue)

let make = React.Context.provider(betaEndPointConfig)
