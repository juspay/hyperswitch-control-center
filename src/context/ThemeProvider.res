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
  updateThemeURLs: JSON.t => option<string>,
}

let newDefaultConfig: HyperSwitchConfigTypes.customStylesTheme = {
  settings: {
    colors: {
      primary: "#006DF9",
      secondary: "#F7F7F7",
      sidebar: "#242F48",
      background: "#F7F8FB",
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
        backgroundColor: "#006DF9",
        textColor: "#006df9",
        hoverBackgroundColor: "#005ED6",
      },
      secondary: {
        backgroundColor: "#F7F7F7",
        textColor: "#202124",
        hoverBackgroundColor: "#EEEEEE",
      },
    },
    borders: {
      defaultRadius: "4px",
      borderColor: "#006DF9",
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
  updateThemeURLs: _ => Some(""),
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
          sidebar: colorsConfig->getString("sidebar", defaultSettings.colors.sidebar),
          background: colorsConfig->getString("background", defaultSettings.colors.background),
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

  let getThemesJson = async (themesID, configRes, devThemeFeature) => {
    open LogicUtils
    //will remove configRes once feature flag is removed.
    try {
      let themeJson = if !devThemeFeature {
        let dict = configRes->getDictFromJsonObject->getDictfromDict("theme")
        let {settings: defaultSettings, _} = newDefaultConfig
        let defaultStyle = {
          "settings": {
            "colors": {
              "primary": dict->getString("primary_color", defaultSettings.colors.primary),
              "sidebar": dict->getString("sidebar_color", defaultSettings.colors.sidebar),
            },
            "buttons": {
              "primary": {
                "backgroundColor": dict->getString(
                  "primary_color",
                  defaultSettings.buttons.primary.backgroundColor,
                ),
                "textColor": dict->getString(
                  "primary_color",
                  defaultSettings.buttons.primary.textColor,
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
        //for testing
        // let url = `http://localhost:9000/theme.json`
        let url = `${GlobalVars.getHostUrl}/themes/${themesID}/theme.json`
        let themeResponse = await fetchApi(`${url}`, ~method_=Get, ~xFeatureRoute=true)
        let themesData = await themeResponse->(res => res->Fetch.Response.json)
        themesData
      }
      themeJson
    } catch {
    | _ => JSON.Encode.null
    }
  }

  let configureFavIcon = (faviconUrl: option<string>) => {
    try {
      open DOMUtils
      let a = createElement(DOMUtils.document, "link")
      let _ = setAttribute(a, "href", `${faviconUrl->Option.getOr("/HyperswitchFavicon.png")}`)
      let _ = setAttribute(a, "rel", "shortcut icon")
      let _ = setAttribute(a, "type", "image/x-icon")
      let _ = appendHead(a)
      Js.log(a)
    } catch {
    | _ => Exn.raiseError("Error on configuring favicon")
    }
  }

  let updateThemeURLs = themesData => {
    open LogicUtils
    open HyperSwitchConfigTypes
    try {
      let urlsDict = themesData->getDictFromJsonObject->getDictfromDict("urls")
      let val = {
        faviconUrl: urlsDict->getString("faviconUrl", "")->getNonEmptyString,
        logoUrl: urlsDict->getString("logoUrl", "")->getNonEmptyString,
      }
      Js.log2("val", val)
      let existingEnv = DOMUtils.window._env_

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

  let value = React.useMemo(() => {
    {
      globalUIConfig: UIConfig.defaultUIConfig,
      theme,
      themeSetter: setTheme,
      configCustomDomainTheme,
      getThemesJson,
      updateThemeURLs,
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
