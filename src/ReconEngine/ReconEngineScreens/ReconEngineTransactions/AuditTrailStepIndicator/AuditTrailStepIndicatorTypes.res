type section = {
  id: string,
  customComponent: option<React.element>,
  onClick: JsxEventU.Mouse.t => unit,
  reasonText: option<string>,
}
