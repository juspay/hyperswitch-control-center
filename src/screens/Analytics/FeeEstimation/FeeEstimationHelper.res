open BarGraphTypes

let costBreakDownTableKey = "Cost Breakdown Overview"
let transactionViewTableKey = "Fee Estimate Transaction Overview"

let feeBreakdownBasedOnGeoLocationPayload = (
  ~feeBreakdownData: array<FeeEstimationTypes.feeBreakdownGeoLocation>,
  ~currency: string,
) => {
  let categories =
    feeBreakdownData->Array.map(item =>
      item.region->LogicUtils.getNonEmptyString->Option.getOr("Unknown")
    )

  let percentageSeries: BarGraphTypes.dataObj = {
    showInLegend: false,
    name: "Percentage",
    data: feeBreakdownData->Array.map(item => item.fees),
    color: "#4392BC",
  }

  let tooltipFormatterJs = @this
  (this: BarGraphTypes.pointFormatter) => {
    let title = this.points->Array.get(0)->Option.map(point => point.x)->Option.getOr("")
    let seriesNames = ["Fees Incurred"]

    let rows =
      this.points
      ->Array.mapWithIndex((point, idx) => {
        let label = seriesNames->Array.get(idx)->Option.getOr("")
        let value = point.y
        `<div
        style="
          display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: flex-start;
        gap: 12px;
        padding: 6px 10px;
        font-family: Inter, sans-serif;
        font-size: 13px;
        line-height: 1.5;
        color: #1a1a1a;
        border-radius: 6px;
      "
    >
      <div style="display: flex; align-items: center; gap: 8px">
        <div
          style="
            width: 10px;
            height: 10px;
            background-color: ${point.color};
            border-radius: 2px;
            flex-shrink: 0;
          "
        ></div>
        <div style="font-weight: 500">${label} <span style="font-weight:600">${currency} ${LogicUtils.valueFormatter(
            value,
            LogicUtilsTypes.Amount,
          )}</span></div>
      </div>
    </div>
`
      })
      ->Array.joinWith("")

    `<div class="bg-white border border-nd_br_gray-200 rounded-lg" style=\"padding:8px 12px;min-width:200px;\"><div style=\"font-weight:700;margin-bottom:8px;margin-left:8px;\">${title}</div>${rows}</div>`
  }

  let payload: BarGraphTypes.barGraphPayload = {
    categories,
    data: [percentageSeries],
    title: {text: ""},
    tooltipFormatter: BarGraphTypes.asTooltipPointFormatter(tooltipFormatterJs),
  }
  payload
}

let costBreakDownBasedOnGeoLocationPayload = (
  ~costBreakDownData: array<FeeEstimationTypes.breakdownContribution>,
  ~currency: string,
) => {
  let categories =
    costBreakDownData->Array.map(item =>
      item.cardBrand->LogicUtils.getNonEmptyString->Option.getOr("Unknown")
    )

  let percentageSeries: BarGraphTypes.dataObj = {
    showInLegend: false,
    name: "Cost Break Down",
    data: costBreakDownData->Array.map(item => item.value),
    color: "#4392BC",
  }

  let tooltipFormatterJs = @this
  (this: BarGraphTypes.pointFormatter) => {
    let title = this.points->Array.get(0)->Option.map(point => point.x)->Option.getOr("")
    let seriesNames = ["Cost Break Down"]

    let rows =
      this.points
      ->Array.mapWithIndex((point, idx) => {
        let label = seriesNames->Array.get(idx)->Option.getOr("")
        let value = point.y
        `<div style="display:flex;justify-content:space-between;gap:12px;padding:2px 0;">
          <div style=\"display:flex;align-items:center;gap:8px;\">
            <div style=\"width:10px;height:10px;background-color:${point.color};border-radius:2px;\"></div>
            <div>${label}</div>
          </div>
          <div style=\"font-weight:600\"> ${currency} ${LogicUtils.valueFormatter(
            value,
            LogicUtilsTypes.Amount,
          )}</div>
        </div>`
      })
      ->Array.joinWith("")

    `<div class="bg-white border border-nd_br_gray-200 rounded-lg" style=\"padding:8px 12px;min-width:200px;\">
      <div style=\"font-weight:700;margin-bottom:8px;\">${title}</div>
      ${rows}
    </div>`
  }

  let payload: BarGraphTypes.barGraphPayload = {
    categories,
    data: [percentageSeries],
    title: {text: ""},
    tooltipFormatter: BarGraphTypes.asTooltipPointFormatter(tooltipFormatterJs),
  }
  payload
}

let labelFormatter = currency => {
  @this
  (this: BarGraphTypes.labelFormatter) => {
    `<p class="text-sm font-medium"> ${this.value} ${currency} </p>`
  }
}
