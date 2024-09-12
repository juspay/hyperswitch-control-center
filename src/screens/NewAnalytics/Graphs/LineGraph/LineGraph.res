external lineGraphOptionsToJson: LineGraphTypes.lineGraphOptions => JSON.t = "%identity"
@react.component
let make = (~options) => {
  <Highcharts.Chart options={options->lineGraphOptionsToJson} highcharts={Highcharts.highcharts} />
}
