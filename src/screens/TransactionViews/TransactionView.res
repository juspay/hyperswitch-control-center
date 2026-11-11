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
    open Typography

    let textClass = `${body.md.semibold} ${isActiveView ? "text-primary" : "text-nd_gray-700"}`
    let countTextClass = `${body.md.semibold} ${isActiveView ? "text-primary" : "text-nd_gray-900"}`
    let borderClass = isActiveView ? "border-primary" : ""

    <div
      className={`relative flex min-w-0 flex-col justify-center flex-auto gap-1 bg-white border rounded-md px-4 py-2.5 cursor-pointer hover:bg-nd_gray-50 ${borderClass}`}
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

@react.component
let make = (
  ~entity=TransactionViewTypes.Orders,
  ~version: UserInfoTypes.version=V1,
  ~isAdvancedView=false,
  ~containerClassName="mb-8",
  ~allStatuses=[],
) => {
  open APIUtils
  open LogicUtils
  open TransactionViewUtils
  open Typography
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let {getResolvedUserInfo} = React.useContext(UserInfoProvider.defaultContext)
  let {transactionEntity} = getResolvedUserInfo()
  let {updateExistingKeys, removeKeys, filterValueJson, filterValue, filterKeys, setfilterKeys} =
    FilterContext.filterContext->React.useContext
  let {devClickhouseAggregate} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasResourceAccess} = GroupACLHooks.useUserGroupACLHook()
  let isClickhouseAggregateEnabled =
    devClickhouseAggregate && userHasResourceAccess(~resourceAccess=Analytics) === Access
  let (aggregateResponse, setAggregateResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let (activeView: TransactionViewTypes.viewTypes, setActiveView) = React.useState(_ =>
    TransactionViewTypes.All
  )

  let customFilterKey = getCustomFilterKey(entity)
  let isAdvancedOrdersView = isAdvancedView && entity == Orders
  let getStatusFilterForView = (view: TransactionViewTypes.viewTypes) =>
    view == All && allStatuses->isNonEmptyArray
      ? allStatuses->Array.joinWith(",")
      : view->getViewFilterValue(aggregateResponse, entity)

  let updateViewsFilterValue = (view: TransactionViewTypes.viewTypes) => {
    let (filterEntries, removedFilterKeys) = getFilterUpdateForView(
      ~view,
      ~isAdvancedOrdersView,
      ~customFilterKey,
      ~customFilter=`[${view->getStatusFilterForView}]`,
    )

    removedFilterKeys->isNonEmptyArray ? removeKeys(removedFilterKeys) : ()

    updateExistingKeys(Dict.fromArray(filterEntries))
    setfilterKeys(_ =>
      mergeFilterKeysForView(
        ~existingKeys=filterKeys,
        ~removedFilterKeys,
        ~filterEntryKeys=filterEntries->Array.map(((key, _)) => key),
      )
    )
  }

  let onViewClick = (view: TransactionViewTypes.viewTypes) => {
    setActiveView(_ => view)
    updateViewsFilterValue(view)
  }

  let (startTime, endTime) = React.useMemo(() => {
    getStartAndEndTime(filterValueJson, version)
  }, (filterValue, version))

  let aggregateRequestKey = React.useMemo(() => {
    [
      (transactionEntity :> string),
      isClickhouseAggregateEnabled->getStringFromBool,
      startTime,
      endTime,
    ]->Array.joinWith(":")
  }, (transactionEntity, isClickhouseAggregateEnabled, startTime, endTime))

  let loadAggregateCounts = async () => {
    try {
      if isAdvancedOrdersView {
        let url = transactionEntity->buildSankeyMetricsUrl
        let body =
          [
            ("startTime", startTime->JSON.Encode.string),
            ("endTime", endTime->JSON.Encode.string),
          ]->getJsonFromArrayOfJson

        let response = await updateDetails(url, body, Post)
        setAggregateResponse(_ => response->sankeyResponseToStatusWithCount)
      } else {
        switch (isClickhouseAggregateEnabled, getClickhouseAggregateMetric(entity)) {
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
          let entityName = getEntityName(~entity, ~version)
          let url = getURL(
            ~entityName,
            ~methodType=Get,
            ~queryParameters=Some(`start_time=${startTime}&end_time=${endTime}`),
          )
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
      filterValueJson->getArrayFromDict(OrderUIUtils.firstAttemptFilterKey, [])
    let appliedStatusFilter = filterValueJson->getArrayFromDict(customFilterKey, [])

    let allViewStatuses =
      allStatuses->isNonEmptyArray
        ? allStatuses
        : aggregateResponse
          ->getDictFromJsonObject
          ->getDictfromDict("status_with_count")
          ->Dict.keysToArray

    let isAllViewSelected =
      appliedStatusFilter->getStrArrayFromJsonArray->Array.toSorted(compareLogic) ==
        allViewStatuses->Array.toSorted(compareLogic)

    if isAdvancedOrdersView && appliedRefundsFilter->isNonEmptyArray {
      setActiveView(_ => Refunded)
    } else if isAdvancedOrdersView && appliedDisputeFilter->isNonEmptyArray {
      setActiveView(_ => Disputed)
    } else if isAdvancedOrdersView && appliedFirstAttemptFilter->isNonEmptyArray {
      let isFirstAttempt =
        appliedFirstAttemptFilter
        ->getStrArrayFromJsonArray
        ->getValueFromArray(0, "")
        ->getBoolFromString(false)
      setActiveView(_ => isFirstAttempt ? FirstAttemptSuccess : RetrySuccess)
    } else if appliedStatusFilter->Array.length == 1 {
      let status = appliedStatusFilter->getStrArrayFromJsonArray->getValueFromArray(0, "")

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
  }, (filterValue, aggregateResponse, allStatuses))

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      loadAggregateCounts()->ignore
    }
    None
  }, [aggregateRequestKey])

  let viewsArray = switch entity {
  | Orders => isAdvancedView ? advancedPaymentViewsArray : paymentViewsArray
  | Refunds => refundViewsArray
  | Disputes => disputeViewsArray
  | Payouts => payoutViewsArray
  }
  let gridColsClass =
    viewsArray->Array.length >= 6
      ? "lg:grid-cols-6 sm:grid-cols-3"
      : "lg:grid-cols-4 sm:grid-cols-2"

  // Counts respond to the date range only; any other applied filter scopes the table alone.
  let viewControlledFilterKeys = [
    OrderUIUtils.startTimeFilterKey(version),
    OrderUIUtils.endTimeFilterKey(version),
    customFilterKey,
    refundsStatusFilterKey,
    disputeStatusFilterKey,
    OrderUIUtils.firstAttemptFilterKey,
  ]
  let hasTableOnlyFilters =
    filterValueJson
    ->Dict.keysToArray
    ->Array.some(key => !(viewControlledFilterKeys->Array.includes(key)))

  let formatTime = DateRangeUtils.convertTimeStamp(~isoStringToCustomTimeZone, _, dateTimeFormat)
  let dateRangeLabel =
    startTime->isNonEmptyString && endTime->isNonEmptyString
      ? `${startTime->formatTime} - ${endTime->formatTime}`
      : ""

  <div className={`flex flex-col gap-3 ${containerClassName}`}>
    <div className="flex flex-wrap items-center justify-between gap-x-4 gap-y-1">
      <div className="flex items-center gap-2 min-w-0">
        <p className={`${body.md.semibold} text-nd_gray-800`}> {"Overview"->React.string} </p>
        <RenderIf condition={dateRangeLabel->isNonEmptyString}>
          <p className={`${body.sm.medium} text-nd_gray-500 truncate`}>
            {dateRangeLabel->React.string}
          </p>
        </RenderIf>
        <ToolTip
          description=viewsCountDescription
          toolTipFor={<span className="inline-flex items-center text-nd_gray-500">
            <Icon name="nd-info-circle" size=14 />
          </span>}
          toolTipPosition=Top
        />
      </div>
      <RenderIf condition=hasTableOnlyFilters>
        <div className={`flex items-center gap-1.5 text-nd_gray-600 ${body.sm.medium}`}>
          <Icon name="nd-info-circle" size=14 className="text-nd_yellow-700" />
          <p> {viewsCountFilterHint->React.string} </p>
        </div>
      </RenderIf>
    </div>
    <div className={`grid ${gridColsClass} md:grid-cols-3 grid-cols-2 gap-6`}>
      {viewsArray
      ->Array.mapWithIndex((item, i) =>
        <TransactionViewCard
          key={i->Int.toString}
          view={item}
          count={getViewCount(item, aggregateResponse, entity)->Int.toString}
          onViewClick
          isActiveView={item == activeView}
          isNewCard={isAdvancedView && !(paymentViewsArray->Array.includes(item))}
          newCardDescription={item->getAdvancedPaymentViewDescription}
        />
      )
      ->React.array}
    </div>
  </div>
}
