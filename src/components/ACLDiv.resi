@react.component
let make: (
  ~permission: AuthTypes.authorization,
  ~onClick: JsxEvent.Mouse.t => unit,
  ~children: React.element,
  ~className: string=?,
  ~noAccessDescription: string=?,
  ~description: string=?,
  ~tooltipWidthClass: string=?,
) => React.element
