let handleCatch = (~error, ~callbackFun=_ => (), ~shouldResolve=false, ()) => {
  if shouldResolve {
    Promise.resolve()->ignore
  }
  callbackFun()
  switch Exn.message(error) {
  | Some(msg) => Exn.raiseError(msg)
  | None => Exn.raiseError("Failed to Fetch")
  }
}
