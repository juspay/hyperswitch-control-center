type theme = Light | Dark

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
      background: "#006df9",
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

  let configCustomDomainTheme = React.useCallback((uiConfg: JSON.t) => {
    open LogicUtils
    let dict = uiConfg->getDictFromJsonObject
    let settings = dict->getDictfromDict("settings")
    let url = dict->getDictfromDict("urls")
    let colorsConfig = settings->getDictfromDict("colors")
    let sidebarConfig = settings->getDictfromDict("sidebar")
    let typography = settings->getDictfromDict("typography")
    let borders = settings->getDictfromDict("borders")
    let spacing = settings->getDictfromDict("spacing")
    let colorsBtnPrimary = settings->getDictfromDict("buttons")->getDictfromDict("primary")
    let colorsBtnSecondary = settings->getDictfromDict("buttons")->getDictfromDict("secondary")
    let {settings: defaultSettings, _} = fallbackThemeConfig
    let value: HyperSwitchConfigTypes.customStylesTheme = {
      settings: {
        colors: {
          primary: colorsConfig->getString("primary", defaultSettings.colors.primary),
          secondary: colorsConfig->getString("secondary", defaultSettings.colors.secondary),
          background: colorsConfig->getString("background", defaultSettings.colors.background),
        },
        sidebar: {
          primary: sidebarConfig->getString("primary", defaultSettings.sidebar.primary),
          textColor: sidebarConfig->getString("textColor", defaultSettings.sidebar.textColor),
          textColorPrimary: sidebarConfig->getString(
            "textColorPrimary",
            defaultSettings.sidebar.textColorPrimary,
          ),
        },
        typography: {
          fontFamily: typography->getString("fontFamily", defaultSettings.typography.fontFamily),
          fontSize: typography->getString("fontSize", defaultSettings.typography.fontSize),
          headingFontSize: typography->getString(
            "headingFontSize",
            defaultSettings.typography.headingFontSize,
          ),
          textColor: typography->getString("textColor", defaultSettings.typography.textColor),
          linkColor: typography->getString("linkColor", defaultSettings.typography.linkColor),
          linkHoverColor: typography->getString(
            "linkHoverColor",
            defaultSettings.typography.linkHoverColor,
          ),
        },
        buttons: {
          primary: {
            backgroundColor: colorsBtnPrimary->getString(
              "backgroundColor",
              defaultSettings.buttons.primary.backgroundColor,
            ),
            textColor: colorsBtnPrimary->getString(
              "textColor",
              defaultSettings.buttons.primary.textColor,
            ),
            hoverBackgroundColor: colorsBtnPrimary->getString(
              "hoverBackgroundColor",
              defaultSettings.buttons.primary.hoverBackgroundColor,
            ),
          },
          secondary: {
            backgroundColor: colorsBtnSecondary->getString(
              "backgroundColor",
              defaultSettings.buttons.secondary.backgroundColor,
            ),
            textColor: colorsBtnSecondary->getString(
              "textColor",
              defaultSettings.buttons.secondary.textColor,
            ),
            hoverBackgroundColor: colorsBtnSecondary->getString(
              "hoverBackgroundColor",
              defaultSettings.buttons.secondary.hoverBackgroundColor,
            ),
          },
        },
        borders: {
          defaultRadius: borders->getString("defaultRadius", defaultSettings.borders.defaultRadius),
          borderColor: borders->getString("borderColor", defaultSettings.borders.borderColor),
        },
        spacing: {
          padding: spacing->getString("padding", defaultSettings.spacing.padding),
          margin: spacing->getString("margin", defaultSettings.spacing.margin),
        },
      },
      urls: {
        faviconUrl: url->getOptionString("faviconUrl"),
        logoUrl: url->getOptionString("logoUrl"),
      },
    }
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
  let updateThemeURLs = themesData => {
    open LogicUtils
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
          "/assets/Dark/hyperswitchLogoIconWithText.svg",
          existingEnv.urlThemeConfig.logoUrl,
        ),
      }
      let updatedUrlConfig = {...existingEnv, urlThemeConfig: val}
      DOMUtils.window._env_ = updatedUrlConfig
      configureFavIcon(val.faviconUrl)->ignore
      setContextLogoUrl(_ => val.logoUrl)
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

  let getThemesJson = async (~themesID, ~domain=None) => {
    try {
      let themeJson = {
        if themesID->Option.isSome && themesID->Option.getOr("")->LogicUtils.isNonEmptyString {
          let id = themesID->Option.getOr("")
          let url = `${GlobalVars.getHostUrl}/themes/${id}/theme.json`
          let themeResponse = await fetchApi(
            url,
            ~method_=Get,
            ~xFeatureRoute=true,
            ~forceCookies=false,
          )
          await themeResponse->(res => res->Fetch.Response.json)
        } // this need to be removed once all the exisitng user started consuming theme from the cdn
        // else if condition for backward compatibility
        else if domain->Option.isSome && domain->Option.getOr("")->LogicUtils.isNonEmptyString {
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
      updateThemeURLs(themeJson)->ignore
      configCustomDomainTheme(themeJson)->ignore
      themeJson
    } catch {
    | _ => {
        let defaultStyle = getDefaultStyle()
        updateThemeURLs(defaultStyle)->ignore
        configCustomDomainTheme(defaultStyle)->ignore
        defaultStyle
      }
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
    if theme === Dark {
      setTheme(Light)
    }
    None
  }, [])

  <Parent value>
    <div className=themeClassName>
      <div
        className="bg-jp-gray-100 dark:bg-jp-gray-darkgray_background text-gray-700 dark:text-gray-200 red:bg-red">
        children
      </div>
    </div>
  </Parent>
}
