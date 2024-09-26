external lineGraphOptionsToJson: LineGraphTypes.lineGraphOptions => JSON.t = "%identity"

@react.component
let make = (~entity, ~config, ~className="") => {
  open NewAnalyticsTypes
  let options = entity.getChatOptions(config)->lineGraphOptionsToJson

  <div className>
    <Highcharts.Chart options highcharts={Highcharts.highcharts} />
  </div>
}
