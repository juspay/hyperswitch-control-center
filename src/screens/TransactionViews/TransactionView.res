module TransactionViewCard = {
  @react.component
  let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
    open TransactionViewUtils

    let textClass = isActiveView ? "text-primary" : "font-semibold text-jp-gray-700"
    let countTextClass = isActiveView ? "text-primary" : "font-semibold text-jp-gray-900"
    let borderClass = isActiveView ? "border-primary" : ""

    <div
      className={`flex flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-2.5 cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <p className={textClass}> {view->getViewsDisplayName->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className={countTextClass}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~entity=TransactionViewTypes.Orders, ~version: UserInfoTypes.version=V1) => {
  open APIUtils
  open APIUtilsTypes
  open LogicUtils
  open TransactionViewUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let {updateExistingKeys, filterValueJson, filterKeys, setfilterKeys} =
    FilterContext.filterContext->React.useContext
  let {devClickhouseAggregate} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
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
      setfilterKeys(prev => prev->Array.concat([customFilterKey]))
    }
  }

  let onViewClick = (view: TransactionViewTypes.viewTypes) => {
    setActiveView(_ => view)
    updateViewsFilterValue(view)
  }

  let (startTime, endTime) = React.useMemo(() => {
    getStartAndEndTime(filterValueJson, version)
  }, (filterValueJson, version))

  let loadAggregateCounts = async () => {
    try {
      switch (devClickhouseAggregate, getClickhouseAggregateMetric(entity)) {
      | (true, Some(metricConfig)) =>
        let url = getURL(
          ~entityName=metricConfig.entityName,
          ~methodType=Post,
          ~id=Some(metricConfig.domain),
        )
        let body = buildAggregateMetricsBody(
          ~startTime,
          ~endTime,
          ~metric=metricConfig.metric,
          ~groupByField=metricConfig.groupByField,
        )
        let response = await updateDetails(url, body, Post)
        setAggregateResponse(_ =>
          response->metricsResponseToStatusWithCount(
            ~statusField=metricConfig.statusField,
            ~countField=metricConfig.countField,
          )
        )
      | _ =>
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
      }
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
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      loadAggregateCounts()->ignore
    }
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
