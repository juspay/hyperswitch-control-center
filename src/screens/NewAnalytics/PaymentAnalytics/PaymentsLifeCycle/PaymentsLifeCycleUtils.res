open SankeyGraphTypes
open LogicUtils
open PaymentsLifeCycleTypes
let paymentLifeCycleResponseMapper = (json: JSON.t) => {
  let valueDict = json->getDictFromJsonObject
  // response need to be changed to snake_case
  {
    normal_success: valueDict->getInt("normal_success", 0),
    normal_failure: valueDict->getInt("normal_failure", 0),
    cancelled: valueDict->getInt("cancelled", 0),
    smart_retried_success: valueDict->getInt("smart_retried_success", 0),
    smart_retried_failure: valueDict->getInt("smart_retried_failure", 0),
    pending: valueDict->getInt("pending", 0),
    partial_refunded: valueDict->getInt("partial_refunded", 0),
    refunded: valueDict->getInt("refunded", 0),
    disputed: valueDict->getInt("disputed", 0),
    pm_awaited: valueDict->getInt("pm_awaited", 0),
    customer_awaited: valueDict->getInt("customer_awaited", 0),
    merchant_awaited: valueDict->getInt("merchant_awaited", 0),
    confirmation_awaited: valueDict->getInt("confirmation_awaited", 0),
  }
}

let paymentsLifeCycleMapper = (
  ~data: paymentLifeCycle,
  ~xKey as _,
  ~yKey as _,
): SankeyGraphTypes.sankeyPayload => {
  let success = data.normal_success + data.smart_retried_success
  let failure = data.normal_failure + data.smart_retried_failure
  let refunded = data.refunded
  let pending = data.pending // Attempted Pending
  let cancelled = data.cancelled
  let customerAwaited = data.customer_awaited // DropOff2
  let attemptedPayments = pending + customerAwaited + success + failure
  let pmAwaited = data.pm_awaited // Dropoff1
  let _totalPayment = pmAwaited + attemptedPayments + cancelled

  let disputed = data.disputed

  let processedData = [
    ("Payments Initiated", "Success", success, "#E4EFFF"),
    ("Payments Initiated", "Non-terminal state", customerAwaited, "#E4EFFF"),
    ("Success", "Dispute Raised", disputed, "#F7E0E0"),
    ("Success", "Refunds Issued", refunded, "#E4EFFF"),
    ("Payments Initiated", "Failed", failure, "#F7E0E0"),
    ("Payments Initiated", "Drop-offs", pmAwaited, "#F7E0E0"),
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
  let colors = ["#91B7EE", "#91B7EE", "#91B7EE", "#EC6262", "#91B7EE", "#EC6262", "#BA3535"]

  {data: processedData, nodes: sankeyNodes, title, colors}
}
