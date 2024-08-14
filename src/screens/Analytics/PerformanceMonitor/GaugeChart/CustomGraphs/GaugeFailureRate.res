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
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let _ = bubbleChartModule(highchartsModule)

  let setGraphOptionValue = (limitData, overallData) => {
    let rate = limitData /. overallData
    let value: PerformanceMonitorTypes.gaugeData = {value: rate}
    let options = entity.getChartOption(value)
    setGaugeOptions(_ => options)
  }

  let fetchExactData = async overallData => {
    try {
      let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let body = PerformanceUtils.requestBody(
        ~dimensions=[],
        ~delta=true,
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~filters=entity.requestBodyConfig.filters,
        ~metrics=entity.requestBodyConfig.metrics,
        ~customFilter=entity.requestBodyConfig.customFilter,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        let limitData = GaugeChartPerformanceUtils.getGaugeData(
          ~array=arr,
          ~config={entity.configRequiredForChartData},
        ).value
        setGraphOptionValue(limitData, overallData)
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
      let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Post, ~id=Some(domain))

      let body = PerformanceUtils.requestBody(
        ~dimensions=[],
        ~delta=true,
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~metrics=entity.requestBodyConfig.metrics,
        ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
      )

      let res = await updateDetails(url, body, Post)
      let arr =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

      if arr->Array.length > 0 {
        let overallData = GaugeChartPerformanceUtils.getGaugeData(
          ~array=arr,
          ~config={entity.configRequiredForChartData},
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
    customUI={PerformanceUtils.customUI(entity.title, ~height="h-40")}>
    <PerformanceUtils.Card title=entity.title>
      <Chart options={gaugeOption} highcharts />
    </PerformanceUtils.Card>
  </PageLoaderWrapper>
}
