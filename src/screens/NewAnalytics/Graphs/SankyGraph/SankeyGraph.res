external sankeyGraphOptionsToJson: SankeyGraphTypes.sankeyGraphOptions => JSON.t = "%identity"

@react.component
let make = (~entity, ~data: JSON.t) => {
  open NewAnalyticsTypes
  Highcharts.sankeyChartModule(Highcharts.highchartsModule)
  let data = entity.getObjects(~data, ~xKey="", ~yKey="")
  let options = entity.getChatOptions(data)
  <Highcharts.Chart
    options={options->sankeyGraphOptionsToJson} highcharts={Highcharts.highcharts}
  />
}
