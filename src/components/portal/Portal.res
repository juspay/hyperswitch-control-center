@react.component
let make = (~to, ~children) => {
  let portalNodes = Jotai.useAtomValue(PortalState.portalNodes)

  let portalNode = Dict.get(portalNodes, to)

  switch portalNode {
  | Some(domNode) => ReactDOM.createPortal(children, domNode)
  | None => children
  }
}
