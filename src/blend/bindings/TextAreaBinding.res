type resize =
  | @as("none") None
  | @as("both") Both
  | @as("horizontal") Horizontal
  | @as("vertical") Vertical
  | @as("block") Block
  | @as("inline") Inline

@module("@juspay/blend-design-system") @react.component
external make: (
  ~value: string,
  ~placeholder: string,
  ~onChange: ReactEvent.Form.t => unit,
  ~onFocus: ReactEvent.Focus.t => unit=?,
  ~onBlur: ReactEvent.Focus.t => unit=?,
  ~disabled: bool=?,
  ~autoFocus: bool=?,
  ~rows: int=?,
  ~cols: int=?,
  ~label: string=?,
  ~sublabel: string=?,
  ~hintText: string=?,
  ~helpIconHintText: string=?,
  ~required: bool=?,
  ~error: bool=?,
  ~errorMessage: string=?,
  ~resize: resize=?,
  ~wrap: string=?,
  ~maxLength: int=?,
  ~readOnly: bool=?,
  ~name: string=?,
  ~id: string=?,
) => React.element = "TextArea"
