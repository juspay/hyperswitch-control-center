@module("react-color") @react.component
external make: (~color: string, ~onChangeComplete: Js.Json.t => unit) => React.element =
  "SketchPicker"
