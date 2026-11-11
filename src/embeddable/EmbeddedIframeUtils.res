open LogicUtils
open EmbeddedTypes

@get external getEventSource: Dom.event => IframeUtils.parent = "source"
@get external getEventOrigin: Dom.event => string = "origin"

let parentOrigin = ref(None)

let isTrustedParentMessage = (ev: Dom.event) => {
  ev->getEventSource === IframeUtils.iframeParent &&
    parentOrigin.contents->mapOptionOrDefault(true, origin => origin === ev->getEventOrigin)
}

let pinParentOrigin = (ev: Dom.event) => {
  let origin = ev->getEventOrigin
  if parentOrigin.contents->Option.isNone && origin->isNonEmptyString && origin !== "null" {
    parentOrigin := Some(origin)
  }
}

let decodeMessageFromParent = (ev: Dom.event): messageFromParent => {
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
    | messageType => UNKNOWN(messageType)
    }
  | None => UNKNOWN("")
  }
}

let sendMessageToParent = (~payload=[], messageType: messageToParent) => {
  let targetOrigin = switch (parentOrigin.contents, messageType) {
  | (Some(origin), _) => Some(origin)
  | (None, EMBEDDED_IFRAME_READY) => Some("*")
  | (None, _) => None
  }
  switch targetOrigin {
  | Some(targetOrigin) =>
    IframeUtils.handlePostMessage(
      ~targetOrigin,
      [("type", (messageType :> string)->JSON.Encode.string)]->Array.concat(payload),
    )
  | None => ()
  }
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
  (isOpen ? EMBEDDED_MODAL_OPEN : EMBEDDED_MODAL_CLOSE)->sendMessageToParent
}

let sendModalVisibleToParent = () => {
  EMBEDDED_MODAL_VISIBLE->sendMessageToParent
}

let sendIframeReadyMessageToParent = () => {
  EMBEDDED_IFRAME_READY->sendMessageToParent
}
