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

  let customFilterKey = getCustomFilterKey(entity)
  let isAdvancedOrdersView = isAdvancedView && entity == Orders

  let updateViewsFilterValue = (view: TransactionViewTypes.viewTypes) => {
    let (filterEntries, removedFilterKeys) = getFilterUpdateForView(
      ~view,
      ~isAdvancedOrdersView,
      ~customFilterKey,
      ~customFilter=`[${view->getViewFilterValue(aggregateResponse, entity)}]`,
    )

    if removedFilterKeys->isNonEmptyArray {
      removeKeys(removedFilterKeys)
    }

    updateExistingKeys(Dict.fromArray(filterEntries))
    setfilterKeys(prev =>
      mergeFilterKeysForView(
        ~existingKeys=prev,
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
          let url = getAggregateUrl(~getURL, ~entity, ~version, ~startTime, ~endTime)
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
  }, (filterValueJson, aggregateResponse))

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

  <div
    className={`${viewsArray->Array.length >= 6
        ? "grid lg:grid-cols-6 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6"
        : "grid lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6"} ${containerClassName}`}>
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
