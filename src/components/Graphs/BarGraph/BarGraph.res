external barGraphOptionsToJson: BarGraphTypes.barGraphOptions => JSON.t = "%identity"

@react.component
let make = (~options: BarGraphTypes.barGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart options={options->barGraphOptionsToJson} highcharts={Highcharts.highcharts} />
  </div>
}
