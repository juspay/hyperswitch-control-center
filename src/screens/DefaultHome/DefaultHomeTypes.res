type actionType =
  | InternalRoute(string)
  | ExternalLink({url: string, trackingEvent: string})
  | CustomAction

type productDetailCards = {
  product?: ProductTypes.productTypes,
  heading: string,
  description: string,
  imgSrc: string,
  action: actionType,
}
