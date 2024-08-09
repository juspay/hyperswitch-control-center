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

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (gaugeOption, setGaugeOptions) = React.useState(_ => JSON.Encode.null)

  let _ = bubbleChartModule(highchartsModule)

  let chartFetch = async () => {
    try {
      let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let metrics =
        entity.requestBodyConfig.metrics->Array.map(v =>
          (v: PerformanceMonitorTypes.metrics :> string)
        )

      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some(metrics),
            ~delta=true,
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
      let configData = entity.getChartData(~array=arr, ~config=entity.configRequiredForChartData)
      let options = GaugeChartPerformanceUtils.gaugeOption(entity.chartConfig, configData)
      setGaugeOptions(_ => options)
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

  <PerformanceUtils.Card title=entity.chartConfig.title description=entity.chartConfig.title>
    <Chart options={gaugeOption} highcharts />
  </PerformanceUtils.Card>
}
