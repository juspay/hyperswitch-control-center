external pieGraphOptionsToJson: PieGraphTypes.pieGraphOptions<'t> => JSON.t = "%identity"

@react.component
let make = (~options: PieGraphTypes.pieGraphOptions<'t>, ~className="") => {
  <div className>
    <Highcharts.DonutChart
      options={options->pieGraphOptionsToJson} highcharts={Highcharts.highcharts}
    />
  </div>
}
