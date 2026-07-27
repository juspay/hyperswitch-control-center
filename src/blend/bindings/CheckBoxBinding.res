module CheckedValue = {
  type t
  external fromBool: bool => t = "%identity"
  external fromIndeterminate: string => t = "%identity"
  external toBool: t => bool = "%identity"
}

type size =
  | @as("sm") Small
  | @as("md") Medium

@module("@juspay/blend-design-system") @react.component
external make: (
  ~checked: CheckedValue.t=?,
  ~defaultChecked: bool=?,
  ~onCheckedChange: CheckedValue.t => unit=?,
  ~disabled: bool=?,
  ~size: size=?,
  ~label: string=?,
  ~subtext: string=?,
  ~error: bool=?,
  ~required: bool=?,
  ~id: string=?,
  ~name: string=?,
) => React.element = "Checkbox"
