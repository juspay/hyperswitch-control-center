module RawDonutChart = {
  @react.component
  let make = (~options: Js.Json.t) => {
    <Highcharts.DonutChart highcharts={Highcharts.highchartsModule} options />
  }
}
