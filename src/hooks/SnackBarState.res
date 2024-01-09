type snackbarType =
  | General
  | Success
  | Error
  | Warning
  | Information

type snackbarProps = {
  snackbarKey: string,
  heading: string,
  body: string,
  snackbarType: snackbarType,
  actionElement: React.element,
  onClose?: unit => unit,
}

let defaultOpenSnackbar: array<snackbarProps> = []

let openSnackbar = Recoil.atom(. "openSnackbar", defaultOpenSnackbar)

type showSnackbarFn = (
  ~heading: string,
  ~body: string,
  ~snackbarType: snackbarType,
  ~actionElement: React.element=?,
  ~onClose: unit => unit=?,
  unit,
) => unit
