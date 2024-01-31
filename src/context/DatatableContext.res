let defaultValue: Dict.t<array<JSON.t>> = Dict.make()
let setDefaultValue: (Js.Dict.key, array<JSON.t>) => unit = (_string, _arr) => ()

let datatableContext = React.createContext((defaultValue, setDefaultValue))

let make = React.Context.provider(datatableContext)
