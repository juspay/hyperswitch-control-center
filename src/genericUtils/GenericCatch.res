let showToast = ToastState.useShowToast()
let toast = (message, toastType) => {
  showToast(~message, ~toastType, ())
}

let handleCatch = (
  ~error,
  ~callbackFun=_ => (),
  ~shouldResolve=false,
  ~doNothing=false,
  ~showToast=false,
  ~toastMessage="",
  (),
) => {
  callbackFun()
  if doNothing {
    None->ignore
  } else if shouldResolve {
    Promise.resolve()->ignore
  } else if showToast {
    toast(toastMessage, ToastError)
  } else {
    switch Exn.message(error) {
    | Some(msg) => Exn.raiseError(msg)
    | None => Exn.raiseError("Failed to Fetch")
    }
  }
}
