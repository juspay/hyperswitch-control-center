@react.component
let make = (~previewOnly=false) => {
  open HSwitchRemoteFilter
  open OrderUIUtils
  open LogicUtils

  let fetchOrdersHook = OrdersHook.useFetchOrdersHook()
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {getCommonSessionDetails, getResolvedUserInfo, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {transactionEntity} = getResolvedUserInfo()
  let {merchantId, orgId, version} = getCommonSessionDetails()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let (sortAtomValue, setSortAtom) = Recoil.useRecoilState(LoadedTable.sortAtom)
  let (widthClass, heightClass) = React.useMemo(() => {
    previewOnly ? ("w-full", "max-h-96") : ("w-full", "")
  }, [previewOnly])
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let defaultSort: LoadedTable.sortOb = {
    sortKey: "",
    sortType: ASC,
  }
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {generateReport, email} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let startTime = filterValueJson->getString(startTimeFilterKey(version), "")

  let handleExtendDateButtonClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let prevStartdate = startDateObj.toDate()->Date.toISOString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString

    updateExistingKeys(Dict.fromArray([(startTimeFilterKey(version), {extendedStartDate})]))
    updateExistingKeys(Dict.fromArray([(endTimeFilterKey(version), {prevStartdate})]))
  }

  let getOrdersList = async filterValueJson => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let res = await fetchOrdersHook(~payload=filterValueJson->JSON.Encode.object, ~version)
      let data = res.data
      let total = res.total_count

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

          let res = await fetchOrdersHook(~payload=filterValueJson->JSON.Encode.object, ~version)
          let data = res.data
          let total = res.total_count

          setData(
            offset,
            setOffset,
            total,
            data,
            setTotalCount,
            setOrdersData,
            setScreenState,
            previewOnly,
          )
        } else {
          setScreenState(_ => PageLoaderWrapper.Custom)
        }
      } else {
        setData(
          offset,
          setOffset,
          total,
          data,
          setTotalCount,
          setOrdersData,
          setScreenState,
          previewOnly,
        )
      }
    } catch {
    | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  let fetchOrders = () => {
    if !previewOnly {
      switch filters {
      | Some(dict) =>
        let filters = Dict.make()

        filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
        filters->Dict.set("limit", 50->Int.toFloat->JSON.Encode.float)
        if !(searchText->isEmptyString) {
          filters->Dict.set("payment_id", searchText->String.trim->JSON.Encode.string)
        }

        let sortObj = sortAtomValue->Dict.get("Orders")->Option.getOr(defaultSort)
        if sortObj.sortKey->isNonEmptyString {
          filters->Dict.set(
            "order",
            [
              ("on", sortObj.sortKey->JSON.Encode.string),
              ("by", sortObj->OrderTypes.getSortString->JSON.Encode.string),
            ]->getJsonFromArrayOfJson,
          )
        }
        //to create amount_filter query
        let newDict = AmountFilterUtils.createAmountQuery(~dict)
        newDict
        ->Dict.toArray
        ->Array.forEach(item => {
          let (key, value) = item
          filters->Dict.set(key, value)
        })
        //to delete unused keys
        filters->deleteNestedKeys(["start_amount", "end_amount", "amount_option"])
        
        filters
        ->getOrdersList
        ->ignore

      | _ => ()
      }
    } else {
      let filters = Dict.make()

      filters
      ->getOrdersList
      ->ignore
    }
  }

  React.useEffect(() => {
    if filters->isNonEmptyValue {
      fetchOrders()
    }

    None
  }, (offset, filters, searchText))

  React.useEffect(() => {
    Some(() => setSortAtom(_ => [("Orders", defaultSort)]->Dict.fromArray))
  }, [])

  let customTitleStyle = previewOnly ? "py-0 !pt-0" : ""

  let customUI =
    <NoDataFound
      customCssClass="my-6"
      message="No results found"
      renderType=ExtendDateUI
      handleClick=handleExtendDateButtonClick
    />

  let filtersUI = React.useMemo(() => {
    <RemoteTableFilters
      title="Orders"
      setFilters
      endTimeFilterKey={endTimeFilterKey(version)}
      startTimeFilterKey={startTimeFilterKey(version)}
      initialFilters
      initialFixedFilter
      setOffset
      submitInputOnEnter=true
      customLeftView={<SearchBarFilter
        placeholder="Search for payment ID" setSearchVal=setSearchText searchVal=searchText
      />}
      entityName={switch version {
      | V1 => V1(ORDER_FILTERS)
      | V2 => V2(V2_ORDER_FILTERS)
      }}
      version
    />
  }, [searchText])

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="Payment Operations" subTitle="" customTitleStyle />
        <div className="flex gap-4">
          <Portal to="OrdersOMPView">
            <OMPSwitchHelper.OMPViews
              views={OMPSwitchUtils.transactionViewList(~checkUserEntity)}
              selectedEntity={transactionEntity}
              onChange={updateTransactionEntity}
              entityMapper=UserInfoUtils.transactionEntityMapper
            />
          </Portal>
          <RenderIf
            condition={generateReport && email && orderData->Array.length > 0 && version == V1}>
            <GenerateReport entityName={V1(PAYMENT_REPORT)} />
          </RenderIf>
        </div>
      </div>
      <div className="grid lg:grid-cols-5 md:grid-cols-4 sm:grid-cols-3 grid-cols-2 gap-6 my-8">
        <TransactionView entity=TransactionViewTypes.Orders version />
      </div>
      <div className="flex">
        <RenderIf condition={!previewOnly}>
          <div className="flex-1"> {filtersUI} </div>
        </RenderIf>
      </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Orders"
          actualData=orderData
          entity={OrderEntity.orderEntity(merchantId, orgId, ~version)}
          resultsPerPage=20
          showSerialNumber=true
          totalResults={previewOnly ? orderData->Array.length : totalCount}
          offset
          setOffset
          currrentFetchCount={orderData->Array.length}
          customColumnMapper=TableAtoms.ordersMapDefaultCols
          defaultColumns={OrderEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          previewOnly
          remoteSortEnabled=true
          showAutoScroll=true
          isDraggable=true
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
