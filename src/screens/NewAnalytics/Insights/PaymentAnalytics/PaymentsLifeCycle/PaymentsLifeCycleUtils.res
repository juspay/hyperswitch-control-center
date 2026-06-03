open SankeyGraphTypes
open LogicUtils
open PaymentsLifeCycleTypes

let getstatusVariantTypeFromString = value => {
  switch value {
  | "succeeded" => Succeeded
  | "failed" => Failed
  | "cancelled" => Cancelled
  | "processing" => Processing
  | "requires_customer_action" => RequiresCustomerAction
  | "requires_merchant_action" => RequiresMerchantAction
  | "requires_payment_method" => RequiresPaymentMethod
  | "requires_confirmation" => RequiresConfirmation
  | "requires_capture" => RequiresCapture
  | "partially_captured" => PartiallyCaptured
  | "partially_captured_and_capturable" => PartiallyCapturedAndCapturable
  | "full_refunded" => Full_Refunded
  | "partial_refunded" => Partial_Refunded
  | "dispute_present" => Dispute_Present
  | _ => Null
  }
}

let getStringFromStatusVariantType = value => {
  switch value {
  | Succeeded => "succeeded"
  | Failed => "failed"
  | Cancelled => "cancelled"
  | Processing => "processing"
  | RequiresCustomerAction => "requires_customer_action"
  | RequiresMerchantAction => "requires_merchant_action"
  | RequiresPaymentMethod => "requires_payment_method"
  | RequiresConfirmation => "requires_confirmation"
  | RequiresCapture => "requires_capture"
  | PartiallyCaptured => "partially_captured"
  | PartiallyCapturedAndCapturable => "partially_captured_and_capturable"
  | Full_Refunded => "full_refunded"
  | Partial_Refunded => "partial_refunded"
  | Dispute_Present => "dispute_present"
  | Null => ""
  }
}

let paymentLifeCycleResponseMapper = (json: JSON.t, ~isSmartRetryEnabled=true) => {
  let valueDict =
    [
      "normal_success",
      "normal_failure",
      "pending",
      "cancelled",
      "drop_offs",
      "smart_retried_success",
      "smart_retried_failure",
      "partial_refunded",
      "refunded",
      "disputed",
    ]
    ->Array.map(item => (item, 0))
    ->Dict.fromArray

  let queryItems =
    json
    ->getArrayFromJson([])
    ->Array.map(query => {
      let queryDict = query->getDictFromJsonObject

      {
        count: queryDict->getInt("count", 0),
        dispute_status: queryDict->getString("dispute_status", "")->getstatusVariantTypeFromString,
        first_attempt: queryDict->getInt("first_attempt", 0),
        refunds_status: queryDict->getString("refunds_status", "")->getstatusVariantTypeFromString,
        status: queryDict->getString("status", "")->getstatusVariantTypeFromString,
      }
    })

  queryItems->Array.forEach(query => {
    let includeSmartRetry =
      query.first_attempt == 1 || (query.first_attempt != 1 && isSmartRetryEnabled)
    switch query.status {
    | Succeeded => {
        // normal_success or smart_retried_success
        if query.first_attempt == 1 {
          valueDict->Dict.set(
            "normal_success",
            valueDict->getInt("normal_success", 0) + query.count,
          )
        } else {
          valueDict->Dict.set(
            "smart_retried_success",
            valueDict->getInt("smart_retried_success", 0) + query.count,
          )
        }

        if includeSmartRetry {
          // "refunded" or "partial_refunded"
          switch query.refunds_status {
          | Full_Refunded =>
            valueDict->Dict.set("refunded", valueDict->getInt("refunded", 0) + query.count)
          | Partial_Refunded =>
            valueDict->Dict.set(
              "partial_refunded",
              valueDict->getInt("partial_refunded", 0) + query.count,
            )
          | _ => ()
          }

          // "disputed"
          switch query.dispute_status {
          | Dispute_Present =>
            valueDict->Dict.set("disputed", valueDict->getInt("disputed", 0) + query.count)
          | _ => ()
          }
        }
      }
    | Failed => {
        valueDict->Dict.set("normal_failure", valueDict->getInt("normal_failure", 0) + query.count)
        if query.first_attempt != 1 {
          valueDict->Dict.set(
            "smart_retried_failure",
            valueDict->getInt("smart_retried_failure", 0) + query.count,
          )
        }
      }
    | Cancelled =>
      if includeSmartRetry {
        valueDict->Dict.set("cancelled", valueDict->getInt("cancelled", 0) + query.count)
      } else {
        valueDict->Dict.set(
          "smart_retried_failure",
          valueDict->getInt("smart_retried_failure", 0) + query.count,
        )
      }
    | RequiresCapture
    | Processing =>
      if includeSmartRetry {
        valueDict->Dict.set("pending", valueDict->getInt("pending", 0) + query.count)
      } else {
        valueDict->Dict.set(
          "smart_retried_failure",
          valueDict->getInt("smart_retried_failure", 0) + query.count,
        )
      }
    | RequiresCustomerAction
    | RequiresMerchantAction
    | RequiresPaymentMethod
    | RequiresConfirmation
    | PartiallyCaptured
    | PartiallyCapturedAndCapturable
    | Null
    | _ =>
      if includeSmartRetry {
        valueDict->Dict.set("drop_offs", valueDict->getInt("drop_offs", 0) + query.count)
      } else {
        valueDict->Dict.set(
          "smart_retried_failure",
          valueDict->getInt("smart_retried_failure", 0) + query.count,
        )
      }
    }
  })

  {
    normalSuccess: valueDict->getInt("normal_success", 0),
    normalFailure: valueDict->getInt("normal_failure", 0),
    cancelled: valueDict->getInt("cancelled", 0),
    smartRetriedSuccess: valueDict->getInt("smart_retried_success", 0),
    smartRetriedFailure: valueDict->getInt("smart_retried_failure", 0),
    pending: valueDict->getInt("pending", 0),
    partialRefunded: valueDict->getInt("partial_refunded", 0),
    refunded: valueDict->getInt("refunded", 0),
    disputed: valueDict->getInt("disputed", 0),
    drop_offs: valueDict->getInt("drop_offs", 0),
  }
}

