open InsightsTypes
open OverallRetryStrategyAnalyticsUtils

@react.component
let make = (~entity: moduleEntity, ~chartEntity) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overallRetryStrategyData, setOverallRetryStrategyData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let getOverallRetryStrategy = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(~entityName=V1(MONTHLY_RETRY_SUCCESS), ~methodType=Get)
      let primaryResponse = await fetchDetails(url, ~version=V1)

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
    customUI={<NewAnalyticsHelper.NoData height="h-64 p-0 -m-0" />}>
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
