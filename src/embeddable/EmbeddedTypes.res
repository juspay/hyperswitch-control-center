type initConfigPayload = {
  initConfig: JSON.t,
  isFullPageModalSupported: bool,
}

type messageFromParent =
  | AUTH_TOKEN(option<string>)
  | AUTH_ERROR
  | INIT_CONFIG(initConfigPayload)
  | EMBEDDED_MODAL_OPENED
  | EMBEDDED_MODAL_CLOSED
  | Unknown(string)

type messageToParent =
  | TOKEN_EXPIRED
  | EMBEDDED_IFRAME_READY
  | EMBEDDED_COMPONENT_RESIZE
  | EMBEDDED_MODAL_OPEN
  | EMBEDDED_MODAL_CLOSE
  | EMBEDDED_MODAL_VISIBLE
