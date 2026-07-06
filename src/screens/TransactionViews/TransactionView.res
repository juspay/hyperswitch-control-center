module TransactionViewCard = {
  @react.component
  let make = (
    ~view,
    ~count="",
    ~onViewClick,
    ~isActiveView,
    ~isNewCard=false,
    ~newCardDescription="",
  ) => {
    open TransactionViewUtils

    let textClass = isActiveView ? "text-primary" : "font-semibold text-jp-gray-700"
    let countTextClass = isActiveView ? "text-primary" : "font-semibold text-jp-gray-900"
    let borderClass = isActiveView ? "border-primary" : ""

    <div
      className={`relative flex min-w-0 flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-2.5 cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <RenderIf condition=isNewCard>
        <div className="absolute right-2 top-2">
          <NewFeatureTag description=newCardDescription />
        </div>
      </RenderIf>
      <p className={`${textClass} truncate ${isNewCard ? "pr-9" : ""}`}>
        {view->getViewsDisplayName->React.string}
      </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className={countTextClass}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

let getTransactionViewGridClass = viewsCount =>
  viewsCount >= 6
    ? "grid lg:grid-cols-6 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6"
    : "grid lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6"

@react.component
let make = (
  ~entity=TransactionViewTypes.Orders,
  ~version: UserInfoTypes.version=V1,
  ~isAdvancedView=false,
  ~containerClassName="mb-8",
) => {
  open APIUtils
  open APIUtilsTypes
  open LogicUtils
  open TransactionViewUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()
  let {getResolvedUserInfo} = React.useContext(UserInfoProvider.defaultContext)
  let {transactionEntity} = getResolvedUserInfo()
  let {updateExistingKeys, removeKeys, filterValueJson, setfilterKeys} =
    FilterContext.filterContext->React.useContext
  let {devClickhouseAggregate} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (aggregateResponse, setAggregateResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let (activeView: TransactionViewTypes.viewTypes, setActiveView) = React.useState(_ =>
    TransactionViewTypes.All
  )
  let lastAggregateRequestKey = React.useRef("")

  let customFilterKey = getCustomFilterKey(entity)
  let isAdvancedOrdersView = isAdvancedView && entity == Orders

  let updateViewsFilterValue = (view: TransactionViewTypes.viewTypes) => {
    let customFilter = `[${view->getViewFilterValue(aggregateResponse, entity)}]`
    let filterKey = isAdvancedOrdersView
      ? view->getAdvancedPaymentFilterKeyForView(~defaultFilterKey=customFilterKey)
      : customFilterKey
    let hiddenFilterEntry = isAdvancedOrdersView
      ? view->getAdvancedPaymentHiddenFilterEntryForView
      : None
    let filterEntries = switch hiddenFilterEntry {
    | Some(entry) => [(filterKey, customFilter), entry]
    | None => [(filterKey, customFilter)]
    }
    let filterEntryKeys = filterEntries->Array.map(((key, _)) => key)
    let removedFilterKeys = isAdvancedOrdersView ? view->getAdvancedPaymentFilterKeysToRemove : []

    if removedFilterKeys->isNonEmptyArray {
      removeKeys(removedFilterKeys)
    }

    updateExistingKeys(Dict.fromArray(filterEntries))
    setfilterKeys(prev => {
      let cleanedKeys =
        removedFilterKeys->isNonEmptyArray
          ? prev->Array.filter(key => !(removedFilterKeys->Array.includes(key)))
          : prev
      cleanedKeys->Array.concat(filterEntryKeys)->getUniqueArray
    })
  }

  let onViewClick = (view: TransactionViewTypes.viewTypes) => {
    setActiveView(_ => view)
    updateViewsFilterValue(view)
  }

  let (startTime, endTime) = React.useMemo(() => {
    getStartAndEndTime(filterValueJson, version)
  }, (filterValueJson, version))
  let aggregateRequestKey = React.useMemo(() => {
    [
      entity->getTransactionViewEntityKey,
      version->getTransactionViewVersionKey,
      (transactionEntity :> string),
      isAdvancedView->getStringFromBool,
      devClickhouseAggregate->getStringFromBool,
      startTime,
      endTime,
    ]->Array.joinWith(":")
  }, (
    entity,
    version,
    transactionEntity,
    isAdvancedView,
    devClickhouseAggregate,
    startTime,
    endTime,
  ))

  let loadAggregateCounts = async () => {
    try {
      if isAdvancedOrdersView {
        let url = getURL(~entityName=V1(ANALYTICS_SANKEY), ~methodType=Post)
        let body =
          [
            ("startTime", startTime->JSON.Encode.string),
            ("endTime", endTime->JSON.Encode.string),
          ]->getJsonFromArrayOfJson

        let response = await updateDetails(url, body, Post)
        setAggregateResponse(_ => response->sankeyResponseToStatusWithCount)
      } else {
        switch (devClickhouseAggregate, getClickhouseAggregateMetric(entity)) {
        | (true, Some(metricConfig)) =>
          let url = buildAggregateMetricsUrl(~metricConfig, ~transactionEntity)
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
      }
    } catch {
    | _ => showToast(~toastType=ToastError, ~message="Failed to fetch views count", ~autoClose=true)
    }
  }

  let syncActiveViewFromFilter = () => {
    let appliedRefundsFilter = filterValueJson->getArrayFromDict(refundsStatusFilterKey, [])
    let appliedDisputeFilter = filterValueJson->getArrayFromDict(disputeStatusFilterKey, [])
    let appliedFirstAttemptFilter =
      filterValueJson->getArrayFromDict(firstAttemptStatusFilterKey, [])
    let appliedStatusFilter = filterValueJson->getArrayFromDict(customFilterKey, [])

    let isAllViewSelected =
      appliedStatusFilter->getStrArrayFromJsonArray->Array.toSorted(compareLogic) ==
        aggregateResponse
        ->getDictFromJsonObject
        ->getDictfromDict("status_with_count")
        ->Dict.keysToArray
        ->Array.toSorted(compareLogic)

    if isAdvancedOrdersView && appliedRefundsFilter->isNonEmptyArray {
      setActiveView(_ => Refunded)
    } else if isAdvancedOrdersView && appliedDisputeFilter->isNonEmptyArray {
      setActiveView(_ => Disputed)
    } else if isAdvancedOrdersView && appliedFirstAttemptFilter->isNonEmptyArray {
      let firstAttemptValue =
        appliedFirstAttemptFilter->getStrArrayFromJsonArray->Array.get(0)->Option.getOr("")
      if firstAttemptValue === "true" {
        setActiveView(_ => FirstAttemptSuccess)
      } else if firstAttemptValue === "false" {
        setActiveView(_ => RetrySuccess)
      } else {
        setActiveView(_ => None)
      }
    } else if appliedStatusFilter->Array.length == 1 {
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
    if (
      startTime->isNonEmptyString &&
      endTime->isNonEmptyString &&
      lastAggregateRequestKey.current !== aggregateRequestKey
    ) {
      let timeoutId = setTimeout(() => {
        if lastAggregateRequestKey.current !== aggregateRequestKey {
          lastAggregateRequestKey.current = aggregateRequestKey
          loadAggregateCounts()->ignore
        }
      }, 120)
      Some(() => clearTimeout(timeoutId))
    } else {
      None
    }
  }, [aggregateRequestKey])

  let viewsArray = switch entity {
  | Orders => isAdvancedView ? advancedPaymentViewsArray : paymentViewsArray
  | Refunds => refundViewsArray
  | Disputes => disputeViewsArray
  | Payouts => payoutViewsArray
  }

  <div className={`${viewsArray->Array.length->getTransactionViewGridClass} ${containerClassName}`}>
    {viewsArray
    ->Array.mapWithIndex((item, i) =>
      <TransactionViewCard
        key={i->Int.toString}
        view={item}
        count={getViewCount(item, aggregateResponse, entity)->Int.toString}
        onViewClick
        isActiveView={item == activeView}
        isNewCard={isAdvancedView && item->isAdvancedPaymentOnlyView}
        newCardDescription={item->getAdvancedPaymentViewDescription}
      />
    )
    ->React.array}
  </div>
}
