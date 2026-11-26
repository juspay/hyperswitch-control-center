type numberInputSize =
  | @as("sm") Small
  | @as("md") Medium
  | @as("lg") Large

type label = {text: string, subtext?: string}
type error = {show: bool, message?: string}
type slot = {left?: React.element, right?: React.element}
type direction =
  | @as("left") Left
  | @as("right") Right

@module("@juspay/blend-design-system") @react.component
external make: (
  ~value: Nullable.t<float>,
  ~onChange: ReactEvent.Form.t => unit,
  ~min: float=?,
  ~max: float=?,
  ~step: float=?,
  ~error: error=?,
  ~size: numberInputSize=?,
  ~label: label=?,
  ~helpIconText: string=?,
  ~hintText: string=?,
  ~slot: slot=?,
  ~unit: string=?,
  ~unitDirection: direction=?,
  ~preventNegative: bool=?,
  ~onBlur: ReactEvent.Focus.t => unit=?,
  ~onFocus: ReactEvent.Focus.t => unit=?,
  ~disabled: bool=?,
  ~required: bool=?,
  ~maxLength: int=?,
  ~placeholder: string=?,
  ~name: string=?,
  ~id: string=?,
) => React.element = "NumberInputV2"
