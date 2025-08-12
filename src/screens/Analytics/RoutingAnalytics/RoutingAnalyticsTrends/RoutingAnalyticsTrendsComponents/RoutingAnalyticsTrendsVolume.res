@react.component
let make = () => {
  open Typography
  open APIUtils
  open LogicUtils
  open InsightsUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (sharedData, setSharedData) = React.useState(_ => JSON.Encode.null)
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let defaultGranularity = InsightsUtils.getDefaultGranularity(
    ~startTime=startTimeVal,
    ~endTime=endTimeVal,
    ~granularity=featureFlag.granularity,
  )
  let granularityOptions = getGranularityOptions(~startTime=startTimeVal, ~endTime=endTimeVal)
  let (granularity, setGranularity) = React.useState(_ => defaultGranularity)

  let getMetricData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(ANALYTICS_ROUTING), ~methodType=Post, ~id=Some("routing"))
      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some(["payment_success_rate", "payment_count"]),
            ~delta=false,
            ~groupByNames=Some(["connector"]),
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~granularity=Some(granularity.value),
            ~filter=Some(filterValueJson->JSON.Encode.object),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let response = await updateDetails(url, body, Post)
      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

      if responseData->Array.length == 0 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      } else {
        let processedModifiedData = RoutingAnalyticsTrendsUtils.fillMissingDataPointsForConnectors(
          ~data=responseData->RoutingAnalyticsTrendsUtils.modifyQueryData->sortQueryDataByDate,
          ~startDate=startTimeVal,
          ~endDate=endTimeVal,
          ~defaultValue={
            "payment_success_rate": 0.0,
            "payment_count": 0,
            "time_bucket": startTimeVal,
            "connector": "",
          }->Identity.genericTypeToJson,
          ~granularity=granularity.value,
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

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setGranularity(_ => defaultGranularity)
    }
    None
  }, (startTimeVal, endTimeVal))

  React.useEffect(_ => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getMetricData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, granularity.value, filterValue))

  let params = {
    InsightsTypes.data: sharedData,
    yKey: "payment_count",
    xKey: "time_bucket",
    comparison: DateRangeUtils.DisableComparison,
  }
  let setGranularity = value => {
    setGranularity(_ => value)
  }
  let options =
    RoutingAnalyticsTrendsEntity.routingVolumeChartEntity.getObjects(
      ~params,
    )->RoutingAnalyticsTrendsEntity.routingVolumeChartEntity.getChatOptions

  <PageLoaderWrapper
    screenState
    customUI={<InsightsHelper.NoData height="h-72" />}
    customLoader={<Shimmer styleClass="w-full h-96" />}>
    <div className="border border-nd_gray-200 rounded-xl w-full">
      <div className="bg-nd_gray-25 px-6 py-4 border-b border-nd_gray-200 rounded-t-xl">
        <p className={`${body.md.semibold} text-nd_gray-800`}>
          {"Volume Over Time"->React.string}
        </p>
      </div>
      <div className="p-4">
        <InsightsHelper.Tabs
          option={granularity}
          setOption={setGranularity}
          options={granularityOptions}
          showSingleTab=false
        />
        <LineGraph options />
      </div>
    </div>
  </PageLoaderWrapper>
}
