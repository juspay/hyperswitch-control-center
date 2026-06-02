type theme = Light | Dark

open LogicUtils

let defaultSetter = _ => ()

type themeType = LightTheme

type x = {theme: string}

type customUIConfig = {
  globalUIConfig: UIConfig.t,
  theme: theme,
  themeSetter: theme => unit,
  configCustomDomainTheme: JSON.t => unit,
  getThemesJson: (~themesID: option<string>, ~domain: option<string>=?) => promise<JSON.t>,
  logoURL: option<string>,
}
open HyperSwitchConfigTypes

// Fallback theme when theme.json fails to load or lacks properties. Keep in sync with config/theme.json.
let fallbackThemeConfig: HyperSwitchConfigTypes.customStylesTheme = {
  settings: {
    colors: {
      primary: "#006DF9",
      secondary: "#303E5F",
      background: "#f7f8fa",
    },
    sidebar: {
      primary: "#FCFCFD",
      textColor: "#525866",
      textColorPrimary: "#1C6DEA",
    },
    typography: {
      fontFamily: "Roboto, sans-serif",
      fontSize: "14px",
      headingFontSize: "24px",
      textColor: "#006DF9",
      linkColor: "#3498db",
      linkHoverColor: "#005ED6",
    },
    buttons: {
      primary: {
        backgroundColor: "#1272f9",
        textColor: "#ffffff",
        hoverBackgroundColor: "#0860dd",
      },
      secondary: {
        backgroundColor: "#f3f3f3",
        textColor: "#626168",
        hoverBackgroundColor: "#fcfcfd",
      },
    },
    borders: {
      defaultRadius: "4px",
      borderColor: "#1272F9",
    },
    spacing: {
      padding: "16px",
      margin: "16px",
    },
  },
  urls: {
    faviconUrl: Some("/HyperswitchFavicon.png"),
    logoUrl: Some(""),
  },
}

let defaultEmailConfig: emailConfig = {
  entity_name: "Hyperswitch",
  entity_logo_url: "https://app.hyperswitch.io/email-assets/HyperswitchLogo.png",
  primary_color: "#006DF9",
  foreground_color: "#111326",
  background_color: "#FFFFFF",
}

let themeContext = {
  globalUIConfig: UIConfig.defaultUIConfig,
  theme: Light,
  themeSetter: defaultSetter,
  configCustomDomainTheme: _ => (),
  getThemesJson: (~themesID, ~domain=None) => {
    switch (themesID, domain) {
    | _ => JSON.Encode.null->Promise.resolve
    }
  },
  logoURL: Some(""),
}

let themeContext = React.createContext(themeContext)

module Parent = {
  let make = React.Context.provider(themeContext)
}
let useTheme = () => {
  let {theme} = React.useContext(themeContext)
  theme
}

