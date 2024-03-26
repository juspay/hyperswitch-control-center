let handleCatch = (~error, ~callbackFun=?, ()) => {
  switch callbackFun {
  | Some(fn) => fn()
  | None =>
    switch Exn.message(error) {
    | Some(msg) => Exn.raiseError(msg)
    | None => Exn.raiseError("Failed to Fetch")
    }
  }
}
