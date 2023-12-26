type hideModalFn = unit => unit
type modalProps = {
  title: string,
  getContent: hideModalFn => React.element,
  closeOnClickOutside: bool,
}

let defaultOpenModals: array<modalProps> = []

let openModals = Recoil.atom(. "openModals", defaultOpenModals)
