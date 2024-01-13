let defaultSetter = (_: string) => ()
let defaultValue = "MMM DD, YYYY hh:mm A"
let dateFormatContext = React.createContext(defaultValue)

let make = React.Context.provider(dateFormatContext)
