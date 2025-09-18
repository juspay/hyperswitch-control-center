open ReconTypes
let getAuthStatusFromMessage = authStatus =>
  switch authStatus {
  | "LoggedOut" => IframeLoggedOut
  | _ => IframeLoggedIn
  }

let getEventTypeFromString = eventTypeString =>
  switch eventTypeString {
  | "AuthenticationStatus"
  | _ =>
    AuthenticationStatus
  }
