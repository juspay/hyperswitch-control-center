@get external getEventSource: Dom.event => IframeUtils.parent = "source"
@get external getEventOrigin: Dom.event => string = "origin"

let parentOrigin = ref("*")

let isMessageFromParent = (ev: Dom.event) => ev->getEventSource === IframeUtils.iframeParent

let getMessageFromParent = (ev: Dom.event) => {
  ev->isMessageFromParent
    ? (ev->HandlingEvents.convertToCustomEvent).data->JSON.Decode.object
    : None
}

let updateParentOrigin = (ev: Dom.event) => {
  let origin = ev->getEventOrigin
  if ev->isMessageFromParent && origin->LogicUtils.isNonEmptyString && origin !== "null" {
    parentOrigin := origin
  }
}

let sendMessageToParent = (~payload=[], messageType: EmbeddedTypes.messageToParent) => {
  IframeUtils.handlePostMessage(
    ~targetOrigin=parentOrigin.contents,
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
