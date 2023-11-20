let selectedTextWeightContext = React.createContext(false)

module Provider = {
  let make = React.Context.provider(selectedTextWeightContext)
}

@react.component
let make = (~children, ~isDropdownSelectedTextDark) => {
  <Provider value=isDropdownSelectedTextDark>
    <div> children </div>
  </Provider>
}
