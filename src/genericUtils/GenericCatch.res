let handleCatch = (~error, ~callbackFun=_ => (), ~shouldResolve=false, ()) => {
  callbackFun()
  if shouldResolve {
    Promise.resolve()->ignore
  } else {
    switch Exn.message(error) {
    | Some(msg) => Exn.raiseError(msg)
    | None => Exn.raiseError("Failed to Fetch")
    }
  }
}
