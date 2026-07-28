type size =
  | @as("sm") Small
  | @as("md") Medium

@module("@juspay/blend-design-system") @react.component
external make: (
  ~checked: bool=?,
  ~defaultChecked: bool=?,
  ~onChange: bool => unit=?,
  ~disabled: bool=?,
  ~required: bool=?,
  ~error: bool=?,
  ~size: size=?,
  ~label: string=?,
  ~subtext: string=?,
  ~slot: React.element=?,
  ~name: string=?,
  ~value: string=?,
) => React.element = "Switch"
