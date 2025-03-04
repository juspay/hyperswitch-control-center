@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~entity: PerformanceMonitorTypes.entity<'t, 't1>,
  ~domain="payments",
) => {
  open APIUtils
  open LogicUtils
  open Highcharts
  let getURL = useGetURL()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let updateDetails = useUpdateMethod()
  let (gaugeOption, setGaugeOptions) = React.useState(_ => JSON.Encode.null)

  let _ = bubbleChartModule(highchartsModule)

  let chartFetch = async () => {
    try {
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some(domain))

      let body = PerformanceUtils.requestBody(
        ~dimensions=[],
        ~excludeFilterValue=entity.requestBodyConfig.excludeFilterValue,
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity.requestBodyConfig.delta,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~groupBy=entity.requestBodyConfig.groupBy,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        let configData = entity.getChartData(
          ~args={array: arr, config: entity.configRequiredForChartData},
        )
        let options = entity.getChartOption(configData)
        setGaugeOptions(_ => options)
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
  }, [])

  <PageLoaderWrapper
    screenState
    customLoader={<Shimmer styleClass="w-full h-40" />}
    customUI={PerformanceUtils.customUI(entity.title, ~height="h-40")}>
    <PerformanceUtils.Card title=entity.title>
      <Chart options={gaugeOption} highcharts />
    </PerformanceUtils.Card>
  </PageLoaderWrapper>
}
