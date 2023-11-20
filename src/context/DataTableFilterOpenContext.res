let defaultValue: Js.Dict.t<bool> = Js.Dict.empty()
let setDefaultValue: (Js.Dict.key, bool) => unit = (_key, _b) => ()

let filterOpenContext = React.createContext((defaultValue, setDefaultValue))

let make = React.Context.provider(filterOpenContext)
