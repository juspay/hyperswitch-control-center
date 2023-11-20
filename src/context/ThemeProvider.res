type theme = Light | Dark

let defaultSetter = (_: theme) => ()

let themeContext = React.createContext((Light, defaultSetter))

type themeType = LightTheme

type x = {theme: string}

module Parent = {
  let make = React.Context.provider(themeContext)
}

let useTheme = () => {
  let (theme, _) = React.useContext(themeContext)
  theme
}

@val external window: Js.Nullable.t<'a> = "window"
@val @scope("window") external parent: 't = "parent"

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
    if window !== parent {
      Light
    } else {
      themeState
    }
  }

  let setTheme = React.useCallback1(value => {
    setThemeBase(_ => value)
  }, [setThemeBase])

  React.useEffect1(() => {
    setTheme(initialTheme)
    None
  }, [isCurrentlyDark])

  let themeClassName = switch theme {
  | Dark => "dark"
  | Light => ""
  }

  let value = React.useMemo2(() => {
    (theme, setTheme)
  }, (theme, setTheme))

  React.useEffect1(() => {
    if theme === Dark {
      setTheme(Light)
    }
    None
  }, [])

  <Parent value>
    <div className=themeClassName>
      <div
        className="bg-jp-gray-100 dark:bg-jp-gray-darkgray_background text-gray-700 dark:text-gray-200">
        children
      </div>
    </div>
  </Parent>
}
