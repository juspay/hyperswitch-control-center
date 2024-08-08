@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~entity: PerformanceMonitorTypes.entity<'t>,
  ~domain="payments",
) => {
  open APIUtils
  open LogicUtils
  open Highcharts
  open PerformanceMonitorTypes
  let updateDetails = useUpdateMethod()
  let (gaugeOption, setBarOptions) = React.useState(_ => JSON.Encode.null)

  let _ = bubbleChartModule(highchartsModule)

  let chartFetch = async () => {
    try {
      let url = `https://sandbox.hyperswitch.io/analytics/v1/metrics/${domain}`

      let metrics = entity.requestBodyConfig.metrics->Array.map(v => (v: metrics :> string))

      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some(metrics),
            ~delta=true,
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            (),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let res = await updateDetails(url, body, Post, ())
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
      let configData = entity.getChartData(~array=arr, ~config=entity.configRequiredForChartData)
      let options = GaugeChartPerformanceUtils.gaugeOption(entity.chartConfig, configData)
      setBarOptions(_ => options)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      chartFetch()->ignore
    }
    None
  }, [])

  <Chart options={gaugeOption} highcharts />
}
