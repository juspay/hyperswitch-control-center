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
  ~dataAttrStr=?,
  ~height=?,
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
    ?height
    toolTipFor={<AddDataAttributes
      attributes=[("data-testid", dataAttrStr->Option.getOr("")->String.toLowerCase)]>
      <div className onClick={permission === CommonAuthTypes.Access ? onClick : {_ => ()}}>
        {children}
      </div>
    </AddDataAttributes>}
    toolTipPosition={Top}
  />
}
