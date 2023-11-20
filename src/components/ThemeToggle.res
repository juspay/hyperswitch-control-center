@react.component
let make = (~setIsAppearancePopupOpen, ~setisBrowserTheme) => {
  let (theme, setTheme) = React.useContext(ThemeProvider.themeContext)
  let toggleSetTheme = isDark => {
    setisBrowserTheme(_ => false)
    switch isDark {
    | false => setTheme(Dark)
    | true => setTheme(Light)
    }
  }

  React.useEffect1(() => {
    let selectedTheme = "LightTheme"

    LocalStorage.setItem("theme", selectedTheme)
    None
  }, [theme])

  <div className="flex pr-4">
    <div
      className="w-full py-3 pl-4 flex text-sm text-gray-700 dark:text-gray-400 cursor-pointer bg-white dark:bg-jp-gray-950 hover:bg-jp-gray-100 dark:hover:bg-jp-gray-900 justify-between"
      onClick={_ => toggleSetTheme(theme === Dark)}>
      {React.string("Dark Mode")}
      <BoolInput.BaseComponent isSelected={theme === Dark} setIsSelected={a => toggleSetTheme(a)} />
    </div>
    <div className="pl-2 cursor-pointer justify-center flex">
      <ToolTip
        tooltipWidthClass="w:24"
        description="Appearance Advance settings"
        toolTipFor={<Icon
          name="settings"
          size=15
          onClick={_ => setIsAppearancePopupOpen(_ => true)}
          className="text-jp-gray-700 dark:hover:text-white hover:text-jp-gray-900 "
        />}
        toolTipPosition=Left
        tooltipPositioning=#absolute
      />
    </div>
  </div>
}
