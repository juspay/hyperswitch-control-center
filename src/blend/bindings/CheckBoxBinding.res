module CheckedValue = {
  type t
  external fromBool: bool => t = "%identity"
  external fromIndeterminate: string => t = "%identity"
  let toBool = value => value === fromBool(true)
}

type size =
  | @as("sm") Small
  | @as("md") Medium
  | @as("lg") Large

@module("@juspay/blend-design-system") @react.component
external make: (
  ~checked: CheckedValue.t,
  ~onCheckedChange: CheckedValue.t => unit=?,
  ~disabled: bool=?,
  ~size: size=?,
  ~label: string=?,
  ~subLabel: string=?,
  @as("aria-label") ~ariaLabel: string=?,
  ~error: bool=?,
  ~required: bool=?,
  ~id: string=?,
  ~name: string=?,
) => React.element = "CheckboxV2"
