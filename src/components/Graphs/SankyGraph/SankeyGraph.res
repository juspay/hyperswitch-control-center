external sankeyGraphOptionsToJson: SankeyGraphTypes.sankeyGraphOptions => JSON.t = "%identity"

@react.component
let make = (~options: SankeyGraphTypes.sankeyGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart
      options={options->sankeyGraphOptionsToJson} highcharts={Highcharts.highchartsWithSankey}
    />
  </div>
}
