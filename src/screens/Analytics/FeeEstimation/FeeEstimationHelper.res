open BarGraphTypes
let feeBreakdownBasedOnGeoLocationPayload = (
  ~feeBreakdownData: array<FeeEstimationTypes.feeBreakdownGeoLocation>,
) => {
  let categories =
    feeBreakdownData->Array.map(item =>
      item.region->LogicUtils.getNonEmptyString->Option.getOr("Unknown")
    )

  let percentageSeries: BarGraphTypes.dataObj = {
    showInLegend: false,
    name: "Percentage",
    data: feeBreakdownData->Array.map(item => item.percentage),
    color: "#4392BC",
  }

  let tooltipFormatterJs = @this
  (this: BarGraphTypes.pointFormatter) => {
    let title = this.points->Array.get(0)->Option.map(point => point.x)->Option.getOr("")
    let seriesNames = ["Percentage"]

    let rows =
      this.points
      ->Array.mapWithIndex((point, idx) => {
        let label = seriesNames->Array.get(idx)->Option.getOr("")
        let value = point.y
        `<div style="display:flex;justify-content:space-between;gap:12px;padding:2px 0;"><div style=\"display:flex;align-items:center;gap:8px;\"><div style=\"width:10px;height:10px;background-color:${point.color};border-radius:2px;\"></div><div>${label}</div></div><div style=\"font-weight:600\">${LogicUtils.valueFormatter(
            value,
            LogicUtilsTypes.Rate,
          )}</div></div>`
      })
      ->Array.joinWith("")

    `<div class="bg-white border border-nd_br_gray-200 rounded-lg" style=\"padding:8px 12px;min-width:200px;\"><div style=\"font-weight:700;margin-bottom:8px;\">${title}</div>${rows}</div>`
  }

  let payload: BarGraphTypes.barGraphPayload = {
    categories,
    data: [percentageSeries],
    title: {text: ""},
    tooltipFormatter: BarGraphTypes.asTooltipPointFormatter(tooltipFormatterJs),
  }
  payload
}
