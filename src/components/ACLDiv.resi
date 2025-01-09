@react.component
let make: (
  ~authorization: CommonAuthTypes.authorization,
  ~onClick: JsxEvent.Mouse.t => unit,
  ~children: React.element,
  ~className: string=?,
  ~noAccessDescription: string=?,
  ~description: string=?,
  ~tooltipWidthClass: string=?,
  ~isRelative: bool=?,
  ~showTooltip: bool=?,
  ~contentAlign: ToolTip.contentPosition=?,
  ~justifyClass: string=?,
  ~tooltipForWidthClass: string=?,
  ~dataAttrStr: string=?,
  ~height: string=?,
) => React.element
