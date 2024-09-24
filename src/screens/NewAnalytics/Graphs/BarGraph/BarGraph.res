external barGraphOptionsToJson: BarGraphTypes.barGraphOptions => JSON.t = "%identity"
@react.component
let make = (~entity, ~data: JSON.t, ~className="") => {
  open NewAnalyticsTypes
  let object = entity.getObjects(data)
  let options = entity.getChatOptions(object)->barGraphOptionsToJson

  <div className>
    <Highcharts.Chart options highcharts={Highcharts.highcharts} />
  </div>
}
