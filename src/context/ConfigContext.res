type uiconfig = {
  uiConfig: UIConfig.t,
  setUIConfig: (UIConfig.t => UIConfig.t) => unit,
}
let defaultConfig = {
  uiConfig: UIConfig.defaultUIConfig,
  setUIConfig: _ => (),
}
let configContext = React.createContext(defaultConfig)

module Provider = {
  let make = React.Context.provider(configContext)
}

@react.component
let make = (~children) => {
  let (uiConfig, setUIConfig) = React.useState(_ => UIConfig.defaultUIConfig)
  <Provider value={uiConfig, setUIConfig}> children </Provider>
}
