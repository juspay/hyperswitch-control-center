@react.component
let make = (~options, ~className="") => {
  <div className>
    <Highcharts.Chart options highcharts={Highcharts.highcharts} />
  </div>
}
