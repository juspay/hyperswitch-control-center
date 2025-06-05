open NewAuthenticationAnalyticsTypes
open InsightsHelper
open ExemptionGraphsUtils
open NewAuthenticationAnalyticsUtils
open InsightsUtils

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    LineGraphTypes.lineGraphPayload,
    LineGraphTypes.lineGraphOptions,
    JSON.t,
  >,
  ~metricXKey: string,
) => {
  open LogicUtils
  open APIUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchApi = AuthHooks.useApiFetcher()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (authenticationSuccessData, setAuthenticationSuccessData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let compareToStartTime = filterValueJson->getString("compareToStartTime", "")
  let compareToEndTime = filterValueJson->getString("compareToEndTime", "")
  let comparison =
    filterValueJson
    ->getString("comparison", "")
    ->DateRangeUtils.comparisonMapprer
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let defaulGranularity = getDefaultGranularity(
    ~startTime=startTimeVal,
    ~endTime=endTimeVal,
    ~granularity=featureFlag.granularity,
  )
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setGranularity(_ => defaulGranularity)
    }
    None
  }, (startTimeVal, endTimeVal))

  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
  let getPaymentsProcessed = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_AUTHENTICATION_V2),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )
      let primaryResponse = if isSampleDataEnabled {
        // let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/payments.json`
        // let res = await fetchApi(
        //   paymentsUrl,
        //   ~method_=Get,
        //   ~xFeatureRoute=false,
        //   ~forceCookies=false,
        // )
        // let paymentsResponse = await res->(res => res->Fetch.Response.json)
        let paymentsResponse = authDummyData
        paymentsResponse
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("authenticationLifeCycleData")
      } else {
        let primaryBody = NewAuthenticationAnalyticsUtils.requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~delta=entity.requestBodyConfig.delta,
          ~metrics=entity.requestBodyConfig.metrics,
          ~granularity=granularity.value->Some,
          ~filter=Some(getUpdatedFilterValueJson(filterValueJson)->JSON.Encode.object),
        )
        await updateDetails(url, primaryBody, Post)
      }
      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->modifyQueryData
        ->sortQueryDataByDate

      if primaryData->Array.length > 0 {
        let primaryModifiedData = [primaryData]->Array.map(data => {
          fillMissingDataPoints(
            ~data,
            ~startDate=startTimeVal,
            ~endDate=endTimeVal,
            ~timeKey="time_bucket",
            ~defaultValue={
              "authentication_count": 0,
              "authentication_success_count": 0,
              "authentication_attempt_count": 0,
              "authentication_exemption_requested": 0,
              "authentication_exemption_accepted": 0,
              "time_bucket": startTimeVal,
            }->Identity.genericTypeToJson,
            ~granularity=granularity.value,
            ~isoStringToCustomTimeZone,
            ~granularityEnabled=featureFlag.granularity,
          )
        })

        setAuthenticationSuccessData(_ => primaryModifiedData->Identity.genericTypeToJson)

        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getPaymentsProcessed()->ignore
    }
    None
  }, (
    startTimeVal,
    endTimeVal,
    compareToStartTime,
    compareToEndTime,
    comparison,
    granularity.value,
    currency,
    isSampleDataEnabled,
  ))

  let params = {
    data: authenticationSuccessData,
    xKey: metricXKey,
    yKey: Time_Bucket->getStringFromVariant,
    title: entity.title,
    comparison,
  }

  let options = chartEntity.getObjects(~params)->chartEntity.getChatOptions

  <Card>
    <NewAuthenticationAnalyticsHelper.ModuleHeader
      title={entity.title} description={entity.description->Option.getOr("")}
    />
    <PageLoaderWrapper
      screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
      <div className="mx-5">
        <LineGraph options className="mr-3" />
      </div>
    </PageLoaderWrapper>
  </Card>
}
