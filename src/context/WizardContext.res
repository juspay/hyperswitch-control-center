type nextPage = unit => unit
let nextPageFn: nextPage = () => ()

let setNextPageFn = (_: nextPage) => ()

let wizardContext = React.createContext((nextPageFn, setNextPageFn))

let make = React.Context.provider(wizardContext)
