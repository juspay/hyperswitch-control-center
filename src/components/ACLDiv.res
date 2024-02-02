@react.component
let make = (
  ~permission,
  ~onClick,
  ~children,
  ~className="",
  ~noAccessDescription=?,
  ~description=?,
  ~tooltipWidthClass=?,
) => {
  <ACLToolTip
    access=permission
    ?noAccessDescription
    ?description
    ?tooltipWidthClass
    toolTipFor={<div className onClick={permission === AuthTypes.Access ? onClick : {_ => ()}}>
      {children}
    </div>}
    toolTipPosition={Top}
  />
}