let getTotalPayments = json => {
  let data = json->paymentLifeCycleResponseMapper

  let payment_initiated =
    data.normalSuccess + data.normalFailure + data.cancelled + data.pending + data.drop_offs

  payment_initiated
}

let transformData = (data: array<(string, int)>) => {
  let data = data->Array.map(item => {
    let (key, value) = item
    (key, value->Int.toFloat)
  })
  let arr = data->Array.map(item => {
    let (_, value) = item
    value
  })
  let minVal = arr->Math.minMany
  let maxVal = arr->Math.maxMany
  let total = arr->Array.reduce(0.0, (sum, count) => {
    sum +. count
  })
  // Normalize Each Element
  let updatedData = data->Array.map(item => {
    let (key, count) = item
    let num = count -. minVal
    let dinom = maxVal -. minVal
    let normalizedValue = maxVal != minVal ? num /. dinom : 1.0

    (key, normalizedValue)
  })
  // Map to Target Range
  let updatedData = updatedData->Array.map(item => {
    let (key, count) = item
    let scaledValue = count *. (100.0 -. 10.0) +. 10.0
    (key, scaledValue)
  })
  // Adjust to Sum 100
  let updatedData = updatedData->Array.map(item => {
    let (key, count) = item
    let mul = 100.0 /. total
    let finalValue = count *. mul
    (key, finalValue)
  })
  // Round to Integers
  let updatedData = updatedData->Array.map(item => {
    let (key, count) = item
    let finalValue = (count *. 100.0)->Float.toInt
    (key, finalValue)
  })

  updatedData->Dict.fromArray
}

