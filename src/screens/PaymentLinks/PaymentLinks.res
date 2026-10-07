open LogicUtils

@react.component
let make = () => {
  open APIUtils
  open HSwitchRemoteFilter
  open PaymentLinksUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (paymentLinksData, setPaymentLinksData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (filters, setFilters) = React.useState(_ => None)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Payment Links")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {orgId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let startTime = filterValueJson->getString("start_time", "")

  let handleExtendDateButtonClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let prevStartdate = startDateObj.toDate()->Date.toISOString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString

    updateExistingKeys(Dict.fromArray([("start_time", {extendedStartDate})]))
    updateExistingKeys(Dict.fromArray([("end_time", {prevStartdate})]))
  }

  let getPaymentLinksList = async (
    filterValueJson,
    ~updateDetails: (string, JSON.t, Fetch.requestMethod) => promise<JSON.t>,
    ~setPaymentLinksData,
    ~setScreenState,
    ~offset,
    ~setTotalCount,
    ~setOffset,
    ~getURL: APIUtilsTypes.getUrlTypes,
  ) => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let paymentLinksUrl = getURL(~entityName=V1(PAYMENT_LINKS), ~methodType=Post)
      let res = await updateDetails(paymentLinksUrl, filterValueJson->JSON.Encode.object, Post)
      let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
      let total = res->getDictFromJsonObject->getInt("total_count", 0)

      let arr = Array.make(~length=offset, Dict.make())
      if total <= offset {
        setOffset(_ => 0)
      }

      if total > 0 {
        let dataArr = data->Array.filterMap(JSON.Decode.object)
        let paymentLinksData =
          arr->Array.concat(dataArr)->Array.map(PaymentLinksEntity.itemToObjMapper)
        let list = paymentLinksData->Array.map(Nullable.make)
        setPaymentLinksData(_ => list)
        setTotalCount(_ => total)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => Custom)
      }
    } catch {
    | _ => setScreenState(_ => Error("Failed to fetch"))
    }
  }

  let fetchPaymentLinks = () => {
    switch filters {
    | Some(dict) =>
      let filters = Dict.make()
      filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
      filters->Dict.set("limit", 20->Int.toFloat->JSON.Encode.float)
      dict
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, value) = item
        filters->Dict.set(key, value)
      })

      filters
      ->getPaymentLinksList(
        ~updateDetails=(url, body, method) => updateDetails(url, body, method),
        ~setPaymentLinksData,
        ~setScreenState,
        ~offset,
        ~setOffset,
        ~setTotalCount,
        ~getURL,
      )
      ->ignore
    | _ => ()
    }
  }

  React.useEffect(() => {
    if filters->OrderUIUtils.isNonEmptyValue {
      fetchPaymentLinks()
    }
    None
  }, (offset, filters))

  <div className="min-h-50-vh">
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading title="Payment Link" subTitle="Create and manage payment links" />
      <CreatePaymentLinkModal
        refetchList={() =>
          updateExistingKeys(
            Dict.fromArray([(endTimeFilterKey, getDateFilteredObject().end_time)]),
          )}
      />
    </div>
    <div className="flex justify-between gap-3">
      <div className="flex-1">
        <RemoteTableFilters
          title="Payment Links"
          apiType=Post
          setFilters
          endTimeFilterKey
          startTimeFilterKey
          initialFilters={(_, _, _, _, _, _) => []}
          initialFixedFilter
          setOffset
          customLeftView=React.null
          entityName=V1(PAYMENT_LINKS)
        />
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        customCssClass="my-6"
        message="No results found"
        renderType=ExtendDateUI
        handleClick=handleExtendDateButtonClick
      />}>
      <LoadedTableWithCustomColumns
        hideTitle=true
        title="Payment Links"
        actualData=paymentLinksData
        entity={PaymentLinksEntity.paymentLinkEntity(orgId)}
        resultsPerPage=20
        showSerialNumber=true
        totalResults={totalCount}
        offset
        setOffset
        currentFetchCount={paymentLinksData->Array.length}
        onEntityClick={paymentLink =>
          GlobalVars.appendDashboardPath(
            ~url=`/payments/${paymentLink.payment_id}/${paymentLink.profile_id}/${paymentLink.merchant_id}/${orgId}`,
          )->Window._open}
        defaultColumns={PaymentLinksEntity.defaultColumns}
        customColumnMapper=TableAtoms.paymentLinksMapDefaultCols
        showSerialNumberInCustomizeColumns=false
        sortingBasedOnDisabled=false
        showAutoScroll=true
        isDraggable=true
        visitedRows={{
          getId: paymentLink => paymentLink.payment_id,
          prefix_key: "payment-link",
        }}
      />
    </PageLoaderWrapper>
  </div>
}
