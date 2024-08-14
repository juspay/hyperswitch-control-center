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
  let (overallData, setOverallData) = React.useState(_ => 0.0)
  let (limitData, setLimitData) = React.useState(_ => 0.0)

  let _ = bubbleChartModule(highchartsModule)

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

      setOverallData(_ =>
        GaugeChartPerformanceUtils.getGaugeData(
          ~array=arr,
          ~config={entity.configRequiredForChartData},
        ).value
      )
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let fetchExactData = async () => {
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
        setLimitData(_ =>
          GaugeChartPerformanceUtils.getGaugeData(
            ~array=arr,
            ~config={entity.configRequiredForChartData},
          ).value
        )
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    let rate = limitData /. overallData
    let value: PerformanceMonitorTypes.gaugeData = {value: rate}
    let options = GaugeChartPerformanceUtils.gaugeOption(
      value,
      ~start=25,
      ~mid=50,
      ~color1="#7AAF73",
      ~color3="#DA6C68",
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

  <PageLoaderWrapper
    screenState
    customLoader={<Shimmer styleClass="w-full h-40" />}
    customUI={PerformanceUtils.customUI(entity.title, ~height="h-40")}>
    <PerformanceUtils.Card title=entity.title>
      <Chart options={gaugeOption} highcharts />
    </PerformanceUtils.Card>
  </PageLoaderWrapper>
}
