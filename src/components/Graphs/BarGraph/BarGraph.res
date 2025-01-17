external barGraphOptionsToJson: BarGraphTypes.barGraphOptions => JSON.t = "%identity"
@react.component
let make = (~entity, ~object, ~className="") => {
  open NewAnalyticsTypes
  let options = entity.getChatOptions(object)->barGraphOptionsToJson

  <div className>
    <Highcharts.Chart options highcharts={Highcharts.highcharts} />
  </div>
}
