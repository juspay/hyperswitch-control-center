external sankeyGraphOptionsToJson: SankeyGraphTypes.sankeyGraphOptions => JSON.t = "%identity"

@react.component
let make = (~options: SankeyGraphTypes.sankeyGraphOptions, ~className="") => {
  Highcharts.sankeyChartModule(Highcharts.highchartsModule)

  <div className>
    <Highcharts.Chart
      options={options->sankeyGraphOptionsToJson} highcharts={Highcharts.highcharts}
    />
  </div>
}
