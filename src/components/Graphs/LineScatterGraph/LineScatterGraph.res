external lineScatterGraphOptionsToJson: LineScatterGraphTypes.lineScatterGraphOptions => JSON.t =
  "%identity"

@react.component
let make = (~options: LineScatterGraphTypes.lineScatterGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart
      options={options->lineScatterGraphOptionsToJson} highcharts={Highcharts.highcharts}
    />
  </div>
}
