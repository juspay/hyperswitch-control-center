type theme = Light | Dark

let defaultSetter = (_: theme) => ()

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
}

let defaultGlobalConfig: customStyle = {
  primaryColor: "#006DF9",
  primaryHover: "#005ED6",
  sidebar: "#242F48",
}

let themeContext = {
  globalUIConfig: UIConfig.defaultUIConfig,
  theme: Light,
  themeSetter: defaultSetter,
  configCustomDomainTheme: (_: JSON.t) => (),
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

  let setTheme = React.useCallback1(value => {
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
  let configCustomDomainTheme = React.useCallback0((uiConfg: JSON.t) => {
    open LogicUtils
    let dict = uiConfg->getDictFromJsonObject->getDictfromDict("theme")
    let {primaryColor, primaryHover, sidebar} = defaultGlobalConfig
    let value: HyperSwitchConfigTypes.customStyle = {
      primaryColor: dict->getString("primary_color", primaryColor),
      primaryHover: dict->getString("primary_hover_color", primaryHover),
      sidebar: dict->getString("sidebar_color", sidebar),
    }
    Window.appendStyle(value)
  })

  let value = React.useMemo2(() => {
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
