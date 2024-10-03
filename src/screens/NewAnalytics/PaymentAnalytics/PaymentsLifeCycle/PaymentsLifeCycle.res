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
  let getPaymentLieCycleData = async () => {
    try {
      let url = getURL(~entityName=ANALYTICS_SANKEY, ~methodType=Post)
      let paymentLifeCycleBody = NewAnalyticsUtils.requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~dimensions=[],
        ~metrics=[],
      )
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
    getPaymentLieCycleData()->ignore
    None
  }, [])
  <div>
    <ModuleHeader title={entity.title} />
    <PageLoaderWrapper
      screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
      <Card>
        <div className="mr-3 my-10">
          <SankeyGraph
            entity={chartEntity} data={chartEntity.getObjects(~data, ~xKey="", ~yKey="")}
          />
        </div>
      </Card>
    </PageLoaderWrapper>
  </div>
}
