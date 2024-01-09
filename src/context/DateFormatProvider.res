let defaultValue = "MMM DD, YYYY hh:mm A"
let dateFormatContext = React.createContext(defaultValue)

@live
let make = React.Context.provider(dateFormatContext)
