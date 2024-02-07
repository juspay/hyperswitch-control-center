@react.component
let make = (
  ~permission,
  ~onClick,
  ~children,
  ~className="",
  ~noAccessDescription=?,
  ~description=?,
  ~tooltipWidthClass=?,
  ~isRelative=?,
  ~contentAlign=?,
  ~justifyClass=?,
  ~tooltipForWidthClass=?,
) => {
  <ACLToolTip
    access=permission
    ?noAccessDescription
    ?tooltipForWidthClass
    ?description
    ?isRelative
    ?contentAlign
    ?tooltipWidthClass
    ?justifyClass
    toolTipFor={<div className onClick={permission === AuthTypes.Access ? onClick : {_ => ()}}>
      {children}
    </div>}
    toolTipPosition={Top}
  />
}
