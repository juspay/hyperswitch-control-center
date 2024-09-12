external sankeyGraphOptionsToJson: SankeyGraphTypes.sankeyGraphOptions => JSON.t = "%identity"

@react.component
let make = (~options) => {
  Highcharts.sankeyChartModule(Highcharts.highchartsModule)

  <Highcharts.Chart
    options={options->sankeyGraphOptionsToJson} highcharts={Highcharts.highcharts}
  />
}
