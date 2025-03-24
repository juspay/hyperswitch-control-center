type actionType =
  | InternalRoute(string)
  | ExternalLink({url: string, trackingEvent: string})

type actionCards = {
  heading: string,
  imgSrc: string,
  action: actionType,
}
type vaultSections = [
  | #authenticateProcessor
  | #setupPMTS
  | #setupWebhook
  | #reviewAndConnect
]
