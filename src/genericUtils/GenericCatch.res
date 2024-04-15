let handleCatch = (~error, ~callbackFun=_ => (), ~shouldResolve=false, ~doNothing=false, ()) => {
  callbackFun()
  if doNothing {
    None->ignore
  } else if shouldResolve {
    Promise.resolve()->ignore
  } else {
    switch Exn.message(error) {
    | Some(msg) => Exn.raiseError(msg)
    | None => Exn.raiseError("Failed to Fetch")
    }
  }
}
