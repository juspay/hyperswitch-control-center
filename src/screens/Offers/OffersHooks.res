open APIUtils
open LogicUtils

let useMerchantId = () => {
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  merchantId
}

let useOffersList = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let merchantId = useMerchantId()

  async (~limit, ~offset, ~filterValueJson, ~sortField, ~sortOrder) => {
    let url = getURL(~entityName=V1(OFFERS), ~methodType=Post, ~offersType=#OFFERS_LIST)
    let body = OffersUtils.buildListBody(
      ~merchantId,
      ~limit,
      ~offset,
      ~sortField,
      ~sortOrder,
      ~filterValueJson,
    )
    let response = await updateDetails(url, body, Post)
    response->OffersUtils.listResponseMapper
  }
}

let useOfferDetail = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let merchantId = useMerchantId()

  async offerId => {
    let url = getURL(~entityName=V1(OFFERS), ~methodType=Post, ~offersType=#OFFER_DETAIL)
    let body = OffersUtils.buildDetailBody(~offerId, ~merchantId)
    let response = await updateDetails(url, body, Post)
    response->getArrayDataFromJson(OffersUtils.detailItemToObjMapper)->Array.get(0)
  }
}

let useUpdateOfferStatus = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  async (~offerId, ~status) => {
    let url = getURL(
      ~entityName=V1(OFFERS),
      ~methodType=Post,
      ~offersType=#OFFER_STATUS_UPDATE,
      ~id=Some(offerId),
    )
    let body = OffersUtils.buildStatusUpdateBody(~status)
    await updateDetails(url, body, Post)
  }
}

let useDeleteOffer = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let merchantId = useMerchantId()

  async offerId => {
    let url = getURL(
      ~entityName=V1(OFFERS),
      ~methodType=Post,
      ~offersType=#OFFER_DELETE,
      ~id=Some(offerId),
    )
    let body = OffersUtils.buildDeleteBody(~merchantId)
    await updateDetails(url, body, Post)
  }
}

let useOffersUiConfig = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)

  async () => {
    let url = getURL(~entityName=V1(OFFERS), ~methodType=Get, ~offersType=#OFFER_UI_CONFIG)
    let response = await fetchDetails(url)
    response->getDictFromJsonObject
  }
}
