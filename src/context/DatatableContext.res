let defaultValue: Js.Dict.t<array<Js.Json.t>> = Js.Dict.empty()
let setDefaultValue: (Js.Dict.key, array<Js.Json.t>) => unit = (_string, _arr) => ()

let datatableContext = React.createContext((defaultValue, setDefaultValue))

let make = React.Context.provider(datatableContext)
