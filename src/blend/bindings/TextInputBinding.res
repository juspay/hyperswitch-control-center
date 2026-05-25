type inputSize =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

type cursor =
  | @as("text") Text
  | @as("pointer") Pointer
  | @as("default") Default
  | @as("not-allowed") NotAllowed

@module("@juspay/blend-design-system") @react.component
external make: (
  ~required: bool=?,
  ~label: string=?,
  ~sublabel: string=?,
  ~hintText: string=?,
  ~helpIconHintText: string=?,
  ~error: bool=?,
  ~errorMessage: string=?,
  ~disabled: bool=?,
  ~size: inputSize=?,
  ~leftSlot: React.element=?,
  ~rightSlot: React.element=?,
  ~value: string,
  ~onChange: ReactEvent.Form.t => unit,
  ~onBlur: ReactEvent.Focus.t => unit=?,
  ~onFocus: ReactEvent.Focus.t => unit=?,
  ~onKeyDown: ReactEvent.Keyboard.t => unit=?,
  ~onKeyPress: ReactEvent.Keyboard.t => unit=?,
  ~onKeyUp: ReactEvent.Keyboard.t => unit=?,
  ~placeholder: string=?,
  ~name: string=?,
  ~cursor: cursor=?,
  ~id: string=?,
  ~autoComplete: string=?,
  ~autoFocus: bool=?,
  ~readOnly: bool=?,
  ~maxLength: int=?,
  ~minLength: int=?,
  ~pattern: string=?,
  ~step: string=?,
  ~min: string=?,
  ~max: string=?,
  ~inputMode: string=?,
  @as("type") ~type_: string=?,
  ~tabIndex: int=?,
  ~passwordToggle: bool=?,
) => React.element = "TextInput"
