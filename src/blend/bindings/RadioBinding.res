type size =
  | @as("sm") Small
  | @as("md") Medium
  | @as("lg") Large

type slot = {slot: React.element, maxHeight?: string}
type maxLength = {label?: int, subLabel?: int}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~value: string=?,
  ~checked: bool,
  ~onCheckedChange: ReactEvent.Form.t => unit=?,
  ~disabled: bool=?,
  ~size: size=?,
  ~name: string=?,
  ~id: string=?,
  ~label: string=?,
  ~subLabel: string=?,
  ~slot: slot=?,
  ~maxLength: maxLength=?,
  ~error: bool=?,
  ~required: bool=?,
  @as("aria-label") ~ariaLabel: string=?,
) => React.element = "RadioV2"
