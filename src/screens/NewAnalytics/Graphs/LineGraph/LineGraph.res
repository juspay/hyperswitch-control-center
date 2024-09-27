external lineGraphOptionsToJson: LineGraphTypes.lineGraphOptions => JSON.t = "%identity"

@react.component
let make = (~entity, ~data: LineGraphTypes.lineGraphPayload, ~className="") => {
  open NewAnalyticsTypes
  let options = data->entity.getChatOptions->lineGraphOptionsToJson

  <div className>
    <Highcharts.Chart options highcharts={Highcharts.highcharts} />
  </div>
}
