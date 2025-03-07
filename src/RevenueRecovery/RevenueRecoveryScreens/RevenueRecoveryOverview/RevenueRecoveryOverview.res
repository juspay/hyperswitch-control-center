@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open HSwitchRemoteFilter
  open RevenueRecoveryOrderUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {userInfo: {merchantId, orgId}} = React.useContext(UserInfoProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("recovery-orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (filters, setFilters) = React.useState(_ => None)
  let (searchText, setSearchText) = React.useState(_ => "")
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let startTime = filterValueJson->getString("created.gte", "")
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ => [])

  let handleExtendDateButtonClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let prevStartdate = startDateObj.toDate()->Date.toISOString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString

    updateExistingKeys(Dict.fromArray([("created.gte", {extendedStartDate})]))
    updateExistingKeys(Dict.fromArray([("created.lte", {prevStartdate})]))
  }

  let fetchOrders = () => {
    let query = switch filters {
    | Some(dict) =>
      let filters = Dict.make()

      filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
      filters->Dict.set("limit", 50->Int.toFloat->JSON.Encode.float)
      if !(searchText->isEmptyString) {
        filters->Dict.set("payment_id", searchText->String.trim->JSON.Encode.string)
      }

      //to create amount_filter query
      let newDict = AmountFilterUtils.createAmountQuery(~dict)
      newDict
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, value) = item
        filters->Dict.set(key, value)
      })
      // TODO: enable amount filter later
      filters->Dict.delete("amount_filter")

      filters
    | _ => Dict.make()
    }

    query
    ->getPaymentsList(
      ~fetchDetails,
      ~getURL,
      ~setOrdersData=setRevenueRecoveryData,
      ~setScreenState,
      ~setOffset,
      ~setTotalCount,
      ~offset,
    )
    ->ignore
  }

  React.useEffect(() => {
    if filters->OrderUIUtils.isNonEmptyValue {
      fetchOrders()
    }

    None
  }, (offset, filters, searchText))

  let customTitleStyle = "py-0 !pt-0"

  let customUI =
    <NoDataFound
      customCssClass="my-6"
      message="No results found"
      renderType=ExtendDateUI
      handleClick=handleExtendDateButtonClick
    />

  let (widthClass, heightClass) = ("w-full", "")

  let filtersUI = React.useMemo(() => {
    <RemoteTableFilters
      title="Orders"
      setFilters
      endTimeFilterKey
      startTimeFilterKey
      initialFilters
      initialFixedFilter
      setOffset
      submitInputOnEnter=true
      customLeftView={<SearchBarFilter
        placeholder="Search for payment ID" setSearchVal=setSearchText searchVal=searchText
      />}
      entityName=V1(ORDER_FILTERS) // TODO: route needed to be changed
    />
  }, [searchText])

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="Recovery Overview" subTitle="" customTitleStyle />
        <Button
          text="View Chargebee"
          buttonType={Secondary}
          onClick={_ =>
            RescriptReactRouter.replace(
              GlobalVars.appendDashboardPath(
                ~url=`/v2/recovery/summary/mca_f2dBJYU5uo0bWM7vGfWk?name=adyen`,
              ),
            )}
          buttonSize={Small}
          customButtonStyle="w-fit"
        />
      </div>
      <div className="flex"> {filtersUI} </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Recovery"
          actualData=revenueRecoveryData
          entity={RevenueRecoveryEntity.revenueRecoveryEntity(merchantId, orgId)}
          resultsPerPage=20
          showSerialNumber=true
          totalResults={totalCount}
          offset
          setOffset
          currrentFetchCount={revenueRecoveryData->Array.length}
          customColumnMapper=TableAtoms.revenueRecoveryMapDefaultCols
          defaultColumns={RevenueRecoveryEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          remoteSortEnabled=true
          showAutoScroll=true
          hideCustomisableColumnButton=true
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
