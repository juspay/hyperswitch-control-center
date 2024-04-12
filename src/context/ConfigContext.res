let configContext = React.createContext(UIConfig.defaultUIConfig)

module CustomUIConfig = {
  let make = React.Context.provider(configContext)
}

@react.component
let make = (~children) => {
  React.useEffect0(() => {
    let customStyle: Window.customStyle = {
      primaryColor: "#22c55e",
      primaryHover: "#facc15",
      sidebar: "#b91c1c",
    }
    let _ = Window.appendStyle(customStyle)
    None
  })
  <CustomUIConfig value=UIConfig.defaultUIConfig> children </CustomUIConfig>
}
