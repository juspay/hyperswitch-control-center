open SankeyGraphTypes

// constants
let textColor = "#333333"
let fontFamily = "Arial, sans-serif"

let valueFormatter = (
  @this
  (this: nodeFormatter) => {
    let weight = this.point.options.dataLabels.name
    let sum = weight->Int.toFloat->CurrencyFormatUtils.valueFormatter(Volume)
    let label = `<span style="font-size: 20px; font-weight: bold;">${sum}</span><br/> <span style="font-size: 14px;">${this.point.id}</span>`
    label
  }
)->asTooltipPointFormatter

let tooltipFormatter = (
  @this
  (this: pointFormatter) => {
    let pointType = this.point.formatPrefix == "node" ? Node : Link

    let format = value => value->Int.toFloat->CurrencyFormatUtils.valueFormatter(Volume)

    let arrowIcon = "&#8594;"

    let titleString = switch pointType {
    | Node => this.key
    | Link => `${this.point.from} ${arrowIcon} ${this.point.to}`
    }

    let info = switch pointType {
    | Node => this.point.options.dataLabels.name->format
    | Link =>
      let fromValue = this.point.fromNode.options.dataLabels.name
      let toValue = this.point.toNode.options.dataLabels.name

      let (fraction, percentage) = if toValue > fromValue {
        (`${fromValue->format} to ${toValue->format}`, "100%")
      } else {
        let percentage = toValue->Int.toFloat /. fromValue->Int.toFloat *. 100.0
        (
          `${toValue->format} of ${fromValue->format}`,
          `${percentage->CurrencyFormatUtils.valueFormatter(Rate)}`,
        )
      }

      `${fraction} (${percentage})`
    }

    let title = `<div style="font-size: 16px; font-weight: bold;">${info}</div>`

    let content = `
          <div style="
          padding:5px 12px;
          border-left: 4px solid ${this.point.color};
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${title}
              <div style="
                display:flex;
                flex-direction:column;
                gap: 7px;">
                ${titleString}
              </div>
        </div>`

    `<div style="
    padding: 10px;
    width:fit-content;
    border-radius: 7px;
    background-color:#FFFFFF;
    padding:10px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
    border: 1px solid #E5E5E5;
    position:relative;">
        ${content}
    </div>`
  }
)->asTooltipPointFormatter

let getSankyGraphOptions = (payload: sankeyPayload) => {
  let {data, nodes, title, colors} = payload
  let style = {
    fontWeight: "normal",
    fontSize: "14px",
    color: textColor,
    fontFamily,
  }

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
        colors,
        keys: ["from", "to", "weight", "color"],
        data,
        nodePadding: 35,
        borderRadius: 3,
        dataLabels: {
          nodeFormatter: valueFormatter,
          style,
          allowOverlap: true, // Allow labels to overlap
          crop: false, // Prevent labels from being cropped
          overflow: "allow", // Allow labels to overflow the chart area
          align: "left",
          verticalAlign: "middle",
        },
        nodes,
      },
    ],
    tooltip: {
      enabled: true,
      useHTML: true,
      style,
      formatter: tooltipFormatter,
      crosshairs: false,
      shape: "square",
      shadow: false,
      backgroundColor: "transparent",
      borderColor: "transparent",
      borderWidth: 0.0,
    },
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
