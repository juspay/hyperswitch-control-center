type theme = Light | Dark

let defaultSetter = _ => ()

type themeType = LightTheme

type x = {theme: string}

type customUIConfig = {
  globalUIConfig: UIConfig.t,
  theme: theme,
  themeSetter: theme => unit,
  configCustomDomainTheme: JSON.t => unit,
  getThemesJson: (string, JSON.t, bool) => promise<JSON.t>,
}

let newDefaultConfig: HyperSwitchConfigTypes.customStylesTheme = {
  settings: {
    colors: {
      primary: "#006DF9",
      secondary: "#303E5F",
      background: "#006df9",
    },
    sidebar: {
      primary: "#FCFCFD",
      secondary: "#FFFFFF",
      hoverColor: "#D9DDE5",
      primaryTextColor: "#1C6DEA",
      secondaryTextColor: "#525866",
      borderColor: "#ECEFF3",
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
    faviconUrl: None,
    logoUrl: None,
  },
}

let themeContext = {
  globalUIConfig: UIConfig.defaultUIConfig,
  theme: Light,
  themeSetter: defaultSetter,
  configCustomDomainTheme: _ => (),
  getThemesJson: (_, _, _) => JSON.Encode.null->Promise.resolve,
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
    let {settings: defaultSettings, _} = newDefaultConfig
    let value: HyperSwitchConfigTypes.customStylesTheme = {
      settings: {
        colors: {
          primary: colorsConfig->getString("primary", defaultSettings.colors.primary),
          secondary: colorsConfig->getString("secondary", defaultSettings.colors.secondary),
          background: colorsConfig->getString("background", defaultSettings.colors.background),
        },
        sidebar: {
          // This 'colorsConfig' will be replaced with 'sidebarConfig', and the 'sidebar' key will be changed to 'primary' after API Changes.
          primary: colorsConfig->getString("sidebar", defaultSettings.sidebar.primary),
          // This 'colorsConfig' will be replaced with 'sidebarConfig' once the API changes are done.
          secondary: sidebarConfig->getString("secondary", defaultSettings.sidebar.secondary),
          hoverColor: sidebarConfig->getString("hoverColor", defaultSettings.sidebar.hoverColor),
          // This property is currently required to support current sidebar changes. It will be removed in a future update.
          primaryTextColor: sidebarConfig->getString(
            "primaryTextColor",
            defaultSettings.sidebar.primaryTextColor,
          ),
          secondaryTextColor: sidebarConfig->getString(
            "secondaryTextColor",
            defaultSettings.sidebar.secondaryTextColor,
          ),
          borderColor: sidebarConfig->getString("borderColor", defaultSettings.sidebar.borderColor),
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
    try {
      open DOMUtils
      let a = createElement(DOMUtils.document, "link")
      let _ = setAttribute(a, "href", `${faviconUrl->Option.getOr("/HyperswitchFavicon.png")}`)
      let _ = setAttribute(a, "rel", "shortcut icon")
      let _ = setAttribute(a, "type", "image/x-icon")
      let _ = appendHead(a)
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
      let val = {
        faviconUrl: urlsDict
        ->getString("faviconUrl", existingEnv.urlThemeConfig.faviconUrl->Option.getOr(""))
        ->getNonEmptyString,
        logoUrl: urlsDict
        ->getString("logoUrl", existingEnv.urlThemeConfig.logoUrl->Option.getOr(""))
        ->getNonEmptyString,
      }

      let updatedUrlConfig = {
        ...existingEnv,
        urlThemeConfig: val,
      }
      DOMUtils.window._env_ = updatedUrlConfig
      configureFavIcon(updatedUrlConfig.urlThemeConfig.faviconUrl)->ignore
      updatedUrlConfig.urlThemeConfig.faviconUrl
    } catch {
    | _ => Exn.raiseError("Error while updating theme URL and favicon")
    }
  }

  let getThemesJson = async (themesID, configRes, devThemeFeature) => {
    open LogicUtils
    //will remove configRes once feature flag is removed.
    try {
      let themeJson = if !devThemeFeature || themesID->isEmptyString {
        let dict = configRes->getDictFromJsonObject->getDictfromDict("theme")
        let {settings: defaultSettings, _} = newDefaultConfig
        let defaultStyle = {
          "settings": {
            "colors": {
              "primary": dict->getString("primary_color", defaultSettings.colors.primary),
              "sidebar": dict->getString("sidebar_primary", defaultSettings.sidebar.primary),
            },
            "sidebar": {
              "secondary": dict->getString("sidebar_secondary", defaultSettings.sidebar.secondary),
              "hoverColor": dict->getString(
                "sidebar_hover_color",
                defaultSettings.sidebar.hoverColor,
              ),
              "primaryTextColor": dict->getString(
                "sidebar_primary_text_color",
                defaultSettings.sidebar.primaryTextColor,
              ),
              "secondaryTextColor": dict->getString(
                "sidebar_secondary_text_color",
                defaultSettings.sidebar.secondaryTextColor,
              ),
              "borderColor": dict->getString(
                "sidebar_border_color",
                defaultSettings.sidebar.borderColor,
              ),
            },
            "buttons": {
              "primary": {
                "backgroundColor": dict->getString(
                  "primary_color",
                  defaultSettings.buttons.primary.backgroundColor,
                ),
                "hoverBackgroundColor": dict->getString(
                  "primary_hover_color",
                  defaultSettings.buttons.primary.hoverBackgroundColor,
                ),
              },
            },
          },
        }
        defaultStyle->Identity.genericTypeToJson
      } else {
        let url = `${GlobalVars.getHostUrl}/themes/${themesID}/theme.json`
        let themeResponse = await fetchApi(
          `${url}`,
          ~method_=Get,
          ~xFeatureRoute=true,
          ~forceCookies=false,
        )
        let themesData = await themeResponse->(res => res->Fetch.Response.json)
        themesData
      }
      updateThemeURLs(themeJson)->ignore
      configCustomDomainTheme(themeJson)->ignore
      themeJson
    } catch {
    | _ => {
        let defaultStyle = {"settings": newDefaultConfig.settings}->Identity.genericTypeToJson
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
    }
  }, (theme, setTheme))
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
