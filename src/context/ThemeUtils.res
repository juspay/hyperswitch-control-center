let useThemeFromEvent = () => {
  let (eventTheme, setEventTheme) = React.useState(_ => None)

  React.useEffect(() => {
    let setEventThemeVal = (eventName, dict) => {
      if eventName === "AuthenticationDetails" {
        let payloadDict = dict->Dict.get("payload")->Option.flatMap(obj => obj->JSON.Decode.object)
        let theme =
          payloadDict->Option.mapOr("", finalDict => LogicUtils.getString(finalDict, "theme", ""))
        setEventTheme(_ => Some(theme))
      } else if eventName == "themeToggle" {
        let theme = LogicUtils.getString(dict, "payload", "")
        setEventTheme(_ => Some(theme))
      } else {
        Js.log2(`Event name is ${eventName}`, dict)
      }
    }

    let handleEventMessage = (ev: Dom.event) => {
      let optionalDict = HandlingEvents.getEventDict(ev)
      switch optionalDict {
      | Some(dict) => {
          let optionalEventName =
            dict->Dict.get("eventType")->Option.flatMap(obj => obj->JSON.Decode.string)
          switch optionalEventName {
          | Some(eventName) => setEventThemeVal(eventName, dict)
          | None => Js.log2("Event Data is not found", dict)
          }
        }

      | None => ()
      }
    }

    Window.addEventListener("message", handleEventMessage)
    Some(() => Window.removeEventListener("message", handleEventMessage))
  }, [])

  eventTheme
}
open LogicUtils
let parseThemeJson = (
  ~uiConfig: JSON.t,
  ~fallbackThemeConfig: HyperSwitchConfigTypes.customStylesTheme,
): HyperSwitchConfigTypes.customStylesTheme => {
  let dict = uiConfig->getDictFromJsonObject
  let settings = dict->getDictfromDict("settings")
  let url = dict->getDictfromDict("urls")
  let colorsConfig = settings->getDictfromDict("colors")
  let sidebarConfig = settings->getDictfromDict("sidebar")
  let typography = settings->getDictfromDict("typography")
  let borders = settings->getDictfromDict("borders")
  let spacing = settings->getDictfromDict("spacing")
  let colorsBtnPrimary = settings->getDictfromDict("buttons")->getDictfromDict("primary")
  let colorsBtnSecondary = settings->getDictfromDict("buttons")->getDictfromDict("secondary")
  let {settings: defaultSettings, _} = fallbackThemeConfig
  {
    settings: {
      colors: {
        primary: colorsConfig->getString("primary", defaultSettings.colors.primary),
        secondary: colorsConfig->getString("secondary", defaultSettings.colors.secondary),
        background: colorsConfig->getString("background", defaultSettings.colors.background),
      },
      sidebar: {
        primary: sidebarConfig->getString("primary", defaultSettings.sidebar.primary),
        textColor: sidebarConfig->getString("textColor", defaultSettings.sidebar.textColor),
        textColorPrimary: sidebarConfig->getString(
          "textColorPrimary",
          defaultSettings.sidebar.textColorPrimary,
        ),
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
}
