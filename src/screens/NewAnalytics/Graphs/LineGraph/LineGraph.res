external lineGraphOptionsToJson: LineGraphTypes.lineGraphOptions => JSON.t = "%identity"
@react.component
let make = (~entity, ~data: JSON.t, ~className="") => {
  open NewAnalyticsTypes
  let data = entity.getObjects(data)
  let default = entity.getChatOptions(data)->lineGraphOptionsToJson
  let (options, setOptions) = React.useState(_ => default)

  React.useEffect(() => {
    // to re-rendor the chart
    setOptions(_ => entity.getChatOptions(data)->lineGraphOptionsToJson)
    None
  }, [])

  <div className>
    <Highcharts.Chart options highcharts={Highcharts.highcharts} />
  </div>
}
