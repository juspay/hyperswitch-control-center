type modalTarget = Inline | Waiting | Portal(Dom.element)

type fullPageModalContextType = {
  isEnabled: bool,
  isFrameExpanded: bool,
  modalRoot: option<Dom.element>,
  setModalRoot: Nullable.t<Dom.element> => unit,
  registerModal: unit => unit,
  unregisterModal: unit => unit,
}

let defaultContext = {
  isEnabled: false,
  isFrameExpanded: false,
  modalRoot: None,
  setModalRoot: _ => (),
  registerModal: () => (),
  unregisterModal: () => (),
}

let fullPageModalContext = React.createContext(defaultContext)

module Provider = {
  let make = React.Context.provider(fullPageModalContext)
}

let useFullPageModal = () => React.useContext(fullPageModalContext)

let useModalTarget = (~showModal) => {
  let {isEnabled, isFrameExpanded, modalRoot, registerModal, unregisterModal} = useFullPageModal()

  React.useEffect(() => {
    if isEnabled && showModal {
      registerModal()
      Some(unregisterModal)
    } else {
      None
    }
  }, (isEnabled, showModal))

  switch modalRoot {
  | Some(root) if isEnabled => showModal && isFrameExpanded ? Portal(root) : Waiting
  | _ => Inline
  }
}
