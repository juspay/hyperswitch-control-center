@react.component
let make = (
  ~authorization,
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
    authorization
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
      <div className onClick={authorization === CommonAuthTypes.Access ? onClick : {_ => ()}}>
        {children}
      </div>
    </AddDataAttributes>}
    toolTipPosition={Top}
  />
}
