open ReconTypes
let getAuthStatusFromMessage = authStatus =>
  switch authStatus {
  | "LoggedOut" => IframeLoggedOut
  | _ => IframeLoggedIn
  }
