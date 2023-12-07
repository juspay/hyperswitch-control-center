@react.component
let make = (~index) => {
  open HSAnalyticsUtils
  let (_totalVolume, setTotalVolume) = React.useState(_ => 0)

  let metrics = [
    "payment_success_rate",
    "payment_count",
    "payment_success_count",
  ]->Js.Array2.map(key => {
    [("name", key->Js.Json.string)]->Js.Dict.fromArray->Js.Json.object_
  })

  let singleStatEntity = PaymentOverviewUtils.getSingleStatEntity(metrics)
  let dateDict = HSwitchRemoteFilter.getDateFilteredObject()

  <DynamicSingleStat
    index
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
    statSentiment={singleStatEntity.statSentiment->Belt.Option.getWithDefault(Js.Dict.empty())}
    wrapperClass="flex flex-wrap w-full h-full"
  />
}
