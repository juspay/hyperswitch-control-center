@react.component
let make = () => {
  open LogicUtils
  open Typography
  open APIUtils
  open LeastCostRoutingAnalyticsDistributionUtils
  open LeastCostRoutingAnalyticsDistributionTypes
  open NewAnalyticsUtils
  open NewAnalyticsHelper
  open NewAnalyticsTypes
  open LeastCostRoutingAnalyticsTypes

  let (response, setResponse) = React.useState(_ => JSON.Encode.null)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let (granularityTabState, setGranularityTabState) = React.useState(_ =>
    RoutingAnalyticsUtils.defaultGranularityOptionsObject
  )
  let granularityOptions = getGranularityOptions(~startTime=startTimeVal, ~endTime=endTimeVal)

  let getData = async (~granularityValue) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Post, ~id=Some("payments"))
      let body =
        [
          AnalyticsUtils.getFilterRequestBody(
            ~metrics=Some([(#sessionized_debit_routing: requestPayloadMetrics :> string)]),
            ~delta=false,
            ~startDateTime=startTimeVal,
            ~endDateTime=endTimeVal,
            ~granularity=Some(granularityValue),
            ~filter=Some(filterDict),
          )->JSON.Encode.object,
        ]->JSON.Encode.array

      let response = await updateDetails(url, body, Post)
      let responseData = response->getDictFromJsonObject->getArrayFromDict("queryData", [])

      if responseData->Array.length == 0 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      } else {
        let editedData = modifySavingsQueryData(~data=responseData)->sortQueryDataByDate
        let modifieddata = fillMissingDataForSavingsGraph(
          ~data=editedData,
          ~startDate=startTimeVal,
          ~endDate=endTimeVal,
          ~defaultValue={
            "debit_routing_savings_in_usd": 0,
            "time_bucket": startTimeVal,
          }->Identity.genericTypeToJson,
          ~timeKey="time_bucket",
          ~granularity=granularityValue,
          ~isoStringToCustomTimeZone,
          ~granularityEnabled=featureFlag.granularity,
        )

        setResponse(_ => modifieddata->Identity.genericTypeToJson)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Error fetching data"))
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
      getData(~granularityValue=defaultGranularity.value)->ignore
    }
    None
  }, (startTimeVal, endTimeVal))

  let params = {
    data: response,
    xKey: (#time_bucket: requestPayloadMetrics :> string),
    yKey: (#debit_routing_savings_in_usd: requestPayloadMetrics :> string),
  }

  let chartOptions = {
    savingsChartOptions(
      ~params,
      ~config=savingsTimeConfig,
      ~tooltipValueFormatterType=LogicUtilsTypes.Amount,
    )
  }

  let setGranularity = (option: optionType) => {
    setGranularityTabState(_ => option)
    getData(~granularityValue=option.value)->ignore
  }

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-72" />}
    customLoader={<Shimmer styleClass="w-full  h-22-rem rounded-xl" />}>
    <div className="flex flex-col">
      <div className="border rounded-xl py-2 px-4 border-nd_gray-200 rounded-b-none bg-nd_gray-25">
        <p className={`text-nd_gray-600 px-3 py-10-px ${body.md.semibold}`}>
          {"Savings over time"->React.string}
        </p>
      </div>
      <div
        className="border rounded-xl border-t-0 border-nd_gray-200 h-22-rem rounded-t-none pt-2 px-2">
        <Tabs
          option={granularityTabState}
          setOption={setGranularity}
          options={granularityOptions}
          showSingleTab=false
        />
        <LineGraph options={chartOptions} />
      </div>
    </div>
  </PageLoaderWrapper>
}
