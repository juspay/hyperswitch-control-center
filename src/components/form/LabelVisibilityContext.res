let formLabelRenderContext = React.createContext(true)

module Provider = {
  let make = React.Context.provider(formLabelRenderContext)
}

@react.component
let make = (~children, ~showLabel) => {
  <Provider value=showLabel>
    <div> children </div>
  </Provider>
}
