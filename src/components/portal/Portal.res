@react.component
let make = (~to, ~children) => {
  let portalNodes = Recoil.useRecoilValueFromAtom(PortalState.portalNodes)

  let portalNode = Js.Dict.get(portalNodes, to)

  switch portalNode {
  | Some(domNode) => ReactDOM.createPortal(children, domNode)
  | None => children
  }
}
