external lineGraphOptionsToJson: LineGraphTypes.lineGraphOptions => JSON.t = "%identity"
@react.component
let make = (~entity, ~data: JSON.t, ~className="") => {
  open NewAnalyticsTypes
  let object = entity.getObjects(data)
  let options = entity.getChatOptions(object)->lineGraphOptionsToJson

  <div className>
    <Highcharts.Chart options highcharts={Highcharts.highcharts} />
  </div>
}
