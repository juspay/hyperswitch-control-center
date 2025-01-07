type theme = Light | Dark

let defaultSetter = _ => ()

type themeType = LightTheme

type x = {theme: string}

type customUIConfig = {
  globalUIConfig: UIConfig.t,
  theme: theme,
  themeSetter: theme => unit,
  configCustomDomainTheme: JSON.t => unit,
}

let newDefaultConfig: HyperSwitchConfigTypes.customStylesTheme = {
  settings: {
    colors: {
      primary: "#006DF9",
      secondary: "#303E5F",
      sidebar: "#242F48",
      background: "#006df9",
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
        textColor: "#ffffff",
        hoverBackgroundColor: "#005ED6",
      },
      secondary: {
        backgroundColor: "#F7F7F7",
        textColor: "#333333",
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

  let value = React.useMemo(() => {
    {
      globalUIConfig: UIConfig.defaultUIConfig,
      theme,
      themeSetter: setTheme,
      configCustomDomainTheme,
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
