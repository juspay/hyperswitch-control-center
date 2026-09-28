open OffersHooks
open OffersUtils
open ShowOfferHelper

@react.component
let make = (~id) => {
  let fetchOfferDetail = useOfferDetail()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offerDetail, setOfferDetail) = React.useState(_ => None)

  let hasManageAccess = userHasAccess(~groupAccess=OffersManage) === Access

  let getOffer = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let response = await fetchOfferDetail(id)
      setOfferDetail(_ => response)
      setScreenState(_ =>
        response->Option.isSome ? PageLoaderWrapper.Success : PageLoaderWrapper.Custom
      )
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to fetch the offer")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    getOffer()->ignore
    None
  }, [id])

  let goToOffersList = () =>
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/offers"))

  let customUI = <NoDataFound message="Offer not found" renderType={Painting} />

  <PageLoaderWrapper screenState customUI>
    {switch offerDetail {
    | Some(detail) =>
      <div className="flex flex-col gap-6">
        <div className="flex justify-between items-start">
          <div className="flex flex-col gap-2">
            <PageUtils.PageHeading title="Offers" />
            <div className="flex items-center gap-3">
              <BreadCrumbNavigation
                path=[{title: "Offers", link: "/offers"}] currentPageTitle=detail.offer.offerCode
              />
              <TableUtils.LabelCell
                labelColor={detail.offer.status->statusToLabelColor}
                text={detail.offer.status->statusToDisplayName->String.toUpperCase}
              />
            </div>
          </div>
          <RenderIf condition=hasManageAccess>
            <OfferRowActions
              offer=detail.offer onStatusToggled={() => getOffer()->ignore} onDeleted=goToOffersList
            />
          </RenderIf>
        </div>
        <OfferInfoSection
          title="Offer Details"
          data=detail
          getHeading=OffersEntity.getOfferDetailsHeading
          getCell=OffersEntity.getOfferDetailsCell
          detailsFields=OffersEntity.offerDetailsFields
        />
        <OfferInfoSection
          title="Payment Details"
          data=detail
          getHeading=OffersEntity.getPaymentDetailsHeading
          getCell=OffersEntity.getPaymentDetailsCell
          detailsFields=OffersEntity.paymentDetailsFields
        />
      </div>
    | None => React.null
    }}
  </PageLoaderWrapper>
}
