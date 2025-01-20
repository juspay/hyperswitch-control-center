external lineGraphOptionsToJson: LineGraphTypes.lineGraphOptions => JSON.t = "%identity"

@react.component
let make = (~options: LineGraphTypes.lineGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart
      options={options->lineGraphOptionsToJson} highcharts={Highcharts.highcharts}
    />
  </div>
}
