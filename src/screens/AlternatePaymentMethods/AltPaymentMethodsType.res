type actionType =
  | InternalRoute(string)
  | ExternalLink({url: string, trackingEvent: string})

type altConfigureStep = {
  heading: string,
  description: React.element,
  action: actionType,
  buttonText: string,
}
