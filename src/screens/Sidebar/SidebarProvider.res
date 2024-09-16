open ProviderTypes

let defaultValue = {
  isSidebarExpanded: false,
  setIsSidebarExpanded: _ => (),
}

let defaultContext = React.createContext(defaultValue)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  let (isSidebarExpanded, setIsSidebarExpanded) = React.useState(_ => false)

  <Provider
    value={
      isSidebarExpanded,
      setIsSidebarExpanded,
    }>
    children
  </Provider>
}
