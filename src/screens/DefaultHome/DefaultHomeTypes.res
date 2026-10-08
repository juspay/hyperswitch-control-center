type actionType =
  | InternalRoute
  | ExternalLink({url: string, trackingEvent: string})

type actionDetailCards = {
  heading: string,
  description: string,
  imgSrc: string,
  action: actionType,
}
