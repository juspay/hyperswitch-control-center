open SankeyGraphTypes

let valueFormatter = (
  @this
  (this: nodeFormatter) => {
    let weight = this.point.options.dataLabels.name
    let sum = weight->Int.toFloat->NewAnalyticsUtils.valueFormatter(Volume)
    let label = `<span style="font-size: 15px; font-weight: bold;">${sum}</span><br/> <span style="font-size: 13px;">${this.point.id}</span>`
    label
  }
)->asTooltipPointFormatter

let getSankyGraphOptions = (payload: sankeyPayload) => {
  let {data, nodes, title, colors} = payload
  let options = {
    title,
    series: [
      {
        \"type": "sankey",
        exporting: {
          enabled: false,
        },
        credits: {
          enabled: false,
        },
        colors, // Payments Initiated // Success // Non-terminal state // Dispute Raised // Refunds Issued // Failed // Drop-offs
        keys: ["from", "to", "weight", "color"],
        data,
        nodePadding: 35,
        borderRadius: 0, // Set the border radius of the bars to 0
        dataLabels: {
          nodeFormatter: valueFormatter,
          style: {
            fontWeight: "normal",
            fontSize: "13px",
            color: "#333333",
          },
          allowOverlap: true, // Allow labels to overlap
          crop: false, // Prevent labels from being cropped
          overflow: "allow", // Allow labels to overflow the chart area
          align: "left",
          verticalAlign: "middle",
        },
        nodes,
      },
    ],
    chart: {
      spacingLeft: 150,
      spacingRight: 150,
    },
    credits: {
      enabled: false,
    },
  }
  options
}
