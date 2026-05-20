module TransactionViewCard = {
  open Typography
  @react.component
  let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
    open TransactionViewUtils

    let labelColor = isActiveView ? "text-nd_primary_blue-500" : "text-nd_gray-400"
    let countColor = isActiveView ? "text-nd_primary_blue-500" : "text-nd_gray-800"
    let borderClass = isActiveView ? "border-nd_primary_blue-500" : ""

    <div
      className={`flex flex-col justify-center flex-auto gap-spacing-xs bg-white border rounded-md px-spacing-xl py-spacing-md cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <p className={`${body.md.medium} ${labelColor}`}>
        {view->getViewsDisplayName->React.string}
      </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className={`${heading.lg.semibold} ${countColor}`}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~entity=TransactionViewTypes.Orders, ~version: UserInfoTypes.version=V1) => {
  open APIUtils
  open LogicUtils
  open TransactionViewUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let {updateExistingKeys, filterValueJson, filterKeys, setfilterKeys} =
    FilterContext.filterContext->React.useContext
  let (aggregateResponse, setAggregateResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let (activeView: TransactionViewTypes.viewTypes, setActiveView) = React.useState(_ =>
    TransactionViewTypes.All
  )

  let customFilterKey = getCustomFilterKey(entity)

  let updateViewsFilterValue = (view: TransactionViewTypes.viewTypes) => {
    let customFilter = `[${view->getViewFilterValue(aggregateResponse, entity)}]`
    updateExistingKeys(Dict.fromArray([(customFilterKey, customFilter)]))

    if !(filterKeys->Array.includes(customFilterKey)) {
      filterKeys->Array.push(customFilterKey)
      setfilterKeys(_ => filterKeys)
    }
  }

  let onViewClick = (view: TransactionViewTypes.viewTypes) => {
    setActiveView(_ => view)
    updateViewsFilterValue(view)
  }

  let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
  let startTime =
    filterValueJson->getString(OrderUIUtils.startTimeFilterKey(version), defaultDate.start_time)
  let endTime =
    filterValueJson->getString(OrderUIUtils.endTimeFilterKey(version), defaultDate.end_time)

  let loadAggregateCounts = async () => {
    try {
      let url = switch entity {
      | Orders =>
        getURL(
          ~entityName={
            switch version {
            | V1 => V1(ORDERS_AGGREGATE)
            | V2 => V2(V2_ORDERS_AGGREGATE)
            }
          },
          ~methodType=Get,
          ~queryParameters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
      | Refunds =>
        getURL(
          ~entityName=V1(REFUNDS_AGGREGATE),
          ~methodType=Get,
          ~queryParameters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
      | Disputes =>
        getURL(
          ~entityName=V1(DISPUTES_AGGREGATE),
          ~methodType=Get,
          ~queryParameters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
      | Payouts =>
        getURL(
          ~entityName=V1(PAYOUTS_AGGREGATE),
          ~methodType=Get,
          ~queryParameters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
      }

      let response = await fetchDetails(url)
      setAggregateResponse(_ => response)
    } catch {
    | _ => showToast(~toastType=ToastError, ~message="Failed to fetch views count", ~autoClose=true)
    }
  }

  let syncActiveViewFromFilter = () => {
    let appliedStatusFilter = filterValueJson->getArrayFromDict(customFilterKey, [])

    let isAllViewSelected =
      appliedStatusFilter->getStrArrayFromJsonArray->Array.toSorted(compareLogic) ==
        aggregateResponse
        ->getDictFromJsonObject
        ->getDictfromDict("status_with_count")
        ->Dict.keysToArray
        ->Array.toSorted(compareLogic)

    if appliedStatusFilter->Array.length == 1 {
      let status =
        appliedStatusFilter
        ->getValueFromArray(0, ""->JSON.Encode.string)
        ->JSON.Decode.string
        ->Option.getOr("")

      let viewType = status->getViewTypeFromString(entity)
      switch viewType {
      | All => setActiveView(_ => None)
      | _ => setActiveView(_ => viewType)
      }
    } else if isAllViewSelected {
      setActiveView(_ => All)
    } else {
      setActiveView(_ => None)
    }
  }

  React.useEffect(() => {
    syncActiveViewFromFilter()
    None
  }, (filterValueJson, aggregateResponse))

  React.useEffect(() => {
    loadAggregateCounts()->ignore
    None
  }, (startTime, endTime))

  let viewsArray = switch entity {
  | Orders => paymentViewsArray
  | Refunds => refundViewsArray
  | Disputes => disputeViewsArray
  | Payouts => payoutViewsArray
  }

  viewsArray
  ->Array.mapWithIndex((item, i) =>
    <TransactionViewCard
      key={i->Int.toString}
      view={item}
      count={getViewCount(item, aggregateResponse, entity)->Int.toString}
      onViewClick
      isActiveView={item == activeView}
    />
  )
  ->React.array
}
