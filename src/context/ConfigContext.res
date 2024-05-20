type customUIConfig = {
  globalUIConfig: UIConfig.t,
  updateGlobalConfig: HyperSwitchConfigTypes.customStyle => unit,
}
let defaultGlobalConfig: HyperSwitchConfigTypes.customStyle = {
  primaryColor: "#006DF9",
  primaryHover: "#005ED6",
  sidebar: "#242F48",
}

let customUIConfig = {
  globalUIConfig: UIConfig.defaultUIConfig,
  updateGlobalConfig: _defaultGlobalConfig => (),
}

let configContext = React.createContext(customUIConfig)

module CustomUIConfig = {
  let make = React.Context.provider(configContext)
}

@react.component
let make = (~children) => {
  let updateGlobalConfig = (customUIConfig: HyperSwitchConfigTypes.customStyle) => {
    Window.appendStyle(customUIConfig)
  }

  <CustomUIConfig
    value={
      globalUIConfig: UIConfig.defaultUIConfig,
      updateGlobalConfig,
    }>
    children
  </CustomUIConfig>
}
