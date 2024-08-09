@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~metric,
  ~filter,
  ~title,
  ~domain="payments",
  ~customValue,
) => {
  open APIUtils
  open LogicUtils
  open Highcharts
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (gaugeOption, setGaugeOptions) = React.useState(_ => JSON.Encode.null)
  let (overallData, setOverallData) = React.useState(_ => 0.0)
  let (limitData, setLimitData) = React.useState(_ => 0.0)

  let defaultChartConfig: PerformanceMonitorTypes.chartConfig = {
    title: "",
    colors: [],
  }

  let config: PerformanceMonitorTypes.chartDataConfig = {
    groupByKeys: [],
    name: metric,
  }

  let _ = bubbleChartModule(highchartsModule)

  let fetchOverallData = async () => {
    try {
      let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let metrics = (metric: PerformanceMonitorTypes.metrics :> string)

      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some([metrics]),
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

      setOverallData(_ => GaugeChartPerformanceUtils.getGaugeData(~array=arr, ~config).value)
    } catch {
    | _ => ()
    }
  }

  let fetchExactData = async () => {
    try {
      let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let metrics = (metric: PerformanceMonitorTypes.metrics :> string)

      let filters = PerformanceUtils.getFilterForPerformance(
        ~dimensions=[],
        ~filters=[filter],
        ~custom=Some(filter),
        ~customValue=Some([customValue]),
      )

      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some([metrics]),
            ~delta=true,
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~filter=filters->Some,
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      setLimitData(_ => GaugeChartPerformanceUtils.getGaugeData(~array=arr, ~config).value)
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    let rate = limitData /. overallData
    let value: PerformanceMonitorTypes.gaugeChartData = {value: rate}
    let options = GaugeChartPerformanceUtils.gaugeOption(
      defaultChartConfig,
      value,
      ~start=25,
      ~mid=50,
    )
    setGaugeOptions(_ => options)
    None
  }, [overallData, limitData])

  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      fetchOverallData()->ignore
      fetchExactData()->ignore
    }
    None
  }, [])

  <PerformanceUtils.Card title description=title>
    <Chart options={gaugeOption} highcharts />
  </PerformanceUtils.Card>
}
