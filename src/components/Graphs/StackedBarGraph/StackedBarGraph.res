external stackedBarGraphOptionsToJson: StackedBarGraphTypes.stackedBarGraphOptions => JSON.t =
  "%identity"

@react.component
let make = (~options: StackedBarGraphTypes.stackedBarGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart
      options={options->stackedBarGraphOptionsToJson} highcharts={Highcharts.highcharts}
    />
  </div>
}
