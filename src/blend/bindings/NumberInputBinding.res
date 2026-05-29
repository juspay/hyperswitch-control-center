type numberInputSize =
  | @as("md") Medium
  | @as("lg") Large

@module("@juspay/blend-design-system") @react.component
external make: (
  ~value: Nullable.t<float>=?,
  ~onChange: ReactEvent.Form.t => unit=?,
  ~step: float=?,
  ~error: bool=?,
  ~errorMessage: string=?,
  ~size: numberInputSize=?,
  ~label: string=?,
  ~sublabel: string=?,
  ~helpIconHintText: string=?,
  ~hintText: string=?,
  ~preventNegative: bool=?,
  ~onBlur: ReactEvent.Focus.t => unit=?,
  ~onFocus: ReactEvent.Focus.t => unit=?,
  ~disabled: bool=?,
  ~maxLength: int=?,
  ~placeholder: string=?,
  ~name: string=?,
  ~id: string=?,
) => React.element = "NumberInput"
