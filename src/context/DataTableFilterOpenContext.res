let defaultValue: Dict.t<bool> = Dict.make()
let setDefaultValue: (string, bool) => unit = (_key, _b) => ()

let filterOpenContext = React.createContext((defaultValue, setDefaultValue))

let make = React.Context.provider(filterOpenContext)
