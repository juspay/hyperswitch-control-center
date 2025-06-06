open NewAuthenticationAnalyticsTypes
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
    JSON.Encode.null->SCAExemptionAnalyticsUtils.scaExemptionResponseMapper
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
      if isSampleDataEnabled {
        let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/payments.json`
        let res = await fetchApi(
          paymentsUrl,
          ~method_=Get,
          ~xFeatureRoute=false,
          ~forceCookies=false,
        )
        let paymentsResponse = await res->(res => res->Fetch.Response.json)
        let scaExemptionData =
          paymentsResponse->getDictFromJsonObject->getJsonObjectFromDict("exemptionSankeyChartData")
        setData(_ => scaExemptionData->SCAExemptionAnalyticsUtils.scaExemptionResponseMapper)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        let url = getURL(~entityName=V1(ANALYTICS_SCA_EXEMPTION_SANKEY), ~methodType=Post)
        let scaExemptionBody =
          [
            ("startTime", startTimeVal->JSON.Encode.string),
            ("endTime", endTimeVal->JSON.Encode.string),
          ]->getJsonFromArrayOfJson

        let scaExemptionResponse = await updateDetails(url, scaExemptionBody, Post)
        setScreenState(_ => PageLoaderWrapper.Custom)

        setData(_ => scaExemptionResponse->SCAExemptionAnalyticsUtils.scaExemptionResponseMapper)
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

  let params: NewAuthenticationAnalyticsTypes.getObjects<
    SCAExemptionAnalyticsTypes.scaExemption,
  > = {
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
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <div className="my-10">
          <SankeyGraph options={options} className="mr-3" />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
