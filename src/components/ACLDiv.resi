@react.component
let make: (
  ~permission: AuthTypes.authorization,
  ~onClick: JsxEvent.Mouse.t => unit,
  ~children: React.element,
  ~className: string=?,
  ~noAccessDescription: string=?,
  ~description: string=?,
  ~tooltipWidthClass: string=?,
  ~isRelative: bool=?,
  ~contentAlign: ToolTip.contentPosition=?,
  ~justifyClass: string=?,
  ~tooltipForWidthClass: string=?,
  ~dataAttrStr: string=?,
) => React.element
