external barGraphOptionsToJson: ColumnGraphTypes.columnGraphOptions => JSON.t = "%identity"

@react.component
let make = (~options: ColumnGraphTypes.columnGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart options={options->barGraphOptionsToJson} highcharts={Highcharts.highcharts} />
  </div>
}
