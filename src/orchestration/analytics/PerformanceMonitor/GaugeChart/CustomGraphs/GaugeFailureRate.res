@react.component
let make = (
  ~startTimeVal,
  ~endTimeVal,
  ~entity1: PerformanceMonitorTypes.entity<PerformanceMonitorTypes.gaugeData, 't1>,
  ~entity2: PerformanceMonitorTypes.entity<PerformanceMonitorTypes.gaugeData, float>,
  ~domain="payments",
  ~dimensions,
) => {
  open APIUtils
  open LogicUtils
  open Highcharts
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (gaugeOption, setGaugeOptions) = React.useState(_ => JSON.Encode.null)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchExactData = async overallData => {
    try {
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some(domain))

      let body = PerformanceUtils.requestBody(
        ~dimensions,
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity2.requestBodyConfig.delta,
        ~filters=entity2.requestBodyConfig.filters,
        ~metrics=entity2.requestBodyConfig.metrics,
        ~customFilter=entity2.requestBodyConfig.customFilter,
        ~applyFilterFor=entity2.requestBodyConfig.applyFilterFor,
      )

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 && overallData > 0.0 {
        let value = entity2.getChartData(
          ~args={
            array: arr,
            config: entity2.configRequiredForChartData,
            optionalArgs: overallData,
          },
        )
        let options = entity2.getChartOption(value)
        setGaugeOptions(_ => options)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let fetchOverallData = async () => {
    try {
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some(domain))

      let body = PerformanceUtils.requestBody(
        ~dimensions,
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~delta=entity1.requestBodyConfig.delta,
        ~metrics=entity1.requestBodyConfig.metrics,
        ~filters=entity1.requestBodyConfig.filters,
        ~applyFilterFor=entity1.requestBodyConfig.applyFilterFor,
        ~customFilter=entity1.requestBodyConfig.customFilter,
        ~excludeFilterValue=entity1.requestBodyConfig.excludeFilterValue,
      )

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        let overallData = entity1.getChartData(
          ~args={array: arr, config: entity1.configRequiredForChartData},
        ).value
        fetchExactData(overallData)->ignore
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      fetchOverallData()->ignore
    }
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customLoader={<Shimmer styleClass="w-full h-40" />}
    customUI={PerformanceUtils.customUI(entity2.title, ~height="h-40")}>
    <PerformanceUtils.Card title=entity2.title>
      <Chart options={gaugeOption} highcharts />
    </PerformanceUtils.Card>
  </PageLoaderWrapper>
}
