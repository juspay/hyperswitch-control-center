@react.component
let make = () => {
  open LogicUtils
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
    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let orderDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)

      let orderData = orderDataDictArr->Array.map(RevenueRecoveryEntity.itemToObjMapper)

      let list = orderData->Array.map(Nullable.make)
      setTotalCount(_ => total)
      setRevenueRecoveryData(_ => list)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  let getPaymentsList = async (filterValueJson: RescriptCore.Dict.t<Core__JSON.t>) => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let res = RevenueRecoveryData.orderData

      let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
      let total = res->getDictFromJsonObject->getInt("total_count", 0)

      if data->Array.length === 0 && filterValueJson->Dict.get("payment_id")->Option.isSome {
        let payment_id =
          filterValueJson
          ->Dict.get("payment_id")
          ->Option.getOr(""->JSON.Encode.string)
          ->JSON.Decode.string
          ->Option.getOr("")

        if RegExp.test(%re(`/^[A-Za-z0-9]+_[A-Za-z0-9]+_[0-9]+/`), payment_id) {
          let newID = payment_id->String.replaceRegExp(%re("/_[0-9]$/g"), "")
          filterValueJson->Dict.set("payment_id", newID->JSON.Encode.string)

          //let res = await fetchDetails(ordersUrl, ~version=V2)
          let res = RevenueRecoveryData.orderData

          let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
          let total = res->getDictFromJsonObject->getInt("total_count", 0)

          setData(total, data)
        } else {
          setScreenState(_ => PageLoaderWrapper.Success)
        }
      } else {
        setData(total, data)
      }
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
    | _ => Dict.make()
    }

    query
    ->getPaymentsList
    ->ignore
  }

  React.useEffect(() => {
    // if filters->OrderUIUtils.isNonEmptyValue {
    //   fetchOrders()
    // }
    fetchOrders()

    None
  }, (offset, filters, searchText))

  let customTitleStyle = "py-0 !pt-0"

  // let customUI =
  //   <NoDataFound
  //     customCssClass="my-6" message="Recovery details will appear soon" renderType={ExtendDateUI}
  //   />

  let (widthClass, heightClass) = ("w-full", "")

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
        <PageUtils.PageHeading
          title="Revenue Recovery Payments"
          subTitle="List of failed Invoices picked up for retry"
          customTitleStyle
        />
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
