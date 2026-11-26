type size =
  | @as("sm") Small
  | @as("md") Medium
  | @as("lg") Large

type slot = {slot: React.element, maxHeight?: string}
type maxLength = {label?: int, subLabel?: int}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~checked: bool,
  ~onCheckedChange: bool => unit=?,
  ~disabled: bool=?,
  ~required: bool=?,
  ~error: bool=?,
  ~size: size=?,
  ~label: string=?,
  ~subLabel: string=?,
  ~slot: slot=?,
  ~maxLength: maxLength=?,
  ~id: string=?,
  ~name: string=?,
  ~value: string=?,
  @as("aria-label") ~ariaLabel: string=?,
  @as("type") ~type_: string=?,
) => React.element = "SwitchV2"
