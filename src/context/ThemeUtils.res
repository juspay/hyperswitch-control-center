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
let newDefaultConfig: HyperSwitchConfigTypes.customStylesTheme = {
  settings: {
    colors: {
      primary: "#006DF9",
      secondary: "#303E5F",
      background: "#006df9",
    },
    sidebar: {
      primary: "#FCFCFD",
      textColor: "#525866",
      textColorPrimary: "#050506",
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
        backgroundColor: "#1272f9",
        textColor: "#ffffff",
        hoverBackgroundColor: "#0860dd",
      },
      secondary: {
        backgroundColor: "#f3f3f3",
        textColor: "#626168",
        hoverBackgroundColor: "#fcfcfd",
      },
    },
    borders: {
      defaultRadius: "4px",
      borderColor: "#1272F9",
    },
    spacing: {
      padding: "16px",
      margin: "16px",
    },
  },
  urls: {
    faviconUrl: Some("/HyperswitchFavicon.png"),
    logoUrl: Some(""),
  },
}
