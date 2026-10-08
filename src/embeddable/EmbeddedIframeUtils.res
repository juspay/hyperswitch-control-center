let sendEventToParentForRefetchToken = () => {
  IframeUtils.handlePostMessage([
    ("type", JSON.Encode.string("TOKEN_EXPIRED")),
    ("value", true->JSON.Encode.bool),
  ])
}

let sendComponentDimensionToParent = (finalHeight, finalWidth, urlPath) => {
  IframeUtils.handlePostMessage([
    ("type", JSON.Encode.string("EMBEDDED_COMPONENT_RESIZE")),
    ("height", finalHeight->JSON.Encode.int),
    ("width", finalWidth->JSON.Encode.int),
    ("component", JSON.Encode.string(urlPath)),
  ])
}

let sendModalStateToParent = isOpen => {
  IframeUtils.handlePostMessage([
    ("type", JSON.Encode.string(isOpen ? "EMBEDDED_MODAL_OPEN" : "EMBEDDED_MODAL_CLOSE")),
  ])
}

let sendModalVisibleToParent = () => {
  IframeUtils.handlePostMessage([("type", JSON.Encode.string("EMBEDDED_MODAL_VISIBLE"))])
}

let sendIframeReadyMessageToParent = () => {
  IframeUtils.handlePostMessage([("type", JSON.Encode.string("EMBEDDED_IFRAME_READY"))])
}
