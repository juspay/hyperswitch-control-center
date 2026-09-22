type deSection = {
  slug: string,
  label: string,
  dePath: string,
  target: string,
  iconTag: option<string>,
  searchOptions: array<(string, string)>,
  inSidebar: bool,
}

type mintState = {seq: int, at: float}

type deMessageType = SessionExpired | RouteChanged | UnknownMessage

let messageTypeFromString = messageType =>
  switch messageType {
  | "de:session-expired" => SessionExpired
  | "de:route-changed" => RouteChanged
  | _ => UnknownMessage
  }
