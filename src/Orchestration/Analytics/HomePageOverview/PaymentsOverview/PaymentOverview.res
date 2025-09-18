@react.component
let make = () => {
  open HSAnalyticsUtils
  open APIUtils
  let getURL = useGetURL()
  let metrics = [
    "payment_success_rate",
    "payment_count",
    "payment_success_count",
  ]->Array.map(key => {
    [("name", key->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
  })
  let analyticsUrl = getURL(
    ~entityName=V1(ANALYTICS_PAYMENTS),
    ~methodType=Post,
    ~id=Some("payments"),
  )

  let singleStatEntity = PaymentOverviewUtils.getSingleStatEntity(metrics, analyticsUrl)
  let dateDict = HSwitchRemoteFilter.getDateFilteredObject()

  <DynamicSingleStat
    entity={singleStatEntity}
    startTimeFilterKey
    endTimeFilterKey
    filterKeys=[]
    moduleName="Payments"
    defaultStartDate={dateDict.start_time}
    defaultEndDate={dateDict.end_time}
    showPercentage=false
    statSentiment={singleStatEntity.statSentiment->Option.getOr(Dict.make())}
    wrapperClass="w-full h-full -mt-4"
  />
}
