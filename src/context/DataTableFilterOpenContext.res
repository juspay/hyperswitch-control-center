let defaultValue: Js.Dict.t<bool> = Dict.make()
let setDefaultValue: (Js.Dict.key, bool) => unit = (_key, _b) => ()

let filterOpenContext = React.createContext((defaultValue, setDefaultValue))

let make = React.Context.provider(filterOpenContext)
