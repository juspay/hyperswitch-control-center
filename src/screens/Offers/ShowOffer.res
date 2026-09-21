open OffersHooks
open OffersUtils
open Typography

module DisplayKeyValueParams = {
  @react.component
  let make = (~heading: Table.header, ~value: Table.cell) => {
    <AddDataAttributes attributes=[("data-label", heading.title)]>
      <div className="flex flex-col gap-2 py-4">
        <div className={`text-nd_gray-500 ${body.md.medium}`}> {heading.title->React.string} </div>
        <div className={`text-left text-nd_gray-600 ${body.md.semibold}`}>
          <Table.TableCell cell=value textAlign=Table.Left fontBold=true labelMargin="!py-0" />
        </div>
      </div>
    </AddDataAttributes>
  }
}

module DetailsSection = {
  @react.component
  let make = (~title, ~data, ~getHeading, ~getCell, ~detailsFields) => {
    <div className="flex flex-col gap-4">
      <div className={`${heading.sm.semibold} text-nd_gray-700`}> {title->React.string} </div>
      <div className="flex flex-wrap border border-nd_gray-150 bg-white rounded-xl p-5">
        {detailsFields
        ->Array.mapWithIndex((colType, index) =>
          <div className="w-full md:w-1/2 lg:w-1/3" key={index->Int.toString}>
            <DisplayKeyValueParams heading={getHeading(colType)} value={getCell(data, colType)} />
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~id) => {
  let fetchOfferDetail = useOfferDetail()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offerDetail, setOfferDetail) = React.useState(_ => None)
  let (refetchCounter, setRefetchCounter) = React.useState(_ => 0)

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
  }, (id, refetchCounter))

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
              offer=detail.offer
              onStatusToggled={() => setRefetchCounter(prev => prev + 1)}
              onDeleted=goToOffersList
            />
          </RenderIf>
        </div>
        <DetailsSection
          title="Offer Details"
          data=detail
          getHeading=OffersEntity.getOfferDetailsHeading
          getCell=OffersEntity.getOfferDetailsCell
          detailsFields=OffersEntity.offerDetailsFields
        />
        <DetailsSection
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
