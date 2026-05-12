open InsightsTypes
open InsightsHelper
open SankeyGraphTypes
@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    sankeyPayload,
    sankeyGraphOptions,
    SCAExemptionAnalyticsTypes.scaExemption,
  >,
) => {
  open APIUtils
  open LogicUtils
  open NewAuthenticationAnalyticsUtils
  let getURL = useGetURL()
  let fetchApi = AuthHooks.useApiFetcher()
  let updateDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ =>
    []->SCAExemptionAnalyticsUtils.scaExemptionResponseMapper
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let isSmartRetryEnabled = filterValueJson->getString("is_smart_retry_enabled", "true")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
  let getPaymentLieCycleData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryResponse = if isSampleDataEnabled {
        let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/authentication.json`
        let res = await fetchApi(
          paymentsUrl,
          ~method_=Get,
          ~xFeatureRoute=false,
          ~forceCookies=false,
        )
        let paymentsResponse = await res->(res => res->Fetch.Response.json)

        paymentsResponse->getDictFromJsonObject->getJsonObjectFromDict("exemptionSankeyChartData")
      } else {
        let url = getURL(~entityName=V1(ANALYTICS_SCA_EXEMPTION_SANKEY), ~methodType=Post)
        let scaExemptionBody =
          [
            ("startTime", startTimeVal->JSON.Encode.string),
            ("endTime", endTimeVal->JSON.Encode.string),
          ]->getJsonFromArrayOfJson

        await updateDetails(url, scaExemptionBody, Post)
      }
      let primaryData = primaryResponse->getArrayFromJson([])
      if primaryData->Array.length > 0 {
        let mappedData = primaryData->SCAExemptionAnalyticsUtils.scaExemptionResponseMapper
        setData(_ => mappedData)
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
      getPaymentLieCycleData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, isSmartRetryEnabled, isSampleDataEnabled))

  let params: InsightsTypes.getObjects<SCAExemptionAnalyticsTypes.scaExemption> = {
    data,
    xKey: isSmartRetryEnabled,
    yKey: "",
  }
  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <div className="my-4">
    <Card>
      <NewAuthenticationAnalyticsHelper.ModuleHeader
        title={entity.title} description={entity.description->Option.getOr("")}
      />
      <PageLoaderWrapper
        screenState
        customLoader={<Shimmer layoutId=entity.title />}
        customUI={<NewAnalyticsHelper.NoData />}>
        <div className="my-10">
          <SankeyGraph options={options} className="mr-3" />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
