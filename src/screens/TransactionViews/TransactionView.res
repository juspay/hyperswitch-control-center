module TransactionViewCard = {
  @react.component
  let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
    open TransactionViewUtils

    let textClass = isActiveView ? "text-blue-500" : "font-semibold text-jp-gray-700"
    let countTextClass = isActiveView ? "text-blue-500" : "font-semibold text-jp-gray-900"
    let borderClass = isActiveView ? "border-blue-500" : ""

    <div
      className={`flex flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-2.5 w-14 my-8 cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <p className={textClass}> {view->getViewsDisplayName->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className={countTextClass}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~entity=TransactionViewTypes.Orders) => {
  open APIUtils
  open LogicUtils
  open TransactionViewUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let {updateExistingKeys, filterValueJson, filterKeys, setfilterKeys} =
    FilterContext.filterContext->React.useContext
  let (countRes, setCountRes) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (activeView: TransactionViewTypes.viewTypes, setActiveView) = React.useState(_ =>
    TransactionViewTypes.All
  )

  let customFilterKey = getCustomFilterKey(entity)

  let updateViewsFilterValue = (view: TransactionViewTypes.viewTypes) => {
    let customFilter = `[${view->getViewsString(countRes, entity)}]`
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
    filterValueJson->getString(OrderUIUtils.startTimeFilterKey, defaultDate.start_time)
  let endTime = filterValueJson->getString(OrderUIUtils.endTimeFilterKey, defaultDate.end_time)

  let getAggregate = async () => {
    try {
      let url = switch entity {
      | Orders =>
        getURL(
          ~entityName=ORDERS_AGGREGATE,
          ~methodType=Get,
          ~queryParamerters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
      | Refunds =>
        getURL(
          ~entityName=REFUNDS_AGGREGATE,
          ~methodType=Get,
          ~queryParamerters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
      | Disputes =>
        getURL(
          ~entityName=DISPUTES_AGGREGATE,
          ~methodType=Get,
          ~queryParamerters=Some(`start_time=${startTime}&end_time=${endTime}`),
        )
      }

      let response = await fetchDetails(url)
      setCountRes(_ => response)
    } catch {
    | _ => showToast(~toastType=ToastError, ~message="Failed to fetch views count", ~autoClose=true)
    }
  }

  let settingActiveView = () => {
    let appliedStatusFilter = filterValueJson->getArrayFromDict(customFilterKey, [])

    let setViewToAll =
      appliedStatusFilter->getStrArrayFromJsonArray->Array.toSorted(compareLogic) ==
        countRes
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
    } else if setViewToAll {
      setActiveView(_ => All)
    } else {
      setActiveView(_ => None)
    }
  }

  React.useEffect(() => {
    settingActiveView()
    None
  }, (filterValueJson, countRes))

  React.useEffect(() => {
    getAggregate()->ignore
    None
  }, (startTime, endTime))

  let viewsArray = switch entity {
  | Orders => paymentViewsArray
  | Refunds => refundViewsArray
  | Disputes => disputeViewsArray
  }

  viewsArray
  ->Array.mapWithIndex((item, i) =>
    <TransactionViewCard
      key={i->Int.toString}
      view={item}
      count={getViewCount(item, countRes, entity)->Int.toString}
      onViewClick
      isActiveView={item == activeView}
    />
  )
  ->React.array
}
