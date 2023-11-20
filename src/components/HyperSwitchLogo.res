type logoVariant = Icon | Text | IconWithText
type theme = Light | Dark

@react.component
let make = (
  ~logoClass="",
  ~handleClick=?,
  ~logoVariant=IconWithText,
  ~logoHeight="h-6",
  ~theme=Dark,
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
  | Icon => `assets/${iconFolder}/hyperswitchLogoIcon.svg`
  | Text => `assets/${iconFolder}/hyperswitchLogoText.svg`
  | IconWithText => `assets/${iconFolder}/hyperswitchLogoIconWithText.svg`
  }

  <div className={`${logoClass}`} onClick={handleClickEvent}>
    <img src=iconImagePath className=logoHeight />
  </div>
}
