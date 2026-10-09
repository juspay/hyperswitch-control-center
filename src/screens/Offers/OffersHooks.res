open APIUtils
open LogicUtils
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

let useOfferDetail = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  async offerId => {
    try {
      let url = getURL(~entityName=V1(OFFERS), ~methodType=Post, ~offersType=#OFFER_DETAIL)
      let response = await updateDetails(url, buildDetailBody(offerId), Post)
      response->getArrayDataFromJson(detailItemToObjMapper)->Array.get(0)
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Failed to fetch the offer"))
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