@react.component
let make = (~children) => {
  let eventTheme = ThemeUtils.useThemeFromEvent()
  let fetchApi = AuthHooks.useApiFetcher()
  let isCurrentlyDark = MatchMedia.useMatchMedia("(prefers-color-scheme: dark)")
  let (contextLogoUrl, setContextLogoUrl) = React.useState(() => Some(""))

  let initialTheme = Light

  let (themeState, setThemeBase) = React.useState(() => initialTheme)

  let theme = switch eventTheme {
  | Some("Dark") => Dark
  | Some(_val) => Light
  | None =>
    if window !== Window.parent {
      Light
    } else {
      themeState
    }
  }

  let setTheme = React.useCallback(value => {
    setThemeBase(_ => value)
  }, [setThemeBase])

  React.useEffect(() => {
    setTheme(initialTheme)
    None
  }, [isCurrentlyDark])

  let themeClassName = switch theme {
  | Dark => "dark"
  | Light => ""
  }

  let configCustomDomainTheme = React.useCallback((uiConfig: JSON.t) => {
    let value = ThemeUtils.parseThemeJson(~uiConfig, ~fallbackThemeConfig)
    Window.appendStyle(value)
  }, [])

  let configureFavIcon = (faviconUrl: option<string>) => {
    open DOMUtils
    try {
      let existingFavicon =
        Webapi.Dom.document->Webapi.Dom.Document.querySelector("link[rel='shortcut icon']")

      switch existingFavicon {
      | Some(faviconElement) =>
        faviconElement->Webapi.Dom.Element.setAttribute(
          "href",
          faviconUrl->Option.getOr("/HyperswitchFavicon.png"),
        )
      | None =>
        let a = createElement(DOMUtils.document, "link")
        a->setAttribute("href", faviconUrl->Option.getOr("/HyperswitchFavicon.png"))
        a->setAttribute("rel", "shortcut icon")
        a->setAttribute("type", "image/x-icon")
        appendHead(a)
      }
    } catch {
    | _ => Exn.raiseError("Error on configuring favicon")
    }
  }
  let updateThemeURLs = (~themesData, ~themeConfigVersion=None) => {
    open HyperSwitchConfigTypes
    try {
      let urlsDict = themesData->getDictFromJsonObject->getDictfromDict("urls")
      let existingEnv = DOMUtils.window._env_
      let getUrl = (key, defaultVal, existingVal) => {
        let value = urlsDict->getJsonObjectFromDict(key)
        if isNullJson(value) {
          Some(defaultVal)
        } else {
          urlsDict->getString(key, existingVal->Option.getOr(defaultVal))->getNonEmptyString
        }
      }
      let val = {
        faviconUrl: getUrl(
          "faviconUrl",
          "/HyperswitchFavicon.png",
          existingEnv.urlThemeConfig.faviconUrl,
        ),
        logoUrl: getUrl(
          "logoUrl",
          "/assets/Light/juspayHyperswitchLogoIconWithText.svg",
          existingEnv.urlThemeConfig.logoUrl,
        ),
      }

      let logoUrlWithVersion = switch val.logoUrl {
      | Some(url) if url !== "/assets/Light/juspayHyperswitchLogoIconWithText.svg" =>
        Some(ThemeFeatureUtils.appendVersionParam(url, ~version=themeConfigVersion))
      | Some(url) => Some(url)
      | _ => val.logoUrl
      }

      let faviconUrlWithVersion = switch val.faviconUrl {
      | Some(url) if url !== "/HyperswitchFavicon.png" =>
        Some(ThemeFeatureUtils.appendVersionParam(url, ~version=themeConfigVersion))
      | Some(url) => Some(url)
      | _ => val.faviconUrl
      }

      let updatedUrlConfig = {
        ...existingEnv,
        urlThemeConfig: {logoUrl: logoUrlWithVersion, faviconUrl: faviconUrlWithVersion},
      }
      DOMUtils.window._env_ = updatedUrlConfig
      configureFavIcon(faviconUrlWithVersion)
      setContextLogoUrl(_ => logoUrlWithVersion)
    } catch {
    | _ => Exn.raiseError("Error while updating theme URL and favicon")
    }
  }

  let getDefaultStyle = () => {
    let defaultStyle = {
      "settings": fallbackThemeConfig.settings,
      "urls": fallbackThemeConfig.urls,
    }->Identity.genericTypeToJson
    defaultStyle
  }

  let applyThemeConfig = (config: JSON.t) => {
    updateThemeURLs(~themesData=config)
    configCustomDomainTheme(config)
  }

  let getThemeConfigVersion = async (~themeId) => {
    try {
      let url = `${GlobalVars.getHostUrl}/api/user/theme/${themeId}/version`
      let response = await fetchApi(url, ~method_=Get, ~xFeatureRoute=false, ~forceCookies=false)
      await response->(res => res->Fetch.Response.json)
    } catch {
    | _ => JSON.Encode.null
    }
  }

  let getThemesJson = async (~themesID, ~domain=None) => {
    try {
      let themeJson = {
        if themesID->Option.isSome && themesID->Option.getOr("")->isNonEmptyString {
          let id = themesID->Option.getOr("")
          let versionApiResponse = await getThemeConfigVersion(~themeId=id)
          let themeConfigVersion =
            versionApiResponse
            ->getDictFromJsonObject
            ->getString("theme_config_version", "")
          HyperSwitchEntryUtils.setThemeConfigVersiontoStore(themeConfigVersion)
          let url = ThemeFeatureUtils.appendVersionParam(
            `${GlobalVars.getHostUrl}/themes/${id}/theme.json`,
            ~version=Some(themeConfigVersion),
          )

          let themeResponse = await fetchApi(
            url,
            ~method_=Get,
            ~xFeatureRoute=true,
            ~forceCookies=false,
          )
          await themeResponse->(res => res->Fetch.Response.json)
        } // this need to be removed once all the existing user started consuming theme from the cdn
        // else if condition for backward compatibility
        else if domain->Option.isSome && domain->Option.getOr("")->isNonEmptyString {
          let domainValue = domain->Option.getOr("")
          let url = `${GlobalVars.getHostUrl}/themes?domain=${domainValue}`
          let themeResponse = await fetchApi(
            url,
            ~method_=Get,
            ~xFeatureRoute=true,
            ~forceCookies=false,
          )
          await themeResponse->(res => res->Fetch.Response.json)
        } else {
          let url = `${GlobalVars.getHostUrlWithBasePath}/config/theme`
          let themeResponse = await fetchApi(
            url,
            ~method_=Get,
            ~xFeatureRoute=false,
            ~forceCookies=false,
          )
          await themeResponse->(res => res->Fetch.Response.json)
        }
      }
      let themeConfigVersion = HyperSwitchEntryUtils.getThemeConfigVersionfromStore()
      updateThemeURLs(~themesData={themeJson}, ~themeConfigVersion)->ignore
      configCustomDomainTheme(themeJson)->ignore
      themeJson
    } catch {
    | _ => {
        let defaultStyle = getDefaultStyle()
        updateThemeURLs(~themesData=defaultStyle)->ignore
        configCustomDomainTheme(defaultStyle)->ignore
        defaultStyle
      }
    }
  }

  let handleInitConfigMessage = (ev: Dom.event) => {
    open EmbeddableGlobalUtils
    try {
      let objectdata = ev->HandlingEvents.convertToCustomEvent
      let dict = objectdata.data->getDictFromJsonObject
      switch dict->getOptionString("type")->Option.map(messageToTypeConversion) {
      | Some(INIT_CONFIG) => {
          let initConfigJson = dict->getJsonObjectFromDict("init_config")
          let themeValues = isNullJson(initConfigJson) ? getDefaultStyle() : initConfigJson
          applyThemeConfig(themeValues)
        }
      | _ => ()
      }
    } catch {
    | _ => ()
    }
  }

  let value = React.useMemo(() => {
    {
      globalUIConfig: UIConfig.defaultUIConfig,
      theme,
      themeSetter: setTheme,
      configCustomDomainTheme,
      getThemesJson,
      logoURL: contextLogoUrl,
    }
  }, (theme, setTheme, contextLogoUrl))

  React.useEffect(() => {
    Window.addEventListener("message", handleInitConfigMessage)
    Some(() => Window.removeEventListener("message", handleInitConfigMessage))
  }, [])
  React.useEffect(() => {
    if theme === Dark {
      setTheme(Light)
    }
    None
  }, [])

  <Parent value>
    <div className=themeClassName>
      <div
        className={`${value.globalUIConfig.backgroundColor} text-gray-700 dark:text-gray-200 red:bg-red`}>
        children
      </div>
    </div>
  </Parent>
}
