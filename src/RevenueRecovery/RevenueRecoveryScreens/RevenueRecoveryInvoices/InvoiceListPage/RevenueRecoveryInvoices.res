@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open Typography
  open HSwitchRemoteFilter
  open InvoiceListPageUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {merchantId, orgId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("recovery_orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ => [])
  let (filters, setFilters) = React.useState(_ => None)
  let {filterValue} = React.useContext(FilterContext.filterContext)

  let setData = (total, data) => {
    let arr = Array.make(~length=offset, Dict.make()->RevenueRecoveryEntity.itemToObjMapper)
    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let orderData = arr->Array.concat(data)
      let list = orderData->Array.map(Nullable.make)
      setTotalCount(_ => total)
      setRevenueRecoveryData(_ => list)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  let getPaymentsList = async (query: RescriptCore.Dict.t<Core__JSON.t>) => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let filter =
        query
        ->Dict.toArray
        ->Array.map(item => {
          let (key, value) = item

          let value = switch value->JSON.Classify.classify {
          | String(str) => str
          | Number(num) => num->Float.toString
          | _ => ""
          }

          (key, value)
        })
        ->Dict.fromArray

      let url = getURL(
        ~entityName=V2(V2_RECOVERY_INVOICES_LIST),
        ~methodType=Get,
        ~queryParameters=Some(filter->FilterUtils.parseFilterDict),
      )
      let res = await fetchDetails(url, ~version=V2)

      let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
      let total = res->getDictFromJsonObject->getInt("total_count", 0)

      let orderDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let orderData = orderDataDictArr->Array.map(RevenueRecoveryEntity.itemToObjMapper)
      setData(total, orderData)
    } catch {
    | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  let fetchOrders = () => {
    Js.log2(">>", "fetch")
    let query = switch filters {
    | Some(dict) =>
      let filters = Dict.make()

      filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
      filters->Dict.set("limit", 50->Int.toFloat->JSON.Encode.float)
      if !(searchText->isEmptyString) {
        filters->Dict.set("payment_id", searchText->String.trim->JSON.Encode.string)
      }

      dict
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, value) = item
        filters->Dict.set(key, value)
      })

      filters
    | _ => {
        let filters = Dict.make()
        filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        filters->Dict.set("limit", 50->Int.toFloat->JSON.Encode.float)
        filters
      }
    }

    query
    ->getPaymentsList
    ->ignore
  }

  React.useEffect(() => {
    if filters->OrderUIUtils.isNonEmptyValue {
      fetchOrders()
    }

    None
  }, (offset, filters, searchText))

  let filtersUI = React.useMemo(() => {
    <RemoteTableFilters
      title="Recovery"
      setFilters
      endTimeFilterKey={endTimeFilterKey}
      startTimeFilterKey={startTimeFilterKey}
      initialFilters
      initialFixedFilter
      setOffset
      submitInputOnEnter=true
      customLeftView={<SearchBarFilter
        placeholder="Search for Invoice ID" setSearchVal=setSearchText searchVal=searchText
      />}
      entityName={V2(V2_ORDER_FILTERS)}
      version=V2
    />
  }, [searchText])

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full w-full min-h-[50vh]`}>
      <div className="flex justify-between items-center mb-5">
        <PageUtils.PageHeading
          title="Invoice Recovery Overview" customTitleStyle="py-0 !pt-0 !text-fs-24"
        />
      </div>
      <RevenueRecoveryInvoiceMetrics />
      <div className="space-y-1 mb-2 mt-10 mb-3">
        <h2 className={`${heading.sm.semibold} text-gray-900`}>
          {"List of Invoices"->React.string}
        </h2>
      </div>
      <div className="flex">
        <div className="flex-1"> {filtersUI} </div>
      </div>
      <PageLoaderWrapper screenState>
        <LoadedTableWithCustomColumns
          title="Recovery"
          actualData=revenueRecoveryData
          entity={RevenueRecoveryEntity.revenueRecoveryEntity(merchantId, orgId, profileId)}
          resultsPerPage=10
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
