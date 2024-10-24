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

  let getPaymentLieCycleData = async () => {
    try {
      let url = getURL(~entityName=ANALYTICS_SANKEY, ~methodType=Post)
      let paymentLifeCycleBody =
        [
          ("startTime", startTimeVal->JSON.Encode.string),
          ("endTime", endTimeVal->JSON.Encode.string),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object
      // Expected response
      // let response = {
      //   "normal_success": 15,
      //   "normal_failure": 1,
      //   "cancelled": 1,
      //   "smart_retried_success": 1,
      //   "smart_retried_failure": 0,
      //   "pending": 0,
      //   "partial_refunded": 0,
      //   "refunded": 0,
      //   "disputed": 0,
      //   "pm_awaited": 0,
      //   "customer_awaited": 2,
      //   "merchant_awaited": 0,
      //   "confirmation_awaited": 0,
      // }->Identity.genericTypeToJson
      let paymentLifeCycleResponse = await updateDetails(url, paymentLifeCycleBody, Post)
      setData(_ => paymentLifeCycleResponse->PaymentsLifeCycleUtils.paymentLifeCycleResponseMapper)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getPaymentLieCycleData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal))

  let mockDelay = async () => {
    if data != JSON.Encode.null->PaymentsLifeCycleUtils.paymentLifeCycleResponseMapper {
      setScreenState(_ => Loading)
      await HyperSwitchUtils.delay(300)
      setScreenState(_ => Success)
    }
  }

  React.useEffect(() => {
    mockDelay()->ignore
    None
  }, [isSmartRetryEnabled])

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <div className="mr-3 my-10">
          <SankeyGraph
            entity={chartEntity}
            data={chartEntity.getObjects(~data, ~xKey=isSmartRetryEnabled, ~yKey="")}
          />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
