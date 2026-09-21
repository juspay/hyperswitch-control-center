open APIUtils
open OffersUtils

let useOffersList = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  async (~limit, ~offset, ~offerCode="", ~filterValueJson=Dict.make()) => {
    try {
      let url = getURL(~entityName=V1(OFFERS), ~methodType=Post, ~offersType=#OFFERS_LIST)
      let body = buildListBody(~merchantId, ~limit, ~offset, ~offerCode, ~filterValueJson)
      let response = await updateDetails(url, body, Post)
      response->listResponseMapper
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch offers"))
    }
  }
}

let useUpdateOfferStatus = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  async (~offerId, ~status) => {
    try {
      let url = getURL(
        ~entityName=V1(OFFERS),
        ~methodType=Post,
        ~offersType=#OFFER_STATUS_UPDATE,
        ~id=Some(offerId),
      )
      let body = buildStatusUpdateBody(~status)
      await updateDetails(url, body, Post)
    } catch {
    | Exn.Error(e) =>
      Exn.raiseError(Exn.message(e)->Option.getOr("Failed to update the offer status"))
    }
  }
}

let useDeleteOffer = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  async offerId => {
    try {
      let url = getURL(
        ~entityName=V1(OFFERS),
        ~methodType=Post,
        ~offersType=#OFFER_DELETE,
        ~id=Some(offerId),
      )
      let body = buildDeleteBody(~merchantId)
      await updateDetails(url, body, Post)
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to delete the offer"))
    }
  }
}
