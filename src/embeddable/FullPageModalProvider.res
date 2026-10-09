let frameResponseTimeout = 500

@react.component
let make = (~children) => {
  open EmbeddedIframeUtils

  let {isFullPageModalSupported: isEnabled} = React.useContext(
    EmbeddedCheckProvider.embeddedContext,
  )
  let (openModalCount, setOpenModalCount) = React.useState(_ => 0)
  let (isFrameExpanded, setIsFrameExpanded) = React.useState(_ => false)
  let (isFallbackInline, setIsFallbackInline) = React.useState(_ => false)
  let (modalRoot, setModalRootElement) = React.useState(_ => None)
  let isFrameExpandedRef = React.useRef(false)
  let isModalActiveRef = React.useRef(false)

  let hasOpenModals = openModalCount > 0

  React.useLayoutEffect(() => {
    isModalActiveRef.current =
      isEnabled && (isFrameExpanded || (hasOpenModals && !isFallbackInline))
    None
  }, (isEnabled, isFrameExpanded, hasOpenModals, isFallbackInline))

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
      Some(() => Window.removeEventListener("message", handleFrameMessage))
    } else {
      None
    }
  }, [isEnabled])

  React.useEffect(() => {
    switch (isEnabled, hasOpenModals, isFrameExpanded) {
    | (true, true, false) => {
        sendModalStateToParent(true)
        let timeoutId = setTimeout(() => setIsFallbackInline(_ => true), frameResponseTimeout)
        Some(() => clearTimeout(timeoutId))
      }
    | (true, false, true) => {
        sendModalStateToParent(false)
        None
      }
    | _ => {
        setIsFallbackInline(_ => false)
        None
      }
    }
  }, (isEnabled, hasOpenModals, isFrameExpanded))

  React.useEffect(() => {
    isFrameExpandedRef.current = isFrameExpanded
    if isEnabled {
      sendModalVisibleToParent()
    }
    None
  }, [isFrameExpanded])

  React.useEffect(() => {
    Some(
      () =>
        if isFrameExpandedRef.current {
          sendModalStateToParent(false)
        },
    )
  }, [])

  let setModalRoot = React.useCallback(element => {
    setModalRootElement(_ => element->Nullable.toOption)
  }, [])
  let isModalActive = React.useCallback(() => isModalActiveRef.current, [])
  let registerModal = React.useCallback(() => setOpenModalCount(count => count + 1), [])
  let unregisterModal = React.useCallback(() => setOpenModalCount(count => count - 1), [])

  let value = React.useMemo((): FullPageModalContext.fullPageModalContextType => {
    isEnabled,
    isFrameExpanded,
    isFallbackInline,
    modalRoot,
    setModalRoot,
    isModalActive,
    registerModal,
    unregisterModal,
  }, (isEnabled, isFrameExpanded, isFallbackInline, modalRoot))

  <FullPageModalContext.Provider value> children </FullPageModalContext.Provider>
}
