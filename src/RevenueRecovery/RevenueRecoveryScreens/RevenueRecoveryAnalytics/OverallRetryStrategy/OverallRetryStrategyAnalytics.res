open InsightsTypes
open OverallRetryStrategyAnalyticsUtils

@react.component
let make = (~entity: moduleEntity, ~chartEntity) => {
  open LogicUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overallRetryStrategyData, setOverallRetryStrategyData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let getOverallRetryStrategy = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryResponse = {
        "data": [
          {
            "time_bucket": "2024-01-01T00:00:00Z",
            "transactions": 0,
            "static_retry_success_rate": 70.5,
            "smart_retry_success_rate": 0,
            "smart_retry_booster_success_rate": 0,
          }->Identity.genericTypeToJson,
          {
            "time_bucket": "2024-02-01T00:00:00Z",
            "transactions": 0,
            "static_retry_success_rate": 68.2,
            "smart_retry_success_rate": 10.1,
            "smart_retry_booster_success_rate": 5.4,
          }->Identity.genericTypeToJson,
          {
            "time_bucket": "2024-03-01T00:00:00Z",
            "transactions": 56000,
            "static_retry_success_rate": 65.3,
            "smart_retry_success_rate": 60.2,
            "smart_retry_booster_success_rate": 62.7,
          }->Identity.genericTypeToJson,
        ],
      }->Identity.genericTypeToJson

      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("data", [])

      setOverallRetryStrategyData(_ => primaryData->Identity.genericTypeToJson)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getOverallRetryStrategy()->ignore
    None
  }, [])

  let params = {
    data: overallRetryStrategyData,
    xKey: TimeBucket->getStringFromVariant,
    yKey: "",
  }

  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <PageLoaderWrapper
    screenState
    customLoader={<InsightsHelper.Shimmer layoutId=entity.title className="h-64 rounded-lg" />}
    customUI={<InsightsHelper.NoData />}>
    <div className="rounded-xl border border-gray-200 w-full bg-white">
      <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
        <h2 className="font-medium text-gray-800"> {entity.title->React.string} </h2>
      </div>
      <div className="p-4">
        <LineAndColumnGraph options />
      </div>
    </div>
  </PageLoaderWrapper>
}
