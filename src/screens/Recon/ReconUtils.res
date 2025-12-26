open ReconTypes
open HSwitchSettingTypes

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

let mapStringToReconStatus = (reconStatus: string): reconStatus => {
  switch reconStatus->String.toLowerCase {
  | "notrequested" => NotRequested
  | "requested" => Requested
  | "active" => Active
  | "disabled" => Disabled
  | _ => NotRequested
  }
}
