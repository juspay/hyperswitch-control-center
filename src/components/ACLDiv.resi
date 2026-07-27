@react.component
let make: (
  ~authorization: CommonAuthTypes.authorization,
  ~onClick: JsxEvent.Mouse.t => unit,
  ~children: React.element,
  ~className: string=?,
  ~noAccessDescription: string=?,
  ~description: string=?,
  ~showTooltip: bool=?,
  ~dataAttrStr: string=?,
) => React.element
