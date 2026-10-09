@get external getEventSource: Dom.event => IframeUtils.parent = "source"
@get external getEventOrigin: Dom.event => string = "origin"

let parentOrigin = ref(None)

let isTrustedParentMessage = (ev: Dom.event) => {
  ev->getEventSource === IframeUtils.iframeParent &&
    parentOrigin.contents->Option.mapOr(true, origin => origin === ev->getEventOrigin)
}

let pinParentOrigin = (ev: Dom.event) => {
  let origin = ev->getEventOrigin
  if (
    parentOrigin.contents->Option.isNone && origin->LogicUtils.isNonEmptyString && origin !== "null"
  ) {
    parentOrigin := Some(origin)
  }
}

let decodeMessageFromParent = (ev: Dom.event): EmbeddedTypes.messageFromParent => {
  open LogicUtils
  let message =
    ev->isTrustedParentMessage
      ? (ev->HandlingEvents.convertToCustomEvent).data->JSON.Decode.object
      : None
  switch message {
  | Some(dict) =>
    switch dict->getString("type", "")->String.toLowerCase {
    | "auth_token" => AUTH_TOKEN(dict->getOptionString("token"))
    | "auth_error" => AUTH_ERROR
    | "init_config" =>
      INIT_CONFIG({
        initConfig: dict->getJsonObjectFromDict("init_config"),
        isFullPageModalSupported: dict
        ->getDictfromDict("sdk_capabilities")
        ->getBool("full_page_modal", false),
      })
    | "embedded_modal_opened" => EMBEDDED_MODAL_OPENED
    | "embedded_modal_closed" => EMBEDDED_MODAL_CLOSED
    | messageType => Unknown(messageType)
    }
  | None => Unknown("")
  }
}

let sendMessageToParent = (~payload=[], messageType: EmbeddedTypes.messageToParent) => {
  IframeUtils.handlePostMessage(
    ~targetOrigin=parentOrigin.contents->Option.getOr("*"),
    [("type", (messageType :> string)->JSON.Encode.string)]->Array.concat(payload),
  )
}

let sendEventToParentForRefetchToken = () => {
  TOKEN_EXPIRED->sendMessageToParent(~payload=[("value", true->JSON.Encode.bool)])
}

let sendComponentDimensionToParent = (finalHeight, finalWidth, urlPath) => {
  EMBEDDED_COMPONENT_RESIZE->sendMessageToParent(
    ~payload=[
      ("height", finalHeight->JSON.Encode.int),
      ("width", finalWidth->JSON.Encode.int),
      ("component", JSON.Encode.string(urlPath)),
    ],
  )
}

let sendModalStateToParent = isOpen => {
  (isOpen ? EmbeddedTypes.EMBEDDED_MODAL_OPEN : EMBEDDED_MODAL_CLOSE)->sendMessageToParent
}

let sendModalVisibleToParent = () => {
  EMBEDDED_MODAL_VISIBLE->sendMessageToParent
}

let sendIframeReadyMessageToParent = () => {
  EMBEDDED_IFRAME_READY->sendMessageToParent
}
