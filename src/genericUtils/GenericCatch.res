let handleCatch = (
  ~error,
  ~callbackFun=_ => (),
  ~shouldResolve=false,
  ~raiseError=false,
  ~showErrorToast=false,
  ~showToast=?,
  ~toastMessage="",
  (),
) => {
  callbackFun()
  if raiseError {
    let _ = switch Exn.message(error) {
    | Some(msg) => Exn.raiseError(msg)
    | None => Exn.raiseError("Failed to Fetch")
    }
  }
  if showErrorToast {
    let _ = switch showToast {
    | Some(fn) => fn
    | None => ()
    }
  }

  if shouldResolve {
    Promise.resolve()->ignore
  } else {
    ()
  }
}
