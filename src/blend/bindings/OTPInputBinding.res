@module("@juspay/blend-design-system") @react.component
external make: (
  ~label: string=?,
  ~sublabel: string=?,
  ~helpIconHintText: string=?,
  ~error: bool=?,
  ~errorMessage: string=?,
  ~hintText: string=?,
  ~value: string=?,
  ~length: int=?,
  ~autoFocus: bool=?,
  ~onChange: string => unit=?,
  ~form: string=?,
  ~disabled: bool=?,
  ~name: string=?,
  ~id: string=?,
  ~required: bool=?,
  ~readOnly: bool=?,
) => React.element = "OTPInputV2"
