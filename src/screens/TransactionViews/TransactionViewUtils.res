open TransactionViewTypes
open LogicUtils
open OrderUIUtils
let paymentViewsArray: array<viewTypes> = [
  All,
  Succeeded,
  Failed,
  Dropoffs,
  Cancelled,
  RequiresCapture,
]

let advancedPaymentViewsArray: array<viewTypes> = [
  All,
  Succeeded,
  Failed,
  Dropoffs,
  Cancelled,
  RequiresCapture,
  Refunded,
  FirstAttemptSuccess,
  RetrySuccess,
  Disputed,
]

let isAdvancedPaymentOnlyView = view => !(paymentViewsArray->Array.includes(view))

let getAdvancedPaymentViewDescription = view =>
  switch view {
  | Refunded => "Payments that have partial or full refunds."
  | Disputed => "Payments that have a dispute state present."
  | FirstAttemptSuccess => "Succeeded payments completed on the first attempt."
  | RetrySuccess => "Succeeded payments completed after more than one attempt."
  | _ => ""
  }

let paymentStatusFilterKey = (#status: OrderTypes.filter)->getValueFromFilterType

let refundsStatusFilterKey = (#refunds_status: OrderTypes.filter)->getValueFromFilterType

let disputeStatusFilterKey = (#dispute_status: OrderTypes.filter)->getValueFromFilterType

let getAdvancedPaymentFilterKeyForView = (view, ~defaultFilterKey) =>
  switch view {
  | Refunded => refundsStatusFilterKey
  | Disputed => disputeStatusFilterKey
  | _ => defaultFilterKey
  }

let getAdvancedPaymentHiddenFilterEntryForView = view =>
  switch view {
  | FirstAttemptSuccess => Some((firstAttemptFilterKey, "[true]"))
  | RetrySuccess => Some((firstAttemptFilterKey, "[false]"))
  | _ => None
  }

let getAdvancedPaymentFilterKeysToRemove = view =>
  switch view {
  | Refunded => [paymentStatusFilterKey, disputeStatusFilterKey, firstAttemptFilterKey]
  | Disputed => [paymentStatusFilterKey, refundsStatusFilterKey, firstAttemptFilterKey]
  | FirstAttemptSuccess
  | RetrySuccess => [refundsStatusFilterKey, disputeStatusFilterKey]
  | _ => [refundsStatusFilterKey, disputeStatusFilterKey, firstAttemptFilterKey]
  }

let getTransactionViewEntityKey = (entity: operationsTypes) => (entity :> string)

let getTransactionViewVersionKey = (version: UserInfoTypes.version) => (version :> string)

let refundViewsArray: array<viewTypes> = [All, Succeeded, Failed, Pending]

let disputeViewsArray: array<viewTypes> = [All, Succeeded, Failed, Pending]

let payoutViewsArray: array<viewTypes> = [All, Succeeded, Failed, Cancelled, Expired, Reversed]

let getCustomFilterKey = entity =>
  switch entity {
  | Orders => "status"
  | Refunds => "refund_status"
  | Disputes => "dispute_status"
  | Payouts => "status"
  }

let getClickhouseAggregateMetric = entity =>
  switch entity {
  | Orders =>
    Some({
      urlPrefix: "analytics/v2",
      domain: "payments",
      metric: "payment_intent_count",
      groupByField: "status",
      statusField: "status",
      countField: "payment_intent_count",
    })
  | Refunds =>
    Some({
      urlPrefix: "analytics/v1",
      domain: "refunds",
      metric: "refund_count",
      groupByField: "refund_status",
      statusField: "refund_status",
      countField: "refund_count",
    })
  | Disputes
  | Payouts =>
    None
  }

let buildAggregateMetricsUrl = (~metricConfig, ~transactionEntity) => {
  let scope = switch transactionEntity {
  | #Profile => "profile"
  | _ => "merchant"
  }
  `${Window.env.apiBaseUrl}/${metricConfig.urlPrefix}/${scope}/metrics/${metricConfig.domain}`
}

let getAggregateUrl = (
  ~getURL: APIUtilsTypes.getUrlTypes,
  ~entity: operationsTypes,
  ~version: UserInfoTypes.version,
  ~startTime,
  ~endTime,
) => {
  open APIUtilsTypes
  let queryParameters = Some(`start_time=${startTime}&end_time=${endTime}`)
  let entityName = switch entity {
  | Orders =>
    switch version {
    | V1 => V1(ORDERS_AGGREGATE)
    | V2 => V2(V2_ORDERS_AGGREGATE)
    }
  | Refunds => V1(REFUNDS_AGGREGATE)
  | Disputes => V1(DISPUTES_AGGREGATE)
  | Payouts => V1(PAYOUTS_AGGREGATE)
  }
  getURL(~entityName, ~methodType=Fetch.Get, ~queryParameters)
}

let getViewsDisplayName = (view: viewTypes) => {
  switch view {
  | All => "All"
  | Succeeded => "Succeeded"
  | Failed => "Failed"
  | Dropoffs => "Dropoffs"
  | Cancelled => "Cancelled"
  | Pending => "Pending"
  | Expired => "Expired"
  | Reversed => "Reversed"
  | RequiresCapture => "Requires Capture"
  | FirstAttemptSuccess => "First Attempt Success"
  | RetrySuccess => "Retry Success"
  | Refunded => "Refunded"
  | Disputed => "Disputed"
  | _ => ""
  }
}

let getViewTypeFromString = (view, entity) => {
  switch entity {
  | Orders =>
    switch view->HSwitchOrderUtils.statusVariantMapper {
    | Succeeded => Succeeded
    | Cancelled => Cancelled
    | Failed => Failed
    | RequiresPaymentMethod => Dropoffs
    | RequiresCapture => RequiresCapture
    | _ => view === "pending" ? Pending : All
    }
  | Refunds =>
    switch view->HSwitchOrderUtils.refundStatusVariantMapper {
    | Success => Succeeded
    | Failure => Failed
    | Pending => Pending
    | _ => All
    }
  | Disputes =>
    switch view->DisputesUtils.disputeStatusVariantMapper {
    | DisputeWon => Succeeded
    | DisputeLost => Failed
    | DisputeOpened => Pending
    | _ => All
    }
  | Payouts =>
    switch view->PayoutsEntity.statusVariantMapper {
    | Succeeded => Succeeded
    | Failed => Failed
    | _ =>
      switch view {
      | "cancelled" => Cancelled
      | "expired" => Expired
      | "reversed" => Reversed
      | _ => All
      }
    }
  }
}

let buildAllStatusFilterStringForKey = (obj, key) => {
  obj
  ->getDictFromJsonObject
  ->getDictfromDict(key)
  ->Dict.keysToArray
  ->Array.joinWith(",")
}

let refundedStatusValues = openSearchRefundStatusValues

let disputedStatusValues = openSearchDisputeStatusValues

let buildAllowedStatusFilterStringWithFallback = (obj, key, allowedStatuses, fallbackValue) => {
  let statusDict = obj->getDictFromJsonObject->getDictfromDict(key)
  let filterValue =
    allowedStatuses
    ->Array.filter(status => statusDict->getOptionValFromDict(status)->Option.isSome)
    ->Array.joinWith(",")
  filterValue->isNonEmptyString ? filterValue : fallbackValue
}

let sumAllowedStatusCount = (dict, key, allowedStatuses) => {
  let statusDict = dict->getDictfromDict(key)
  allowedStatuses->Array.reduce(0, (acc, status) =>
    (acc->Int.toFloat +. statusDict->getFloat(status, 0.0))->Float.toInt
  )
}

let getSankeyCountMetric = (dict, key) => dict->getInt(key, 0)

let getSankeyRowCount = dict => dict->getFloat("count", dict->getFloat("payment_intent_count", 0.0))

let getSankeyFirstAttempt = dict =>
  switch dict->getOptionValFromDict(firstAttemptFilterKey) {
  | Some(value) => value->getBoolFromJson(value->getIntFromJson(0) == 1)
  | None => false
  }

let buildAllStatusFilterString = obj => buildAllStatusFilterStringForKey(obj, "status_with_count")

let getViewFilterValue = (view, obj, entity) => {
  switch entity {
  | Orders =>
    switch view {
    | All => buildAllStatusFilterString(obj)
    | Succeeded => "succeeded"
    | Failed => "failed"
    | Dropoffs => "requires_payment_method"
    | Cancelled => "cancelled"
    | Pending => "pending"
    | RequiresCapture => "requires_capture"
    | FirstAttemptSuccess
    | RetrySuccess => "succeeded"
    | Refunded => refundedStatusValues->Array.joinWith(",")
    | Disputed =>
      buildAllowedStatusFilterStringWithFallback(
        obj,
        "dispute_status_with_count",
        disputedStatusValues,
        disputedStatusValues->Array.joinWith(","),
      )
    | _ => ""
    }
  | Refunds =>
    switch view {
    | All => buildAllStatusFilterString(obj)
    | Succeeded => "success"
    | Failed => "failure"
    | Pending => "pending"
    | _ => ""
    }
  | Disputes =>
    switch view {
    | All => buildAllStatusFilterString(obj)
    | Succeeded => "dispute_won"
    | Failed => "dispute_lost"
    | Pending => "dispute_opened"
    | _ => ""
    }
  | Payouts =>
    switch view {
    | All => buildAllStatusFilterString(obj)
    | Succeeded => "success"
    | Failed => "failed"
    | Cancelled => "cancelled"
    | Expired => "expired"
    | Reversed => "reversed"
    | _ => ""
    }
  }
}

let calculateTotalViewCount = obj => {
  let countArray =
    obj
    ->getDictFromJsonObject
    ->getDictfromDict("status_with_count")
    ->Dict.valuesToArray
  countArray->Array.reduce(0, (acc, curr) =>
    (acc->Int.toFloat +. curr->getFloatFromJson(0.0))->Float.toInt
  )
}

let getViewCount = (view, obj, entity) => {
  let dict = obj->getDictFromJsonObject
  switch (view, entity) {
  | (All, _) => calculateTotalViewCount(obj)
  | (Refunded, Orders) =>
    sumAllowedStatusCount(dict, "refunds_status_with_count", refundedStatusValues)
  | (Disputed, Orders) =>
    sumAllowedStatusCount(dict, "dispute_status_with_count", disputedStatusValues)
  | (FirstAttemptSuccess, Orders) => getSankeyCountMetric(dict, "first_attempt_success_count")
  | (RetrySuccess, Orders) => getSankeyCountMetric(dict, "retry_success_count")
  | _ =>
    dict
    ->getDictfromDict("status_with_count")
    ->getInt(view->getViewFilterValue(obj, entity), 0)
  }
}

let buildAggregateMetricsBody = (~startTime, ~endTime, ~metric, ~groupByField) => {
  let timeRange =
    [
      ("startTime", startTime->JSON.Encode.string),
      ("endTime", endTime->JSON.Encode.string),
    ]->getJsonFromArrayOfJson

  let body =
    [
      ("timeRange", timeRange),
      ("groupByNames", [groupByField->JSON.Encode.string]->JSON.Encode.array),
      ("metrics", [metric->JSON.Encode.string]->JSON.Encode.array),
      ("source", "BATCH"->JSON.Encode.string),
    ]->getJsonFromArrayOfJson

  [body]->JSON.Encode.array
}

let metricsResponseToStatusWithCount = (~statusField, ~countField, response) => {
  let statusWithCount = Dict.make()

  response
  ->getDictFromJsonObject
  ->getArrayFromDict("queryData", [])
  ->Array.forEach(row => {
    let dict = row->getDictFromJsonObject
    let status = dict->getString(statusField, "")
    if status->isNonEmptyString {
      statusWithCount->Dict.set(status, dict->getFloat(countField, 0.0)->JSON.Encode.float)
    }
  })

  [("status_with_count", statusWithCount->JSON.Encode.object)]->getJsonFromArrayOfJson
}

type sankeyAggregateData = {
  statusWithCount: Dict.t<JSON.t>,
  refundsStatusWithCount: Dict.t<JSON.t>,
  disputeStatusWithCount: Dict.t<JSON.t>,
  mutable firstAttemptSuccessCount: float,
  mutable retrySuccessCount: float,
}

let sankeyResponseToStatusWithCount = response => {
  let result =
    response
    ->getArrayFromJson([])
    ->Array.reduce(
      (
        {
          statusWithCount: Dict.make(),
          refundsStatusWithCount: Dict.make(),
          disputeStatusWithCount: Dict.make(),
          firstAttemptSuccessCount: 0.0,
          retrySuccessCount: 0.0,
        }: sankeyAggregateData
      ),
      (acc, row) => {
        let dict = row->getDictFromJsonObject
        let count = dict->getSankeyRowCount
        let status = dict->getString("status", "")->String.toLowerCase
        let refundsStatus = dict->getString("refunds_status", "")
        let disputeStatus = dict->getString("dispute_status", "")
        let isFirstAttempt = dict->getSankeyFirstAttempt

        if status->isNonEmptyString {
          let previous = acc.statusWithCount->getFloat(status, 0.0)
          acc.statusWithCount->Dict.set(status, (previous +. count)->JSON.Encode.float)
        }
        if status === "succeeded" && isFirstAttempt {
          acc.firstAttemptSuccessCount = acc.firstAttemptSuccessCount +. count
        }
        if status === "succeeded" && !isFirstAttempt {
          acc.retrySuccessCount = acc.retrySuccessCount +. count
        }
        if refundsStatus->isNonEmptyString {
          let previous = acc.refundsStatusWithCount->getFloat(refundsStatus, 0.0)
          acc.refundsStatusWithCount->Dict.set(
            refundsStatus,
            (previous +. count)->JSON.Encode.float,
          )
        }
        if disputeStatus->isNonEmptyString {
          let previous = acc.disputeStatusWithCount->getFloat(disputeStatus, 0.0)
          acc.disputeStatusWithCount->Dict.set(
            disputeStatus,
            (previous +. count)->JSON.Encode.float,
          )
        }
        acc
      },
    )

  [
    ("status_with_count", result.statusWithCount->JSON.Encode.object),
    ("refunds_status_with_count", result.refundsStatusWithCount->JSON.Encode.object),
    ("dispute_status_with_count", result.disputeStatusWithCount->JSON.Encode.object),
    ("first_attempt_success_count", result.firstAttemptSuccessCount->JSON.Encode.float),
    ("retry_success_count", result.retrySuccessCount->JSON.Encode.float),
  ]->getJsonFromArrayOfJson
}

let getStartAndEndTime = (filterValueJson, version) => {
  filterValueJson->isEmptyDict
    ? ("", "")
    : {
        let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
        (
          filterValueJson->getString(startTimeFilterKey(version), defaultDate.start_time),
          filterValueJson->getString(endTimeFilterKey(version), defaultDate.end_time),
        )
      }
}

let buildAggregateRequestKey = (
  ~entity: operationsTypes,
  ~version: UserInfoTypes.version,
  ~transactionEntity: UserInfoTypes.entity,
  ~isAdvancedView: bool,
  ~devClickhouseAggregate: bool,
  ~startTime: string,
  ~endTime: string,
) =>
  [
    entity->getTransactionViewEntityKey,
    version->getTransactionViewVersionKey,
    (transactionEntity :> string),
    isAdvancedView->getStringFromBool,
    devClickhouseAggregate->getStringFromBool,
    startTime,
    endTime,
  ]->Array.joinWith(":")
