@react.component
let make = () => {
  open HSAnalyticsUtils
  let (_totalVolume, setTotalVolume) = React.useState(_ => 0)

  let metrics = [
    "payment_success_rate",
    "payment_count",
    "payment_success_count",
  ]->Array.map(key => {
    [("name", key->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
  })

  let singleStatEntity = PaymentOverviewUtils.getSingleStatEntity(metrics)
  let dateDict = HSwitchRemoteFilter.getDateFilteredObject()

  <DynamicSingleStat
    entity={singleStatEntity}
    startTimeFilterKey
    endTimeFilterKey
    filterKeys=[]
    moduleName="Payments"
    defaultStartDate={dateDict.start_time}
    defaultEndDate={dateDict.end_time}
    setTotalVolume
    showPercentage=false
    isHomePage=true
    statSentiment={singleStatEntity.statSentiment->Option.getOr(Dict.make())}
    wrapperClass="flex flex-wrap w-full h-full"
  />
}
