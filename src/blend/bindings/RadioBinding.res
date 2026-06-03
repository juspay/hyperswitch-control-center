type size =
  | @as("sm") Small
  | @as("md") Medium

@module("@juspay/blend-design-system") @react.component
external make: (
  ~value: string=?,
  ~checked: bool=?,
  ~defaultChecked: bool=?,
  ~onChange: ReactEvent.Form.t => unit=?,
  ~disabled: bool=?,
  ~size: size=?,
  ~name: string=?,
  ~id: string=?,
  ~subtext: string=?,
  ~error: bool=?,
  ~required: bool=?,
  ~children: React.element=?,
) => React.element = "Radio"

module Group = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~name: string,
    ~value: string=?,
    ~defaultValue: string=?,
    ~onChange: string => unit=?,
    ~disabled: bool=?,
    ~label: string=?,
    ~children: React.element,
    ~id: string=?,
    ~error: bool=?,
    ~required: bool=?,
  ) => React.element = "RadioGroup"
}
