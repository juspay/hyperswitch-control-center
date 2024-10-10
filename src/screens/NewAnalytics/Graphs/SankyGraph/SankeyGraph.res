external sankeyGraphOptionsToJson: SankeyGraphTypes.sankeyGraphOptions => JSON.t = "%identity"

@react.component
let make = (~entity, ~data: SankeyGraphTypes.sankeyPayload) => {
  open NewAnalyticsTypes
  Highcharts.sankeyChartModule(Highcharts.highchartsModule)
  let options = entity.getChatOptions(data)

  <Highcharts.Chart
    options={options->sankeyGraphOptionsToJson} highcharts={Highcharts.highcharts}
  />
}
