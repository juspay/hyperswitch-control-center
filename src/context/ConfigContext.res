type uiconfig = {
  uiConfig: UIConfigTypes.t,
  setUIConfig: (UIConfigTypes.t => UIConfigTypes.t) => unit,
}
let defaultConfig = {
  uiConfig: HyperSwitchDefaultConfig.getUIConfigs(),
  setUIConfig: _ => (),
}
let configContext = React.createContext(defaultConfig)

module Provider = {
  let make = React.Context.provider(configContext)
}

@react.component
let make = (~children) => {
  let (uiConfig, setUIConfig) = React.useState(_ => HyperSwitchDefaultConfig.getUIConfigs())
  <Provider value={uiConfig, setUIConfig}> children </Provider>
}
