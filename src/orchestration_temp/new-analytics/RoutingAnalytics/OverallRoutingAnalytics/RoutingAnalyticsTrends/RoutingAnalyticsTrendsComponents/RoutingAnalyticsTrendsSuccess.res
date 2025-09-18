@react.component
let make = () => {
  open Typography
  open APIUtils
  open LogicUtils
  open NewAnalyticsUtils
  open RoutingAnalyticsTrendsTypes
  open RoutingAnalyticsTrendsUtils
  open NewAnalyticsTypes
  open NewAnalyticsHelper
  open RoutingAnalyticsUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (sharedData, setSharedData) = React.useState(_ => JSON.Encode.null)
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let (granularityTabState, setGranularityTabState) = React.useState(_ =>
    defaultGranularityOptionsObject
  )
  let granularityOptions = getGranularityOptions(~startTime=startTimeVal, ~endTime=endTimeVal)

  let getMetricData = async (~granularityValue) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(ANALYTICS_ROUTING), ~methodType=Post, ~id=Some("routing"))
      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some([(#payment_success_rate: routingTrendsMetrics :> string)]),
            ~delta=false,
            ~groupByNames=Some([(#connector: routingTrendsMetrics :> string)]),
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~granularity=Some(granularityValue),
            ~filter=Some(filterValueJson->JSON.Encode.object),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let response = await updateDetails(url, body, Post)
      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

      if responseData->Array.length == 0 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      } else {
        let processedModifiedData = fillMissingDataPointsForConnectors(
          ~data=responseData
          ->modifyQueryDataForSucessGraph
          ->sortQueryDataByDate,
          ~startDate=startTimeVal,
          ~endDate=endTimeVal,
          ~defaultValue={
            "payment_success_rate": 0.0,
            "time_bucket": startTimeVal,
            "connector": "",
          }->Identity.genericTypeToJson,
          ~granularity=granularityValue,
          ~isoStringToCustomTimeZone,
          ~granularityEnabled=featureFlag.granularity,
        )

        setSharedData(_ => processedModifiedData->Identity.genericTypeToJson)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Unable to fetch."))
    }
  }

  React.useEffect(_ => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      let defaultGranularity = NewAnalyticsUtils.getDefaultGranularity(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~granularity=featureFlag.granularity,
      )
      setGranularityTabState(_ => defaultGranularity)
      getMetricData(~granularityValue=defaultGranularity.value)->ignore
    }
    None
  }, (startTimeVal, endTimeVal, filterValue))

  let params = {
    data: sharedData,
    xKey: (#time_bucket: routingTrendsMetrics :> string),
    yKey: (#payment_success_rate: routingTrendsMetrics :> string),
    comparison: DateRangeUtils.DisableComparison,
  }
  let setGranularity = (option: optionType) => {
    setGranularityTabState(_ => option)
    getMetricData(~granularityValue=option.value)->ignore
  }

  let options =
    RoutingAnalyticsTrendsEntity.routingSuccessRateChartEntity.getObjects(
      ~params,
    )->RoutingAnalyticsTrendsEntity.routingSuccessRateChartEntity.getChatOptions

  <PageLoaderWrapper
    screenState customUI={<NoData />} customLoader={<Shimmer styleClass="w-full h-96" />}>
    <div className="border border-nd_gray-200 rounded-xl ">
      <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
        <p className={`${body.md.semibold} text-nd_gray-800`}>
          {"Success Over Time"->React.string}
        </p>
      </div>
      <div className="p-4">
        <Tabs
          option={granularityTabState}
          setOption={setGranularity}
          options={granularityOptions}
          showSingleTab=false
        />
        <LineGraph options />
      </div>
    </div>
  </PageLoaderWrapper>
}
