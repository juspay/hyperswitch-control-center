@react.component
let make = (~previewOnly=false) => {
  open APIUtils
  open HSwitchRemoteFilter
  open OrderUIUtils
  open LogicUtils
  open ViewUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (orderData, setOrdersData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (filters, setFilters) = React.useState(_ => None)
  let (paymentCountRes, setPaymentCountRes) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (activeView: ViewTypes.viewTypes, setActiveView) = React.useState(_ => ViewTypes.All)

  let {updateExistingKeys, filterValueJson, filterKeys, setfilterKeys} =
    FilterContext.filterContext->React.useContext

  let (widthClass, heightClass) = React.useMemo(() => {
    previewOnly ? ("w-full", "max-h-96") : ("w-full", "")
  }, [previewOnly])

  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get("Orders")->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

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

        dict
        ->Dict.toArray
        ->Array.forEach(item => {
          let (key, value) = item
          filters->Dict.set(key, value)
        })
        filters
        ->getOrdersList(
          ~updateDetails,
          ~setOrdersData,
          ~previewOnly,
          ~setScreenState,
          ~setOffset,
          ~setTotalCount,
          ~offset,
          ~getURL,
        )
        ->ignore

      | _ => ()
      }
    } else {
      let filters = Dict.make()

      filters
      ->getOrdersList(
        ~updateDetails,
        ~setOrdersData,
        ~previewOnly,
        ~setScreenState,
        ~setOffset,
        ~setTotalCount,
        ~offset,
        ~getURL,
      )
      ->ignore
    }
  }

  let updateViewsFilterValue = (view: ViewTypes.viewTypes) => {
    let customFilterKey = "status"
    let customFilter = `[${view->getViewsString(paymentCountRes)}]`

    updateExistingKeys(Dict.fromArray([(customFilterKey, customFilter)]))

    switch view {
    | All => {
        let updateFilterKeys = filterKeys->Array.filter(item => item != "status")
        setfilterKeys(_ => updateFilterKeys)
      }
    | _ => {
        if !(filterKeys->Array.includes("status")) {
          filterKeys->Array.push("status")
        }
        setfilterKeys(_ => filterKeys)
      }
    }
  }

  let onViewClick = (view: ViewTypes.viewTypes) => {
    setActiveView(_ => view)
    updateViewsFilterValue(view)
  }

  let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
  let startTime = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
  let endTime = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

  let getAggregate = async () => {
    try {
      let url = getURL(
        ~entityName=ORDERS_AGGREGATE,
        ~methodType=Get,
        ~queryParamerters=Some(`start_time=${startTime}&end_time=${endTime}`),
      )
      let response = await fetchDetails(url)
      setPaymentCountRes(_ => response)
    } catch {
    | _ => showToast(~toastType=ToastError, ~message="Failed to fetch views count", ~autoClose=true)
    }
  }

  let setActiveViewOnLoad = () => {
    let appliedStatusFilter =
      filterValueJson->JSON.Encode.object->getDictFromJsonObject->getArrayFromDict("status", [])

    if appliedStatusFilter->Array.length == 1 {
      let statusValue =
        appliedStatusFilter->getValueFromArray(0, ""->JSON.Encode.string)->JSON.Decode.string

      let status = statusValue->Option.getOr("")
      setActiveView(_ => status->getViewTypeFromString)
    } else {
      setActiveView(_ => All)
    }
  }

  React.useEffect(() => {
    if filters->isNonEmptyValue {
      fetchOrders()
    }
    setActiveViewOnLoad()
    None
  }, (offset, filters, searchText))

  React.useEffect(() => {
    getAggregate()->ignore
    None
  }, (startTime, endTime))

  let customTitleStyle = previewOnly ? "py-0 !pt-0" : ""

  let customUI =
    <NoDataFound
      customCssClass={"my-6"} message="There are no payments as of now" renderType=Painting
    />

  let filterUrl = getURL(~entityName=ORDERS, ~methodType=Get, ~id=Some("v2/filter"))

  let filtersUI = React.useMemo(() => {
    <RemoteTableFilters
      filterUrl
      setFilters
      endTimeFilterKey
      startTimeFilterKey
      initialFilters
      initialFixedFilter
      setOffset
      customLeftView={<SearchBarFilter
        placeholder="Search payment id" setSearchVal=setSearchText searchVal=searchText
      />}
    />
  }, [])

  let viewsUI =
    paymentViewsArray->Array.mapWithIndex((item, i) =>
      <ViewHelpers.ViewCards
        key={i->Int.toString}
        view={item}
        count={paymentCount(item, paymentCountRes)->Int.toString}
        onViewClick
        isActiveView={item == activeView}
      />
    )

  <ErrorBoundary>
    <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
      <div className="flex justify-between items-center">
        <PageUtils.PageHeading title="Payment Operations" subTitle="" customTitleStyle />
        <RenderIf condition={generateReport && orderData->Array.length > 0}>
          <GenerateReport entityName={PAYMENT_REPORT} />
        </RenderIf>
      </div>
      <div className="flex gap-6 justify-around"> {viewsUI->React.array} </div>
      <div className="flex">
        <RenderIf condition={!previewOnly}>
          <div className="flex-1"> {filtersUI} </div>
        </RenderIf>
      </div>
      <PageLoaderWrapper screenState customUI>
        <LoadedTableWithCustomColumns
          title="Orders"
          actualData=orderData
          entity={OrderEntity.orderEntity}
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
        />
      </PageLoaderWrapper>
    </div>
  </ErrorBoundary>
}
