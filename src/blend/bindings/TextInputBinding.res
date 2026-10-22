type inputSize =
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

type inputError = {show: bool, message?: string}
type inputSlot = {slot: React.element, maxHeight?: string}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~required: bool=?,
  ~label: string=?,
  ~subLabel: string=?,
  ~hintText: string=?,
  ~helpIconText: string=?,
  ~error: inputError=?,
  ~disabled: bool=?,
  ~size: inputSize=?,
  ~leftSlot: inputSlot=?,
  ~rightSlot: inputSlot=?,
  ~value: string,
  ~onChange: ReactEvent.Form.t => unit,
  ~onBlur: ReactEvent.Focus.t => unit=?,
  ~onFocus: ReactEvent.Focus.t => unit=?,
  ~onKeyDown: ReactEvent.Keyboard.t => unit=?,
  ~onKeyPress: ReactEvent.Keyboard.t => unit=?,
  ~onKeyUp: ReactEvent.Keyboard.t => unit=?,
  ~placeholder: string=?,
  ~name: string=?,
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
  @as("aria-label") ~ariaLabel: string=?,
) => React.element = "TextInputV2"
