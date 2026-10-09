@react.component
let make = (~children) => {
  open EmbeddedIframeUtils

  let {isFullPageModalSupported: isEnabled} = React.useContext(
    EmbeddedCheckProvider.embeddedContext,
  )
  let (openModalCount, setOpenModalCount) = React.useState(_ => 0)
  let (isFrameExpanded, setIsFrameExpanded) = React.useState(_ => false)
  let (modalRoot, setModalRootElement) = React.useState(_ => None)
  let isFrameExpandedRef = React.useRef(false)

  let hasOpenModals = openModalCount > 0

  React.useEffect(() => {
    if isEnabled {
      let handleFrameMessage = (ev: Dom.event) => {
        let messageType =
          ev
          ->getMessageFromParent
          ->Option.mapOr("", dict => dict->LogicUtils.getString("type", ""))
          ->EmbeddableGlobalUtils.messageToTypeConversion
        switch messageType {
        | EMBEDDED_MODAL_OPENED => setIsFrameExpanded(_ => true)
        | EMBEDDED_MODAL_CLOSED => setIsFrameExpanded(_ => false)
        | _ => ()
        }
      }
      Window.addEventListener("message", handleFrameMessage)
      Some(
        () => {
          Window.removeEventListener("message", handleFrameMessage)
          if isFrameExpandedRef.current {
            sendModalStateToParent(false)
          }
        },
      )
    } else {
      None
    }
  }, [isEnabled])

  React.useEffect(() => {
    if isEnabled && hasOpenModals !== isFrameExpanded {
      sendModalStateToParent(hasOpenModals)
    }
    None
  }, (isEnabled, hasOpenModals, isFrameExpanded))

  React.useEffect(() => {
    isFrameExpandedRef.current = isFrameExpanded
    if isEnabled {
      sendModalVisibleToParent()
    }
    None
  }, [isFrameExpanded])

  let setModalRoot = React.useCallback(element => {
    setModalRootElement(_ => element->Nullable.toOption)
  }, [])
  let registerModal = React.useCallback(() => setOpenModalCount(count => count + 1), [])
  let unregisterModal = React.useCallback(() => setOpenModalCount(count => count - 1), [])

  let value = React.useMemo((): FullPageModalContext.fullPageModalContextType => {
    isEnabled,
    isFrameExpanded,
    modalRoot,
    setModalRoot,
    registerModal,
    unregisterModal,
  }, (isEnabled, isFrameExpanded, modalRoot))

  <FullPageModalContext.Provider value> children </FullPageModalContext.Provider>
}
