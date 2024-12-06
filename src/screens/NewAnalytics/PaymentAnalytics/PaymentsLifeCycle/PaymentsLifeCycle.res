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
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(~entityName=ANALYTICS_SANKEY, ~methodType=Post)
      let paymentLifeCycleBody =
        [
          ("startTime", startTimeVal->JSON.Encode.string),
          ("endTime", endTimeVal->JSON.Encode.string),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object

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
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getPaymentLieCycleData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, isSmartRetryEnabled))

  let params = {
    data,
    xKey: isSmartRetryEnabled,
    yKey: "",
  }

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <div className="mr-3 my-10">
          <SankeyGraph entity={chartEntity} data={chartEntity.getObjects(~params)} />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
