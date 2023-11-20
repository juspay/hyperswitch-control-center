type hideModalFn = unit => unit
type modalProps = {
  title: string,
  getContent: hideModalFn => React.element,
  closeOnClickOutside: bool,
}

let makeModalProps = (~title, ~getContent, ~closeOnClickOutside=false, ()) => {
  title,
  getContent,
  closeOnClickOutside,
}

let defaultOpenModals: array<modalProps> = []

let openModals = Recoil.atom(. "openModals", defaultOpenModals)

let useShowModal = () => {
  let setOpenModals = Recoil.useSetRecoilState(openModals)
  React.useCallback1(modalProps => {
    setOpenModals(.prevArr => prevArr->Js.Array2.concat([modalProps]))
  }, [setOpenModals])
}
