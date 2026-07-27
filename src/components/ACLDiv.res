@react.component
let make = (
  ~authorization,
  ~onClick,
  ~children,
  ~className="",
  ~noAccessDescription=?,
  ~description=?,
  ~showTooltip=true,
  ~dataAttrStr=?,
) => {
  switch showTooltip {
  | true =>
    <ACLToolTip
      authorization
      ?noAccessDescription
      ?description
      toolTipFor={<AddDataAttributes
        attributes=[("data-testid", dataAttrStr->Option.getOr("")->String.toLowerCase)]>
        <div className onClick={authorization === CommonAuthTypes.Access ? onClick : {_ => ()}}>
          {children}
        </div>
      </AddDataAttributes>}
      toolTipPosition={Top}
    />
  | false => React.null
  }
}
