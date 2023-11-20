module RenderIf = {
  @react.component
  let make = (~condition, ~children) => {
    if condition {
      children
    } else {
      React.null
    }
  }
}
