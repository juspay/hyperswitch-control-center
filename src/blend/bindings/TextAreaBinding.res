type resize =
  | @as("none") None
  | @as("both") Both
  | @as("horizontal") Horizontal
  | @as("vertical") Vertical
  | @as("block") Block
  | @as("inline") Inline

type inputSize =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

type error = {show: bool, message?: string}

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
  ~size: inputSize=?,
  ~label: string=?,
  ~sublabel: string=?,
  ~hintText: string=?,
  ~helpIconText: string=?,
  ~required: bool=?,
  ~error: error=?,
  ~resize: resize=?,
  ~wrap: string=?,
  ~maxLength: int=?,
  ~readOnly: bool=?,
  ~name: string=?,
  ~id: string=?,
) => React.element = "TextAreaV2"
