external lineColumnGraphOptionsToJson: LineAndColumnGraphTypes.lineColumnGraphOptions => JSON.t =
  "%identity"

@react.component
let make = (~options: LineAndColumnGraphTypes.lineColumnGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart
      options={options->lineColumnGraphOptionsToJson} highcharts={Highcharts.highcharts}
    />
  </div>
}
