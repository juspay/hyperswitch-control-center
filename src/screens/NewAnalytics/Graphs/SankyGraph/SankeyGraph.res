@react.component
let make = (~options) => {
  Highcharts.sankeyChartModule(Highcharts.highchartsModule)

  <Highcharts.Chart
    options={options->Identity.genericTypeToJson} highcharts={Highcharts.highcharts}
  />
}
