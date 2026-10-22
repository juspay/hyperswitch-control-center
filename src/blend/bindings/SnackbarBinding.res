type snackbarVariant =
  | @as("info") Info
  | @as("success") Success
  | @as("warning") Warning
  | @as("error") Error

type snackbarPosition =
  | @as("top-left") TopLeft
  | @as("top-right") TopRight
  | @as("bottom-left") BottomLeft
  | @as("bottom-right") BottomRight
  | @as("top-center") TopCenter
  | @as("bottom-center") BottomCenter

type actionButton = {
  label: string,
  onClick: unit => unit,
  autoDismiss?: bool,
}

type addToastOptions = {
  header: string,
  description?: string,
  variant?: snackbarVariant,
  onClose?: unit => unit,
  actionButton?: actionButton,
  duration?: int,
  position?: snackbarPosition,
  slot?: React.element,
  width?: string,
  maxWidth?: string,
  minWidth?: string,
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~position: snackbarPosition=?,
  ~dismissOnClickAway: bool=?,
  ~visibleToasts: int=?,
  ~containerAriaLabel: string=?,
  ~hotkey: array<string>=?,
  ~maxWidth: string=?,
) => React.element = "SnackbarV2"

@unboxed
type toastId = String(string) | Number(int)

@module("@juspay/blend-design-system")
external addSnackbarV2: addToastOptions => toastId = "addSnackbarV2"
