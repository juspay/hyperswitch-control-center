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

let urlConfig = (urlConfig: JSON.t) => {
  open LogicUtils
  let dict = urlConfig->getDictFromJsonObject
  let value: Window.env = {
    apiBaseUrl: dict->getString("api_url", ""),
    sdkBaseUrl: dict->getString("sdk_url", ""),
    mixpanelToken: dict->getString("mixpanelToken", ""),
  }
  Window.env.apiBaseUrl = value.apiBaseUrl
  Window.env.sdkBaseUrl = value.sdkBaseUrl
  Window.env.mixpanelToken = value.mixpanelToken
}
type screen = Custom | Success

@react.component
let make = (~children) => {
  let (screenState, setScreenState) = React.useState(_ => Success)
  let fetchApi = AuthHooks.useApiFetcher()
  let url = RescriptReactRouter.useUrl()
  let fetchConfig = async () => {
    try {
      open LogicUtils
      let domain =
        url.search->getDictFromUrlSearchParams->Dict.get("domain")->Option.getOr("default")
      let apiURL = `${HSwitchGlobalVars.hyperSwitchFEPrefix}/config/merchant-config?domain=${domain}`
      let res = await fetchApi(apiURL, ~method_=Get, ())
      let typedConfig = try {
        await res->Fetch.Response.json
      } catch {
      | _ => Exn.raiseError("Error in Config")
      }
      typedConfig->urlConfig
      Window.appendStyle(typedConfig->uiConfigTyped)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Custom)
    }
  }

  let updateGlobalConfig = (customUIConfig: Window.customStyle) => {
    Window.appendStyle(customUIConfig)
  }

  React.useEffect0(() => {
    let _ = fetchConfig()
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
    }
  }
}
