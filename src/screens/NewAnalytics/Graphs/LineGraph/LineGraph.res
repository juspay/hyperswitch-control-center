external lineGraphOptionsToJson: LineGraphTypes.lineGraphOptions => JSON.t = "%identity"
@react.component
let make = (~entity, ~data: JSON.t) => {
  open NewAnalyticsTypes
  let data = entity.getObjects(data)
  let options = entity.getChatOptions(data)
  <Highcharts.Chart options={options->lineGraphOptionsToJson} highcharts={Highcharts.highcharts} />
}