let paymentsLifeCycleMapper = (
  ~params: InsightsTypes.getObjects<paymentLifeCycle>,
): SankeyGraphTypes.sankeyPayload => {
  open NewAnalyticsUtils
  let {data, xKey} = params

  let isSmartRetryEnabled = xKey->getBoolFromString(true)

  let normalSuccess = data.normalSuccess
  let normalFailure = data.normalFailure
  let totalFailure = normalFailure + (isSmartRetryEnabled ? 0 : data.smartRetriedSuccess)
  let pending = data.pending
  let cancelled = data.cancelled
  let dropoff = data.drop_offs
  let disputed = data.disputed
  let refunded = data.refunded
  let partialRefunded = data.partialRefunded
  let smartRetriedFailure = isSmartRetryEnabled ? data.smartRetriedFailure : 0
  let smartRetriedSuccess = isSmartRetryEnabled ? data.smartRetriedSuccess : 0
  let success = normalSuccess + smartRetriedSuccess

  let valueDict =
    [
      ("Succeeded on First Attempt", normalSuccess),
      ("Succeeded on Subsequent Attempts", smartRetriedSuccess),
      ("Failed", totalFailure),
      ("Smart Retried Failure", smartRetriedFailure),
      ("Pending", pending),
      ("Cancelled", cancelled),
      ("Drop-offs", dropoff),
      ("Dispute Raised", disputed),
      ("Refunds Issued", refunded),
      ("Partial Refunded", partialRefunded),
    ]
    ->Array.filter(item => {
      let (_, value) = item
      value > 0
    })
    ->transformData

  let total = success + totalFailure + pending + dropoff + cancelled

  let sankeyNodes = [
    {
      id: "Payments Initiated",
      dataLabels: {
        align: "left",
        x: -130,
        name: total,
      },
    },
    {
      id: "Succeeded on First Attempt",
      dataLabels: {
        align: "right",
        x: 183,
        name: normalSuccess,
      },
    },
    {
      id: "Failed",
      dataLabels: {
        align: "left",
        x: 20,
        name: totalFailure,
      },
    },
    {
      id: "Pending",
      dataLabels: {
        align: "left",
        x: 20,
        name: pending,
      },
    },
    {
      id: "Cancelled",
      dataLabels: {
        align: "left",
        x: 20,
        name: cancelled,
      },
    },
    {
      id: "Drop-offs",
      dataLabels: {
        align: "left",
        x: 20,
        name: dropoff,
      },
    },
    {
      id: "Success",
      dataLabels: {
        align: "right",
        x: 65,
        name: success,
      },
    },
    {
      id: "Refunds Issued",
      dataLabels: {
        align: "right",
        x: 110,
        name: refunded,
      },
    },
    {
      id: "Partial Refunded",
      dataLabels: {
        align: "right",
        x: 115,
        name: partialRefunded,
      },
    },
    {
      id: "Dispute Raised",
      dataLabels: {
        align: "right",
        x: 105,
        name: disputed,
      },
    },
    {
      id: "Smart Retried Failure",
      dataLabels: {
        align: "right",
        x: 145,
        name: smartRetriedFailure,
      },
    },
    {
      id: "Succeeded on Subsequent Attempts",
      dataLabels: {
        align: "right",
        x: 235,
        name: smartRetriedSuccess,
      },
    },
  ]

  let normalSuccess = valueDict->getInt("Succeeded on First Attempt", 0)
  let smartRetriedSuccess = valueDict->getInt("Succeeded on Subsequent Attempts", 0)
  let totalFailure = valueDict->getInt("Failed", 0)
  let smartRetriedFailure = valueDict->getInt("Smart Retried Failure", 0)
  let pending = valueDict->getInt("Pending", 0)
  let cancelled = valueDict->getInt("Cancelled", 0)
  let dropoff = valueDict->getInt("Drop-offs", 0)
  let disputed = valueDict->getInt("Dispute Raised", 0)
  let refunded = valueDict->getInt("Refunds Issued", 0)
  let partialRefunded = valueDict->getInt("Partial Refunded", 0)

  let processedData = if isSmartRetryEnabled {
    [
      ("Payments Initiated", "Succeeded on First Attempt", normalSuccess, sankyBlue),
      ("Payments Initiated", "Succeeded on Subsequent Attempts", smartRetriedSuccess, sankyBlue), // smart retry
      ("Payments Initiated", "Failed", totalFailure, sankyRed),
      ("Payments Initiated", "Pending", pending, sankyBlue),
      ("Payments Initiated", "Cancelled", cancelled, sankyRed),
      ("Payments Initiated", "Drop-offs", dropoff, sankyRed),
      ("Succeeded on First Attempt", "Success", normalSuccess, sankyBlue),
      ("Succeeded on Subsequent Attempts", "Success", smartRetriedSuccess, sankyBlue),
      ("Failed", "Smart Retried Failure", smartRetriedFailure, sankyRed), // smart retry
      ("Success", "Refunds Issued", refunded, sankyBlue),
      ("Success", "Partial Refunded", partialRefunded, sankyBlue),
      ("Success", "Dispute Raised", disputed, sankyRed),
    ]
  } else {
    [
      ("Payments Initiated", "Success", normalSuccess, sankyBlue),
      ("Payments Initiated", "Failed", totalFailure, sankyRed),
      ("Payments Initiated", "Pending", pending, sankyBlue),
      ("Payments Initiated", "Cancelled", cancelled, sankyRed),
      ("Payments Initiated", "Drop-offs", dropoff, sankyRed),
      ("Success", "Refunds Issued", refunded, sankyBlue),
      ("Success", "Partial Refunded", partialRefunded, sankyBlue),
      ("Success", "Dispute Raised", disputed, sankyRed),
    ]
  }

  let title = {
    text: "",
  }

  let colors = if isSmartRetryEnabled {
    [
      sankyLightBlue, // "Payments Initiated"
      sankyLightBlue, // "Succeeded on First Attempt"
      sankyLightBlue, // "Succeeded on Subsequent Attempts"
      sankyLightRed, // "Failed"
      sankyLightBlue, // "Pending"
      sankyLightRed, // "Cancelled"
      sankyLightRed, // "Drop-offs"
      sankyLightBlue, // "Success"
      sankyLightRed, // "Smart Retried Failure"
      sankyLightBlue, // "Refunds Issued"
      sankyLightBlue, // "Partial Refunded"
      sankyLightRed, // "Dispute Raised"
    ]
  } else {
    [
      sankyLightBlue, // "Payments Initiated"
      sankyLightBlue, // "Success"
      sankyLightRed, // "Failed"
      sankyLightBlue, // "Pending"
      sankyLightRed, // "Cancelled"
      sankyLightRed, // "Drop-offs"
      sankyLightBlue, // "Refunds Issued"
      sankyLightBlue, // "Partial Refunded"
      sankyLightRed, // "Dispute Raised"
    ]
  }

  {data: processedData, nodes: sankeyNodes, title, colors}
}
