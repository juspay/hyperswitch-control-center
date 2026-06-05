@react.component
let make = (
  ~logoClass="",
  ~handleClick=?,
  ~logoVariant=CommonAuthTypes.IconWithText,
  ~logoHeight="h-6",
  ~iconUrl=None,
) => {
  let {theme} = React.useContext(ThemeProvider.themeContext)
  let iconFolder = switch theme {
  | Dark => "Dark"
  | Light => "Light"
  }

  let handleClickEvent = ev => {
    switch handleClick {
    | Some(fn) => fn(ev)
    | None => ()
    }
  }

  let iconImagePath = switch logoVariant {
  | Icon => `/assets/${iconFolder}/hyperswitchLogoIcon.svg`
  | Text => `/assets/${iconFolder}/hyperswitchLogoText.svg`
  | IconWithText => `/assets/${iconFolder}/juspayHyperswitchLogoIconWithText.svg`
  | IconWithURL => `${iconUrl->Option.getOr("")}`
  }

  <div className={`${logoClass}`} onClick={handleClickEvent}>
    <img alt="image" src=iconImagePath className=logoHeight />
  </div>
}
