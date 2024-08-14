@react.component
let make = (
  ~domain,
  ~startTimeVal,
  ~endTimeVal,
  ~dimensions,
  ~entity: PerformanceMonitorTypes.entity<'t>,
) => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (options, setBarOptions) = React.useState(_ => JSON.Encode.null)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let chartFetch = async () => {
    try {
      let metricsUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))
      let body = PerformanceUtils.requestBody(
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

      if arr->Array.length > 0 {
        let configData = entity.getChartData(~array=arr, ~config=entity.configRequiredForChartData)
        let options = entity.getChartOption(configData)
        setBarOptions(_ => options)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      chartFetch()->ignore
    }
    None
  }, [dimensions])

  <PageLoaderWrapper
    screenState
    customLoader={<Shimmer styleClass="w-full h-96" />}
    customUI={PerformanceUtils.customUI(entity.title)}>
    <PerformanceUtils.Card title=entity.title>
      <HighchartPieChart.RawPieChart options={options} />
    </PerformanceUtils.Card>
  </PageLoaderWrapper>
}
