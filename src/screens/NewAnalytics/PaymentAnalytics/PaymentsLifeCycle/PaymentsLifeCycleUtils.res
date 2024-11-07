open SankeyGraphTypes
open LogicUtils
open PaymentsLifeCycleTypes
let paymentLifeCycleResponseMapper = (json: JSON.t) => {
  let valueDict = json->getDictFromJsonObject
  // response need to be changed to snake_case
  // {
  //   normalSuccess: valueDict->getInt("normal_success", 0),
  //   normalFailure: valueDict->getInt("normal_failure", 0),
  //   cancelled: valueDict->getInt("cancelled", 0),
  //   smartRetriedSuccess: valueDict->getInt("smart_retried_success", 0),
  //   smartRetriedFailure: valueDict->getInt("smart_retried_failure", 0),
  //   pending: valueDict->getInt("pending", 0),
  //   partialRefunded: valueDict->getInt("partial_refunded", 0),
  //   refunded: valueDict->getInt("refunded", 0),
  //   disputed: valueDict->getInt("disputed", 0),
  //   pmAwaited: valueDict->getInt("pm_awaited", 0),
  //   customerAwaited: valueDict->getInt("customer_awaited", 0),
  //   merchantAwaited: valueDict->getInt("merchant_awaited", 0),
  //   confirmationAwaited: valueDict->getInt("confirmation_awaited", 0),
  // }
  {
    normalSuccess: 15,
    normalFailure: 10,
    cancelled: 5,
    smartRetriedSuccess: 5,
    smartRetriedFailure: 5,
    pending: 5,
    partialRefunded: 5,
    refunded: 5,
    disputed: 5,
    pmAwaited: 5,
    customerAwaited: 5,
    merchantAwaited: 5,
    confirmationAwaited: 5,
  }
}

let paymentsLifeCycleMapper = (
  ~params: NewAnalyticsTypes.getObjects<paymentLifeCycle>,
): SankeyGraphTypes.sankeyPayload => {
  let {data, xKey} = params
  let isSmartRetryEnabled =
    xKey->getBoolFromString(true)->NewPaymentAnalyticsUtils.getSmartRetryMetricType
  let success =
    data.normalSuccess + (isSmartRetryEnabled === Smart_Retry ? data.smartRetriedSuccess : 0)
  let failure =
    data.normalFailure + (isSmartRetryEnabled === Smart_Retry ? data.smartRetriedFailure : 0)
  let refunded = data.refunded
  let pending = data.pending // Attempted Pending
  let cancelled = data.cancelled
  let customerAwaited = data.customerAwaited // DropOff2
  let attemptedPayments = pending + customerAwaited + success + failure
  let pmAwaited = data.pmAwaited // Dropoff1
  let _totalPayment = pmAwaited + attemptedPayments + cancelled

  let disputed = data.disputed

  let processedData = [
    ("Payments Initiated", "Success", success, "#E4EFFF"),
    ("Payments Initiated", "Failed", failure, "#F7E0E0"),
    ("Payments Initiated", "Pending", failure, "#F7E0E0"),
    ("Payments Initiated", "Cancelled", customerAwaited, "#E4EFFF"),
    ("Payments Initiated", "Drop-offs", 20, "#F7E0E0"),
    ("Success", "Dispute Raised", disputed, "#F7E0E0"),
    ("Success", "Refunds Issued", refunded, "#E4EFFF"),
    ("Success", "Partial Refunded", refunded, "#E4EFFF"),
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
      id: "Non-terminal state",
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
  let colors = ["#91B7EE"] // , "#91B7EE", "#91B7EE", "#EC6262", "#91B7EE", "#EC6262", "#BA3535"

  {data: processedData, nodes: sankeyNodes, title, colors}
}
