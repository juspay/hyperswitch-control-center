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

let uiConfigTyped = (uiConfg: JSON.t) => {
  open LogicUtils
  let dict = uiConfg->getDictFromJsonObject
  let {primaryColor, primaryHover, sidebar} = defaultGlobalConfig
  let value: Window.customStyle = {
    primaryColor: dict->getString("primary_color", primaryColor),
    primaryHover: dict->getString("primary_hover_color", primaryHover),
    sidebar: dict->getString("sidebar_color", sidebar),
  }
  value
}
type screen = Loading | Custom | Success

@react.component
let make = (~children) => {
  let (screenState, setScreenState) = React.useState(_ => Loading)
  let fetchApi = AuthHooks.useApiFetcher()
  let fetchConfig = async () => {
    try {
      let url = `${HSwitchGlobalVars.hyperSwitchFEPrefix}/config/merchant-config`
      let res = await fetchApi(url, ~method_=Get, ())
      let typedConfig = try {
        await res->Fetch.Response.json
      } catch {
      | _ => Exn.raiseError("Error in Config")
      }->uiConfigTyped
      Window.appendStyle(typedConfig)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Custom)
    }
  }
  let updateGlobalConfig = (customUIConfig: Window.customStyle) => {
    Window.appendStyle(customUIConfig)
  }
  React.useEffect0(() => {
    fetchConfig()->ignore

    // let _ = Window.appendStyle(defaultGlobalConfig)
    None
  })

  {
    switch screenState {
    | Success =>
      <CustomUIConfig
        value={
          globalUIConfig: UIConfig.defaultUIConfig,
          updateGlobalConfig,
        }>
        children
      </CustomUIConfig>
    | Custom => <NoDataFound message="Oops! Missing config" renderType=NotFound />
    | _ => React.null
    }
  }
}
