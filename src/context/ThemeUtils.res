let useThemeFromEvent = () => {
  let (eventTheme, setEventTheme) = React.useState(_ => None)

  React.useEffect0(() => {
    let setEventThemeVal = (eventName, dict) => {
      if eventName === "AuthenticationDetails" {
        let payloadDict = dict->Dict.get("payload")->Belt.Option.flatMap(Js.Json.decodeObject)
        let theme =
          payloadDict->Belt.Option.mapWithDefault("", finalDict =>
            LogicUtils.getString(finalDict, "theme", "")
          )
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
            dict->Dict.get("eventType")->Belt.Option.flatMap(Js.Json.decodeString)
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
  })

  eventTheme
}
