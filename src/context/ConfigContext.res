type customUIConfig = {
  globalUIConfig: UIConfig.t,
  updateGlobalConfig: Window.customStyle => unit,
}
let defaultGlobalConfig: Window.customStyle = {
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
  let updateGlobalConfig = (customUIConfig: Window.customStyle) => {
    Window.appendStyle(customUIConfig)
  }
  React.useEffect0(() => {
    let _ = Window.appendStyle(defaultGlobalConfig)
    None
  })
  <CustomUIConfig
    value={
      globalUIConfig: UIConfig.defaultUIConfig,
      updateGlobalConfig,
    }>
    children
  </CustomUIConfig>
}
