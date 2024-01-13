let ignoreAttributesContext = React.createContext(false)

module Provider = {
  let make = React.Context.provider(ignoreAttributesContext)
}

@react.component
let make = (~children, ~ignoreAttributes) => {
  <Provider value=ignoreAttributes>
    <div> children </div>
  </Provider>
}
