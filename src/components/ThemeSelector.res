type theme = Light | Dark

type record = {
  key: string,
  title: string,
  value: bool,
}

module MenuOption = {
  @react.component
  let make = (~text, ~onClick=?, ~isSelected=false) => {
    let bgClass = "bg-white dark:bg-jp-gray-950 hover:bg-jp-gray-100 dark:hover:bg-jp-gray-900"

    <button
      className={`px-4 py-3 flex text-sm text-gray-700 dark:text-gray-400 justify-between cursor-pointer ${bgClass}`}
      ?onClick>
      {React.string(text)}
      <div className="mt-1">
        <Tick isSelected />
      </div>
    </button>
  }
}

@react.component
let make = (~setIsAppearancePopupOpen, ~setisBrowserTheme=?) => {
  let (theme, setTheme) = React.useContext(ThemeProvider.themeContext)
  let (selectedTheme, setSelectedTheme) = React.useState(_ => {
    switch LocalStorage.getItem("theme")->Js.Nullable.toOption {
    | Some(str) => str
    | None => "LightTheme"
    }
  })

  let setIsSelected = React.useCallback2(newBoolValue => {
    setTheme(
      if newBoolValue {
        Dark
      } else {
        Light
      },
    )
  }, (theme, setTheme))

  let isCurrentlyDark = MatchMedia.useMatchMedia("(prefers-color-scheme: dark)")

  let themeList = [
    {key: "BrowserTheme", title: "Use Device Theme", value: isCurrentlyDark},
    {key: "DarkTheme", title: "Dark Theme", value: true},
    {key: "LightTheme", title: "Light Theme", value: false},
  ]

  <>
    <div className="flex mx-3 mb-3">
      <div className="cursor-pointer" onClick={_ => setIsAppearancePopupOpen(_ => false)}>
        <Icon className="mr-3 mt-1" size=12 name="chevron-left" />
      </div>
      <div className="text-black dark:text-white"> {React.string("Appearance")} </div>
    </div>
    <div className="m-3 text-sm text-gray-500 dark:text-gray-400">
      {React.string("Settings applies to this browser only")}
    </div>
    {themeList
    ->Js.Array2.mapi((obj, index) => {
      <MenuOption
        key={index->string_of_int}
        onClick={_ => {
          setIsSelected(obj.value)
          setSelectedTheme(_ => obj.key)
          switch setisBrowserTheme {
          | Some(setisBrowserTheme) => setisBrowserTheme(_ => obj.key === "BrowserTheme")
          | _ => ()
          }
          LocalStorage.setItem("theme", obj.key)
        }}
        text=obj.title
        isSelected={selectedTheme === obj.key}
      />
    })
    ->React.array}
  </>
}
