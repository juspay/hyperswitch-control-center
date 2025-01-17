@react.component
let make = (~options: BarGraphTypes.barGraphOptions, ~className="") => {
  <div className>
    <Highcharts.Chart
      options={options->BarGraphUtils.barGraphOptionsToJson} highcharts={Highcharts.highcharts}
    />
  </div>
}
