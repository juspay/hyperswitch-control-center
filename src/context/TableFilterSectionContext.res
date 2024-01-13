let filterSectionContext = React.createContext(false)

module Provider = {
  let make = React.Context.provider(filterSectionContext)
}

@react.component
let make = (~children, ~isFilterSection) => {
  <Provider value=isFilterSection> children </Provider>
}
