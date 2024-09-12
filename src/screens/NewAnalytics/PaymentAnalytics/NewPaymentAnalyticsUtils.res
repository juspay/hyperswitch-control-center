// helper functions

let paymentsLifeCycleMapper = (_json): SankeyGraphTypes.sankeyPayload => {
  open SankeyGraphTypes
  let processedData = [
    ("Payments Initiated", "Success", 8000, "#E4EFFF"),
    ("Payments Initiated", "Non-terminal state", 1200, "#E4EFFF"),
    ("Success", "Dispute Raised", 200, "#F7E0E0"),
    ("Success", "Refunds Issued", 600, "#E4EFFF"),
    ("Payments Initiated", "Failed", 200, "#F7E0E0"),
    ("Payments Initiated", "Drop-offs", 600, "#F7E0E0"),
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
    text: "Payments Lifecycle",
  }
  let colors = ["#91B7EE", "#91B7EE", "#91B7EE", "#EC6262", "#91B7EE", "#EC6262", "#BA3535"]
  {data: processedData, nodes: sankeyNodes, title, colors}
}
