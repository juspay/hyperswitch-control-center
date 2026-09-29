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

type themeTokens = {
  primary: string,
  background: string,
  surface: string,
  link: string,
  linkHover: string,
  primaryButtonBackground: string,
  primaryButtonText: string,
  primaryButtonHover: string,
  secondaryButtonBackground: string,
  secondaryButtonText: string,
  secondaryButtonHover: string,
  fontFamily: string,
  fontSize: string,
  headingFontSize: string,
  radius: string,
}

type themeFrame = {src: string, id: string}

type deMessageType = SessionExpired | RouteChanged | UnknownMessage

let messageTypeFromString = messageType =>
  switch messageType {
  | "de:session-expired" => SessionExpired
  | "de:route-changed" => RouteChanged
  | _ => UnknownMessage
  }
