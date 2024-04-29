type theme = Light | Dark

@react.component
let make = (
  ~logoClass="",
  ~handleClick=?,
  ~logoVariant=HyperSwitchAuthTypes.IconWithText,
  ~logoHeight="h-6",
  ~theme=Dark,
  ~iconUrl=None,
) => {
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
  | IconWithText => `/assets/${iconFolder}/hyperswitchLogoIconWithText.svg`
  | IconWithURL => `${iconUrl->Option.getOr("")}`
  }

  <div className={`${logoClass}`} onClick={handleClickEvent}>
    <img src=iconImagePath className=logoHeight />
  </div>
}
