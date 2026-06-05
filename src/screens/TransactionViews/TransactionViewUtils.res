open TransactionViewTypes

let paymentViewsArray: array<viewTypes> = [
  All,
  Succeeded,
  Failed,
  Dropoffs,
  Cancelled,
  RequiresCapture,
]

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
  | _ => ""
  }
}

let getViewTypeFromString = (view, entity) => {
  switch entity {
  | Orders =>
    switch view {
    | "succeeded" => Succeeded
    | "cancelled" => Cancelled
    | "failed" => Failed
    | "requires_payment_method" => Dropoffs
    | "pending" => Pending
    | "requires_capture" => RequiresCapture
    | _ => All
    }
  | Refunds =>
    switch view {
    | "success" => Succeeded
    | "failure" => Failed
    | "pending" => Pending
    | _ => All
    }
  | Disputes =>
    switch view {
    | "dispute_won" => Succeeded
    | "dispute_lost" => Failed
    | "dispute_opened" => Pending
    | _ => All
    }
  | Payouts =>
    switch view {
    | "success" => Succeeded
    | "failed" => Failed
    | "cancelled" => Cancelled
    | "expired" => Expired
    | "reversed" => Reversed
    | _ => All
    }
  }
}

let buildAllStatusFilterString = obj => {
  open LogicUtils
  obj
  ->getDictFromJsonObject
  ->getDictfromDict("status_with_count")
  ->Dict.keysToArray
  ->Array.joinWith(",")
}

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
  open LogicUtils
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
  open LogicUtils
  switch view {
  | All => calculateTotalViewCount(obj)
  | _ =>
    obj
    ->getDictFromJsonObject
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

let getStartAndEndTime = (filterValueJson, version) => {
  filterValueJson->isEmptyDict
    ? ("", "")
    : {
        let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
        (
          filterValueJson->getString(
            OrderUIUtils.startTimeFilterKey(version),
            defaultDate.start_time,
          ),
          filterValueJson->getString(OrderUIUtils.endTimeFilterKey(version), defaultDate.end_time),
        )
      }
}
