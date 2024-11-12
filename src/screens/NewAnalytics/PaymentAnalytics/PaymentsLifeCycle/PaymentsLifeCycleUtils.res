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

  let sankeyNodes = [
    {
      id: "Payments Initiated",
      dataLabels: {
        align: "left",
        x: -130,
      },
    },
    {
      id: "Success",
      dataLabels: {
        align: "right",
        x: -25,
      },
    },
    {
      id: "Dispute Raised",
      dataLabels: {
        align: "right",
        x: 105,
      },
    },
    {
      id: "Refunds Issued",
      dataLabels: {
        align: "right",
        x: 110,
      },
    },
    {
      id: "Partial Refunded",
      dataLabels: {
        align: "right",
        x: 115,
      },
    },
    {
      id: "Pending",
      dataLabels: {
        align: "left",
        x: 20,
      },
    },
    {
      id: "Cancelled",
      dataLabels: {
        align: "left",
        x: 20,
      },
    },
    {
      id: "Failed",
      dataLabels: {
        align: "left",
        x: 20,
      },
    },
    {
      id: "Drop-offs",
      dataLabels: {
        align: "left",
        x: 20,
      },
    },
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
