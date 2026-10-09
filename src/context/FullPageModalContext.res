type modalTarget = Inline | Waiting | Portal(Dom.element)

type fullPageModalContextType = {
  isEnabled: bool,
  isFrameExpanded: bool,
  isFallbackInline: bool,
  modalRoot: option<Dom.element>,
  setModalRoot: Nullable.t<Dom.element> => unit,
  isModalActive: unit => bool,
  registerModal: unit => unit,
  unregisterModal: unit => unit,
}

let defaultContext = {
  isEnabled: false,
  isFrameExpanded: false,
  isFallbackInline: false,
  modalRoot: None,
  setModalRoot: _ => (),
  isModalActive: () => false,
  registerModal: () => (),
  unregisterModal: () => (),
}

let fullPageModalContext = React.createContext(defaultContext)

module Provider = {
  let make = React.Context.provider(fullPageModalContext)
}

let useFullPageModal = () => React.useContext(fullPageModalContext)

let useModalTarget = (~showModal) => {
  let {
    isEnabled,
    isFrameExpanded,
    isFallbackInline,
    modalRoot,
    registerModal,
    unregisterModal,
  } = useFullPageModal()

  React.useEffect(() => {
    if isEnabled && showModal {
      registerModal()
      Some(unregisterModal)
    } else {
      None
    }
  }, (isEnabled, showModal))

  switch modalRoot {
  | Some(root) if isEnabled && !isFallbackInline =>
    showModal && isFrameExpanded ? Portal(root) : Waiting
  | _ => Inline
  }
}
