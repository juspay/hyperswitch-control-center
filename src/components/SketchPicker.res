@module("react-color") @react.component
external make: (~color: string, ~onChangeComplete: JSON.t => unit) => React.element = "SketchPicker"
