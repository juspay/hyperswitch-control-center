open SankeyGraphTypes
open LogicUtils
open PaymentsLifeCycleTypes
let paymentLifeCycleResponseMapper = (json: JSON.t) => {
  let valueDict = json->getDictFromJsonObject

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
    pmAwaited: valueDict->getInt("pm_awaited", 0),
    customerAwaited: valueDict->getInt("customer_awaited", 0),
    merchantAwaited: valueDict->getInt("merchant_awaited", 0),
    confirmationAwaited: valueDict->getInt("confirmation_awaited", 0),
  }
}

let getTotalPayments = json => {
  let data = json->paymentLifeCycleResponseMapper

  let total =
    data.normalSuccess +
    data.normalFailure +
    data.cancelled +
    data.smartRetriedSuccess +
    data.smartRetriedFailure +
    data.pending +
    data.partialRefunded +
    data.refunded +
    data.disputed +
    data.pmAwaited +
    data.customerAwaited +
    data.merchantAwaited +
    data.confirmationAwaited

  total
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
    let normalizedValue = num /. dinom

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
  ~params: NewAnalyticsTypes.getObjects<paymentLifeCycle>,
): SankeyGraphTypes.sankeyPayload => {
  let {data, xKey} = params

  let isSmartRetryEnabled = xKey->getBoolFromString(true)

  let disputed = data.disputed
  let refunded = data.refunded
  let partialRefunded = data.partialRefunded

  let success =
    disputed +
    refunded +
    partialRefunded +
    (isSmartRetryEnabled ? data.smartRetriedSuccess : 0) +
    data.normalSuccess
  let failure = data.normalFailure + (isSmartRetryEnabled ? data.smartRetriedFailure * 2 : 0)
  let pending = data.pending
  let cancelled = data.cancelled
  let dropoff =
    data.pmAwaited + data.customerAwaited + data.merchantAwaited + data.confirmationAwaited

  let valueDict =
    [
      ("Success", success),
      ("Failed", failure),
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

  let total = success + failure + pending + cancelled + dropoff

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
      id: "Success",
      dataLabels: {
        align: "right",
        x: -25,
        name: success,
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
      id: "Failed",
      dataLabels: {
        align: "left",
        x: 20,
        name: failure,
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
  ]

  let success = valueDict->getInt("Success", 0)
  let failure = valueDict->getInt("Failed", 0)
  let pending = valueDict->getInt("Pending", 0)
  let cancelled = valueDict->getInt("Cancelled", 0)
  let dropoff = valueDict->getInt("Drop-offs", 0)
  let disputed = valueDict->getInt("Dispute Raised", 0)
  let refunded = valueDict->getInt("Refunds Issued", 0)
  let partialRefunded = valueDict->getInt("Partial Refunded", 0)

  let processedData = [
    ("Payments Initiated", "Success", success, "#E4EFFF"),
    ("Payments Initiated", "Failed", failure, "#F7E0E0"),
    ("Payments Initiated", "Pending", pending, "#E4EFFF"),
    ("Payments Initiated", "Cancelled", cancelled, "#F7E0E0"),
    ("Payments Initiated", "Drop-offs", dropoff, "#F7E0E0"),
    ("Success", "Dispute Raised", disputed, "#F7E0E0"),
    ("Success", "Refunds Issued", refunded, "#E4EFFF"),
    ("Success", "Partial Refunded", partialRefunded, "#E4EFFF"),
  ]

  let title = {
    text: "",
  }
  let colors = [
    "#91B7EE",
    "#91B7EE",
    "#EC6262",
    "#91B7EE",
    "#EC6262",
    "#EC6262",
    "#EC6262",
    "#91B7EE",
  ]

  {data: processedData, nodes: sankeyNodes, title, colors}
}
