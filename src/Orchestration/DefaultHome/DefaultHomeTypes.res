type actionType =
  | InternalRoute
  | ExternalLink({url: string, trackingEvent: string})

type productDetailCards = {
  product: ProductTypes.productTypes,
  heading: string,
  description: string,
  imgSrc: string,
  action: actionType,
}

type actionDetailCards = {
  heading: string,
  description: string,
  imgSrc: string,
  action: actionType,
}
