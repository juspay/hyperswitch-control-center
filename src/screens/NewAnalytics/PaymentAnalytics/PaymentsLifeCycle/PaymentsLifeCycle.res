open NewAnalyticsTypes
open NewAnalyticsHelper
open SankeyGraphTypes
@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    sankeyPayload,
    sankeyGraphOptions,
    PaymentsLifeCycleTypes.paymentLifeCycle,
  >,
) => {
  open APIUtils
  open LogicUtils
  open NewAnalyticsContainerUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ =>
    JSON.Encode.null->PaymentsLifeCycleUtils.paymentLifeCycleResponseMapper
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let isSmartRetryEnabled = filterValueJson->getString("is_smart_retry_enabled", "true")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
  let fetchApi = AuthHooks.useApiFetcher()
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
        let paymentLifecycleData =
          paymentsResponse->getDictFromJsonObject->getJsonObjectFromDict("paymentLifecycleData")
        setData(_ =>
          paymentLifecycleData->PaymentsLifeCycleUtils.paymentLifeCycleResponseMapper(
            ~isSmartRetryEnabled=isSmartRetryEnabled->LogicUtils.getBoolFromString(true),
          )
        )
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        let url = getURL(~entityName=V1(ANALYTICS_SANKEY), ~methodType=Post)
        let paymentLifeCycleBody =
          [
            ("startTime", startTimeVal->JSON.Encode.string),
            ("endTime", endTimeVal->JSON.Encode.string),
          ]->getJsonFromArrayOfJson

        let paymentLifeCycleResponse = await updateDetails(url, paymentLifeCycleBody, Post)
        if paymentLifeCycleResponse->PaymentsLifeCycleUtils.getTotalPayments > 0 {
          setData(_ =>
            paymentLifeCycleResponse->PaymentsLifeCycleUtils.paymentLifeCycleResponseMapper(
              ~isSmartRetryEnabled=isSmartRetryEnabled->LogicUtils.getBoolFromString(true),
            )
          )
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          setScreenState(_ => PageLoaderWrapper.Custom)
        }
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

  let params = {
    data,
    xKey: isSmartRetryEnabled,
    yKey: "",
  }

  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <div className="my-10">
          <SankeyGraph options={options} className="mr-3" />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
