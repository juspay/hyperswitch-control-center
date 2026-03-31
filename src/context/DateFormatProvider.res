let defaultValue = "MMM DD, YYYY hh:mm:ss.SSS A"
let dateFormatContext = React.createContext(defaultValue)

@live
let make = React.Context.provider(dateFormatContext)
