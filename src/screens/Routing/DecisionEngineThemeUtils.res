open DecisionEngineTypes
open DOMUtils
open LogicUtils

let themeTokens = (config: HyperSwitchConfigTypes.customStylesTheme): themeTokens => {
  let {colors, typography, buttons, borders} = config.settings
  {
    primary: colors.primary,
    background: colors.background,
    surface: "#ffffff",
    link: typography.linkColor,
    linkHover: typography.linkHoverColor,
    primaryButtonBackground: buttons.primary.backgroundColor,
    primaryButtonText: buttons.primary.textColor,
    primaryButtonHover: buttons.primary.hoverBackgroundColor,
    secondaryButtonBackground: buttons.secondary.backgroundColor,
    secondaryButtonText: buttons.secondary.textColor,
    secondaryButtonHover: buttons.secondary.hoverBackgroundColor,
    fontFamily: typography.fontFamily,
    fontSize: typography.fontSize,
    headingFontSize: typography.headingFontSize,
    radius: borders.defaultRadius,
  }
}

let isFrameMessage = (~iframeRef: React.ref<Nullable.t<Dom.element>>, event: messageEventData) =>
  event.origin === Window.Location.origin &&
    switch iframeRef.current->Nullable.toOption {
    | Some(frame) =>
      let source = frame->frameWindow
      source->Nullable.toOption->Option.isSome && event.source === source
    | None => false
    }

let postToFrame = (~iframeRef: React.ref<Nullable.t<Dom.element>>, message) =>
  iframeRef.current
  ->Nullable.toOption
  ->Option.flatMap(frame => frame->frameWindow->Nullable.toOption)
  ->Option.forEach(target => target->postMessage(message, Window.Location.origin))

let requestTheme = (~iframeRef) =>
  postToFrame(~iframeRef, {"type": "de:theme-request", "version": 1}->Identity.genericTypeToJson)

let getReadyFrame = (event: messageEventData) => {
  let dict = event.data->getDictFromJsonObject
  let id = dict->getString("frameId", "")
  let supportedVersion = switch dict->getJsonObjectFromDict("version")->JSON.Classify.classify {
  | Number(version) => version === 1.
  | _ => false
  }
  if (
    dict->getString("type", "") === "de:theme-ready" &&
    supportedVersion &&
    id->isNonEmptyString &&
    id->String.length <= 64
  ) {
    Some(id)
  } else {
    None
  }
}

let sendTheme = (~iframeRef, ~frameId, snapshot: HyperSwitchConfigTypes.resolvedTheme) =>
  postToFrame(
    ~iframeRef,
    {
      "type": "de:theme-update",
      "version": 1,
      "frameId": frameId,
      "revision": snapshot.revision,
      "tokens": themeTokens(snapshot.config),
    }->Identity.genericTypeToJson,
  )
