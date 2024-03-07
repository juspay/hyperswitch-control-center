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
  ~dataAttrStr="",
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
    toolTipFor={<AddDataAttributes attributes=[("data-testid", dataAttrStr)]>
      <div className onClick={permission === AuthTypes.Access ? onClick : {_ => ()}}>
        {children}
      </div>
    </AddDataAttributes>}
    toolTipPosition={Top}
  />
}
