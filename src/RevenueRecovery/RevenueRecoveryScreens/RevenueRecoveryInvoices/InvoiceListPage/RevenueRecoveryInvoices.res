@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open RevenueRecoveryOrderUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {userInfo: {merchantId, orgId, profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 10}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("recovery_orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let (filters, _setFilters) = React.useState(_ => None)
  let (searchText, _setSearchText) = React.useState(_ => "")
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ => [])

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
        ~entityName=V2(V2_ORDERS_LIST),
        ~methodType=Get,
        ~queryParamerters=Some(filter->FilterUtils.parseFilterDict),
      )
      let res = await fetchDetails(url, ~version=V2)

      let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
      let total = res->getDictFromJsonObject->getInt("total_count", 0)

      let orderDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let orderData = orderDataDictArr->Array.map(RevenueRecoveryEntity.itemToObjMapper)

      // Process failed payments to get additional information from process tracker
      let processedOrderData = await Promise.all(
        orderData->Array.map(async order => {
          // TODO: change this later // order.status->RevenueRecoveryOrderUtils.statusVariantMapper == Failed
          if false {
            try {
              let processTrackerUrl = getURL(
                ~entityName=V2(PROCESS_TRACKER),
                ~methodType=Get,
                ~id=Some(order.id),
              )
              let processTrackerData = await fetchDetails(processTrackerUrl, ~version=V2)

              let processTrackerDataDict = processTrackerData->getDictFromJsonObject

              let status = processTrackerDataDict->getString("status", "")

              // If we get a response, modify the payment object
              if (
                processTrackerDataDict->Dict.keysToArray->Array.length > 0 &&
                  status != Finish->schedulerStatusStringMapper
              ) {
                // Create a modified order object with additional process tracker data
                {
                  ...order,
                  status: Scheduled->schedulerStatusStringMapper,
                }
              } else {
                // Keep the order as-is if no response
                order
              }
            } catch {
            | Exn.Error(_) => // Keep the order as-is if there's an error
              order
            }
          } else {
            // Keep non-failed orders as-is
            order
          }
        }),
      )

      setData(total, processedOrderData)
    } catch {
    | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
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
    // TODO: filters will be enabled later
    // if filters->OrderUIUtils.isNonEmptyValue {
    //   fetchOrders()
    // }
    fetchOrders()

    None
  }, (offset, filters, searchText))

  let customTitleStyle = "py-0 !pt-0"

  let (widthClass, heightClass) = ("w-full", "")

  // TODO: filters will be enabled later
  // let filtersUI = React.useMemo(() => {
  //   <RemoteTableFilters
  //     title="Orders"
  //     setFilters
  //     endTimeFilterKey
  //     startTimeFilterKey
  //     initialFilters
  //     initialFixedFilter
  //     setOffset
  //     submitInputOnEnter=true
  //     customLeftView={<SearchBarFilter
  //       placeholder="Search for payment ID" setSearchVal=setSearchText searchVal=searchText
  //     />}
  //     entityName=V2(V2_ORDER_FILTERS)
  //     version=V2
  //   />
  // }, [searchText])

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="List of Invoices" customTitleStyle />
      </div>
      //<div className="flex"> {filtersUI} </div>
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
