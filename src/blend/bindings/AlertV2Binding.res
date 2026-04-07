type alertV2Type =
  | @as("primary") Primary
  | @as("success") Success
  | @as("warning") Warning
  | @as("error") Error
  | @as("neutral") Neutral

type slotConfig = {slot: React.element}

type alertV2Action = {
  text: string,
  onClick: ReactEvent.Mouse.t => unit,
}

type alertV2ActionPosition =
  | @as("bottom") Bottom
  | @as("right") Right

type alertV2Actions = {
  position?: alertV2ActionPosition,
  primaryAction?: alertV2Action,
  secondaryAction?: alertV2Action,
}

type alertV2CloseButton = {show: bool}

module BaseAlertV2 = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~\"type": alertV2Type=?,
    ~slot: slotConfig=?,
    ~heading: string=?,
    ~description: string=?,
    ~actions: alertV2Actions=?,
    ~closeButton: alertV2CloseButton=?,
    ~maxWidth: string=?,
    ~className: string=?,
  ) => React.element = "AlertV2"
}

@react.component
let make = (
  ~alertType: alertV2Type=Primary,
  ~slot: slotConfig=?,
  ~heading: string=?,
  ~description: string=?,
  ~actions: alertV2Actions=?,
  ~className: string=?,
) => {
  <BaseAlertV2
    \"type"=alertType
    ?slot
    ?heading
    ?description
    ?actions
    closeButton={{show: false}}
    maxWidth="none"
    ?className
  />
}
