let paymentsLifeCycleMapper = (~data, ~xKey as _, ~yKey as _): SankeyGraphTypes.sankeyPayload => {
  open SankeyGraphTypes
  open LogicUtils

  let valueDict = data->getDictFromJsonObject

  //let normal_success = valueDict->getInt("normal_success", 0)
  //let normal_failure = valueDict->getInt("normal_failure", 0)
  //let cancelled = valueDict->getInt("cancelled", 0)
  //let smart_retried_success = valueDict->getInt("smart_retried_success", 0)
  //let smart_retried_failure = valueDict->getInt("smart_retried_failure", 0)
  //let pending = valueDict->getInt("pending", 0)
  let failed = valueDict->getInt("failed", 0)
  let partial_refunded = valueDict->getInt("partial_refunded", 0)
  let refunded = valueDict->getInt("refunded", 0)
  let disputed = valueDict->getInt("disputed", 0)
  let pm_awaited = valueDict->getInt("pm_awaited", 0)
  let customer_awaited = valueDict->getInt("customer_awaited", 0)
  let success = partial_refunded + refunded + disputed

  let processedData = [
    ("Payments Initiated", "Success", success, "#E4EFFF"),
    ("Payments Initiated", "Non-terminal state", customer_awaited, "#E4EFFF"),
    ("Success", "Dispute Raised", disputed, "#F7E0E0"),
    ("Success", "Refunds Issued", refunded, "#E4EFFF"),
    ("Payments Initiated", "Failed", failed, "#F7E0E0"),
    ("Payments Initiated", "Drop-offs", pm_awaited, "#F7E0E0"),
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
