type theme = Light | Dark

let defaultSetter = _ => ()

type themeType = LightTheme

type x = {theme: string}

type customStyle = {
  primaryColor: string,
  primaryHover: string,
  sidebar: string,
}

type customUIConfig = {
  globalUIConfig: UIConfig.t,
  theme: theme,
  themeSetter: theme => unit,
  configCustomDomainTheme: JSON.t => unit,
  configCustomThemeDynamic: JSON.t => unit,
}

let defaultGlobalConfig: customStyle = {
  primaryColor: "#006DF9",
  primaryHover: "#005ED6",
  sidebar: "#242F48",
}

let newDefaultConfig: HyperSwitchConfigTypes.customStylesTheme = {
  settings: {
    colors: {
      primary: "#006DF9",
      secondary: "#FFC0CB",
      sidebar: "#242F48",
      background: "#F7F8FB",
    },
    typography: {
      fontFamily: "Roboto, sans-serif",
      fontSize: "14px",
      headingFontSize: "24px",
      textColor: "#2c3e50",
      linkColor: "#3498db",
      linkHoverColor: "#005ED6",
    },
    buttons: {
      primary: {
        backgroundColor: "#3498db",
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
      borderColor: "#dcdde1",
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
  configCustomThemeDynamic: _ => (),
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
    let dict = uiConfg->getDictFromJsonObject->getDictfromDict("theme")
    let {primaryColor, primaryHover, sidebar} = defaultGlobalConfig
    let value: HyperSwitchConfigTypes.customStyle = {
      primaryColor: dict->getString("primary_color", primaryColor),
      primaryHover: dict->getString("primary_hover_color", primaryHover),
      sidebar: dict->getString("sidebar_color", sidebar),
    }
    Window.appendStyle(value)
  }, [])

  let configCustomThemeDynamic = React.useCallback((uiConfg: JSON.t) => {
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
    let {settings, _} = newDefaultConfig
    let value: HyperSwitchConfigTypes.customStylesTheme = {
      settings: {
        colors: {
          primary: colorsConfig->getString("primary", settings.colors.primary),
          secondary: colorsConfig->getString("secondary", settings.colors.secondary),
          sidebar: colorsConfig->getString("sidebar", settings.colors.sidebar),
          background: colorsConfig->getString("background", settings.colors.background),
        },
        typography: {
          fontFamily: typography->getString("fontFamily", settings.typography.fontFamily),
          fontSize: typography->getString("fontSize", settings.typography.fontSize),
          headingFontSize: typography->getString(
            "headingFontSize",
            settings.typography.headingFontSize,
          ),
          textColor: typography->getString("textColor", settings.typography.textColor),
          linkColor: typography->getString("linkColor", settings.typography.linkColor),
          linkHoverColor: typography->getString(
            "linkHoverColor",
            settings.typography.linkHoverColor,
          ),
        },
        buttons: {
          primary: {
            backgroundColor: colorsBtnPrimary->getString(
              "backgroundColor",
              settings.buttons.primary.backgroundColor,
            ),
            textColor: colorsBtnPrimary->getString("textColor", settings.buttons.primary.textColor),
            hoverBackgroundColor: colorsBtnPrimary->getString(
              "hoverBackgroundColor",
              settings.buttons.primary.hoverBackgroundColor,
            ),
          },
          secondary: {
            backgroundColor: colorsBtnSecondary->getString(
              "backgroundColor",
              settings.buttons.primary.backgroundColor,
            ),
            textColor: colorsBtnSecondary->getString(
              "textColor",
              settings.buttons.primary.textColor,
            ),
            hoverBackgroundColor: colorsBtnSecondary->getString(
              "hoverBackgroundColor",
              settings.buttons.primary.hoverBackgroundColor,
            ),
          },
        },
        borders: {
          defaultRadius: borders->getString("defaultRadius", settings.borders.defaultRadius),
          borderColor: borders->getString("borderColor", settings.borders.borderColor),
        },
        spacing: {
          padding: spacing->getString("padding", settings.spacing.padding),
          margin: spacing->getString("margin", settings.spacing.margin),
        },
      },
      urls: {
        faviconUrl: url->getOptionString("faviconUrl"),
        logoUrl: url->getOptionString("logoUrl"),
      },
    }
    Window.appendThemesStyle(value)
  }, [])

  let value = React.useMemo(() => {
    {
      globalUIConfig: UIConfig.defaultUIConfig,
      theme,
      themeSetter: setTheme,
      configCustomDomainTheme,
      configCustomThemeDynamic,
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
