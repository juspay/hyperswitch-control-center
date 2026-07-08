open LogicUtils
open OrderUIUtils
open OrderTypes
module TransactionView = TransactionViewTypes

let paymentStatusFilterKey = (#status: filter)->getValueFromFilterType

let refundsStatusFilterKey = (#refunds_status: filter)->getValueFromFilterType

let disputeStatusFilterKey = (#dispute_status: filter)->getValueFromFilterType

let getGridClass = viewsCount =>
  viewsCount >= 6
    ? "grid lg:grid-cols-6 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6"
    : "grid lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6"

let buildAllStatusFilterStringForKey = (obj, key) => {
  obj
  ->getDictFromJsonObject
  ->getDictfromDict(key)
  ->Dict.keysToArray
  ->Array.joinWith(",")
}

let buildAllowedStatusFilterStringWithFallback = (obj, key, allowedStatuses, fallbackValue) => {
  let statusDict = obj->getDictFromJsonObject->getDictfromDict(key)
  let filterValue =
    allowedStatuses
    ->Array.filter(status => statusDict->Dict.get(status)->Option.isSome)
    ->Array.joinWith(",")

  filterValue->isNonEmptyString ? filterValue : fallbackValue
}

let getViewFilterValue = (view, obj) =>
  switch view {
  | TransactionView.All => buildAllStatusFilterStringForKey(obj, "status_with_count")
  | TransactionView.Succeeded => "succeeded"
  | TransactionView.Failed => "failed"
  | TransactionView.Dropoffs => "requires_payment_method"
  | TransactionView.Cancelled => "cancelled"
  | TransactionView.Pending => "pending"
  | TransactionView.RequiresCapture => "requires_capture"
  | TransactionView.FirstAttemptSuccess
  | TransactionView.RetrySuccess => "succeeded"
  | TransactionView.Refunded => openSearchRefundStatusValues->Array.joinWith(",")
  | TransactionView.Disputed =>
    buildAllowedStatusFilterStringWithFallback(
      obj,
      "dispute_status_with_count",
      openSearchDisputeStatusValues,
      openSearchDisputeStatusValues->Array.joinWith(","),
    )
  | _ => ""
  }

let getFilterKeyForView = view =>
  switch view {
  | TransactionView.Refunded => refundsStatusFilterKey
  | TransactionView.Disputed => disputeStatusFilterKey
  | _ => paymentStatusFilterKey
  }

let getHiddenFilterEntryForView = view =>
  switch view {
  | TransactionView.FirstAttemptSuccess => Some((firstAttemptFilterKey, "[true]"))
  | TransactionView.RetrySuccess => Some((firstAttemptFilterKey, "[false]"))
  | _ => None
  }

let getFilterKeysToRemove = view =>
  switch view {
  | TransactionView.Refunded => [
      paymentStatusFilterKey,
      disputeStatusFilterKey,
      firstAttemptFilterKey,
    ]
  | TransactionView.Disputed => [
      paymentStatusFilterKey,
      refundsStatusFilterKey,
      firstAttemptFilterKey,
    ]
  | TransactionView.FirstAttemptSuccess
  | TransactionView.RetrySuccess => [refundsStatusFilterKey, disputeStatusFilterKey]
  | _ => [refundsStatusFilterKey, disputeStatusFilterKey, firstAttemptFilterKey]
  }

let sumAllowedStatusCount = (dict, key, allowedStatuses) => {
  let statusDict = dict->getDictfromDict(key)
  allowedStatuses->Array.reduce(0, (acc, status) =>
    (acc->Int.toFloat +. statusDict->getFloat(status, 0.0))->Float.toInt
  )
}

let getSankeyRowCount = dict => dict->getFloat("count", dict->getFloat("payment_intent_count", 0.0))

let getSankeyFirstAttempt = dict =>
  switch dict->Dict.get(firstAttemptFilterKey) {
  | Some(value) =>
    switch value->JSON.Decode.bool {
    | Some(isFirstAttempt) => Some(isFirstAttempt)
    | None =>
      switch value->getOptionIntFromJson {
      | Some(1) => Some(true)
      | Some(0) => Some(false)
      | _ =>
        switch value
        ->JSON.Decode.string
        ->Option.map(value => value->String.trim->String.toLowerCase) {
        | Some("true") => Some(true)
        | Some("false") => Some(false)
        | _ => None
        }
      }
    }
  | None => None
  }

let sankeyResponseToStatusWithCount = response => {
  let statusWithCount = Dict.make()
  let refundsStatusWithCount = Dict.make()
  let disputeStatusWithCount = Dict.make()
  let firstAttemptSuccessCount = ref(0.0)
  let retrySuccessCount = ref(0.0)

  response
  ->getArrayFromJson([])
  ->Array.forEach(row => {
    let dict = row->getDictFromJsonObject
    let count = dict->getSankeyRowCount
    let status = dict->getString("status", "")->String.toLowerCase
    let refundsStatus = dict->getString("refunds_status", "")
    let disputeStatus = dict->getString("dispute_status", "")
    let firstAttempt = dict->getSankeyFirstAttempt

    if status->isNonEmptyString {
      let previous = statusWithCount->getFloat(status, 0.0)
      statusWithCount->Dict.set(status, (previous +. count)->JSON.Encode.float)
    }
    if status === "succeeded" {
      switch firstAttempt {
      | Some(true) => firstAttemptSuccessCount := firstAttemptSuccessCount.contents +. count
      | Some(false) => retrySuccessCount := retrySuccessCount.contents +. count
      | None => ()
      }
    }
    if refundsStatus->isNonEmptyString {
      let previous = refundsStatusWithCount->getFloat(refundsStatus, 0.0)
      refundsStatusWithCount->Dict.set(refundsStatus, (previous +. count)->JSON.Encode.float)
    }
    if disputeStatus->isNonEmptyString {
      let previous = disputeStatusWithCount->getFloat(disputeStatus, 0.0)
      disputeStatusWithCount->Dict.set(disputeStatus, (previous +. count)->JSON.Encode.float)
    }
  })

  [
    ("status_with_count", statusWithCount->JSON.Encode.object),
    ("refunds_status_with_count", refundsStatusWithCount->JSON.Encode.object),
    ("dispute_status_with_count", disputeStatusWithCount->JSON.Encode.object),
    ("first_attempt_success_count", firstAttemptSuccessCount.contents->JSON.Encode.float),
    ("retry_success_count", retrySuccessCount.contents->JSON.Encode.float),
  ]->getJsonFromArrayOfJson
}

let getViewCount = (view, obj) => {
  let dict = obj->getDictFromJsonObject

  switch view {
  | TransactionView.All => TransactionViewUtils.calculateTotalViewCount(obj)
  | TransactionView.Refunded =>
    sumAllowedStatusCount(dict, "refunds_status_with_count", openSearchRefundStatusValues)
  | TransactionView.Disputed =>
    sumAllowedStatusCount(dict, "dispute_status_with_count", openSearchDisputeStatusValues)
  | TransactionView.FirstAttemptSuccess =>
    dict->getFloat("first_attempt_success_count", 0.0)->Float.toInt
  | TransactionView.RetrySuccess => dict->getFloat("retry_success_count", 0.0)->Float.toInt
  | _ => dict->getDictfromDict("status_with_count")->getInt(view->getViewFilterValue(obj), 0)
  }
}

module Card = {
  @react.component
  let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
    let isNewCard = view->TransactionViewUtils.isAdvancedPaymentOnlyView
    let textClass = isActiveView ? "text-primary" : "font-semibold text-jp-gray-700"
    let countTextClass = isActiveView ? "text-primary" : "font-semibold text-jp-gray-900"
    let borderClass = isActiveView ? "border-primary" : ""

    <div
      className={`relative flex min-w-0 flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-2.5 cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <RenderIf condition=isNewCard>
        <div className="absolute right-2 top-2">
          <NewFeatureTag
            description={view->TransactionViewUtils.getAdvancedPaymentNewCardDescription}
          />
        </div>
      </RenderIf>
      <p className={`${textClass} truncate ${isNewCard ? "pr-9" : ""}`}>
        {view->TransactionViewUtils.getViewsDisplayName->React.string}
      </p>
      <RenderIf condition={!(count->isEmptyString)}>
        <p className={countTextClass}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~version: UserInfoTypes.version=V1, ~requestScopeKey="", ~containerClassName="") => {
  open APIUtils
  open APIUtilsTypes

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()
  let {updateExistingKeys, removeKeys, filterValueJson, setfilterKeys} =
    FilterContext.filterContext->React.useContext
  let (aggregateResponse, setAggregateResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let (activeView: TransactionView.viewTypes, setActiveView) = React.useState(_ =>
    TransactionView.All
  )
  let lastAggregateRequestKey = React.useRef("")

  let (startTime, endTime) = React.useMemo(() => {
    TransactionViewUtils.getStartAndEndTime(filterValueJson, version)
  }, (filterValueJson, version))
  let aggregateRequestKey = React.useMemo(() => {
    [requestScopeKey, startTime, endTime]->Array.joinWith(":")
  }, (requestScopeKey, startTime, endTime))

  let updateViewsFilterValue = view => {
    let customFilter = `[${view->getViewFilterValue(aggregateResponse)}]`
    let filterKey = view->getFilterKeyForView
    let filterEntries = switch view->getHiddenFilterEntryForView {
    | Some(entry) => [(filterKey, customFilter), entry]
    | None => [(filterKey, customFilter)]
    }
    let filterEntryKeys = filterEntries->Array.map(((key, _)) => key)
    let removedFilterKeys = view->getFilterKeysToRemove

    if removedFilterKeys->isNonEmptyArray {
      removeKeys(removedFilterKeys)
    }

    updateExistingKeys(Dict.fromArray(filterEntries))
    setfilterKeys(prev =>
      prev
      ->Array.filter(key => !(removedFilterKeys->Array.includes(key)))
      ->Array.concat(filterEntryKeys)
      ->getUniqueArray
    )
  }

  let onViewClick = view => {
    setActiveView(_ => view)
    updateViewsFilterValue(view)
  }

  let loadAggregateCounts = async () => {
    try {
      let url = getURL(~entityName=V1(ANALYTICS_SANKEY), ~methodType=Post)
      let body =
        [
          ("startTime", startTime->JSON.Encode.string),
          ("endTime", endTime->JSON.Encode.string),
        ]->getJsonFromArrayOfJson

      let response = await updateDetails(url, body, Post)
      setAggregateResponse(_ => response->sankeyResponseToStatusWithCount)
    } catch {
    | _ => showToast(~toastType=ToastError, ~message="Failed to fetch views count", ~autoClose=true)
    }
  }

  let syncActiveViewFromFilter = () => {
    let appliedRefundsFilter = filterValueJson->getArrayFromDict(refundsStatusFilterKey, [])
    let appliedDisputeFilter = filterValueJson->getArrayFromDict(disputeStatusFilterKey, [])
    let appliedFirstAttemptFilter = filterValueJson->getArrayFromDict(firstAttemptFilterKey, [])
    let appliedStatusFilter = filterValueJson->getArrayFromDict(paymentStatusFilterKey, [])

    let isAllViewSelected =
      appliedStatusFilter->getStrArrayFromJsonArray->Array.toSorted(compareLogic) ==
        aggregateResponse
        ->getDictFromJsonObject
        ->getDictfromDict("status_with_count")
        ->Dict.keysToArray
        ->Array.toSorted(compareLogic)

    if appliedRefundsFilter->isNonEmptyArray {
      setActiveView(_ => TransactionView.Refunded)
    } else if appliedDisputeFilter->isNonEmptyArray {
      setActiveView(_ => TransactionView.Disputed)
    } else if appliedFirstAttemptFilter->isNonEmptyArray {
      let firstAttemptValue =
        appliedFirstAttemptFilter->getStrArrayFromJsonArray->Array.get(0)->Option.getOr("")

      if firstAttemptValue === "true" {
        setActiveView(_ => TransactionView.FirstAttemptSuccess)
      } else if firstAttemptValue === "false" {
        setActiveView(_ => TransactionView.RetrySuccess)
      } else {
        setActiveView(_ => TransactionView.None)
      }
    } else if appliedStatusFilter->Array.length == 1 {
      let status =
        appliedStatusFilter
        ->getValueFromArray(0, ""->JSON.Encode.string)
        ->JSON.Decode.string
        ->Option.getOr("")

      let viewType = status->TransactionViewUtils.getViewTypeFromString(TransactionView.Orders)
      switch viewType {
      | TransactionView.All => setActiveView(_ => TransactionView.None)
      | _ => setActiveView(_ => viewType)
      }
    } else if isAllViewSelected {
      setActiveView(_ => TransactionView.All)
    } else {
      setActiveView(_ => TransactionView.None)
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

  <div
    className={`${TransactionViewUtils.advancedPaymentViewsArray
      ->Array.length
      ->getGridClass} ${containerClassName}`}>
    {TransactionViewUtils.advancedPaymentViewsArray
    ->Array.mapWithIndex((view, index) =>
      <Card
        key={index->Int.toString}
        view
        count={view->getViewCount(aggregateResponse)->Int.toString}
        onViewClick
        isActiveView={view == activeView}
      />
    )
    ->React.array}
  </div>
}
