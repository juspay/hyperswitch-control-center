@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~dimensions,
  ~entity: PerformanceMonitorTypes.entity<'t>,
) => {
  let domain = "payments"
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (barOption, setBarOptions) = React.useState(_ => JSON.Encode.null)
  let chartFetch = async () => {
    try {
      let metricsUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))
      let body = entity.getBody(
        ~dimensions,
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupBy=entity.requestBodyConfig.groupBy,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )
      let res = await updateDetails(metricsUrl, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
      let configData = entity.getChartData(~array=arr, ~config=entity.configRequiredForChartData)
      let options = BarChartPerformanceUtils.barOption(entity.chartConfig, configData)
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
  }, [dimensions])
  <>
    <HighchartBarChart.RawBarChart options={barOption} />
  </>
}
