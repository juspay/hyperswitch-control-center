open InsightsTypes

@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overallRetryStrategyData, setOverallRetryStrategyData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let getOverallRetryStrategy = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryResponse = {
        "success_rate_percent": 72.48,
        "success_orders_percentage": 72.48,
        "soft_declines_percentage": 16.52,
        "hard_declines_percentage": 10.9,
      }->Identity.genericTypeToJson

      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])

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

  <div className="rounded-xl border border-gray-200 w-full bg-white">
    <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
      <h2 className="font-medium text-gray-800"> {entity.title->React.string} </h2>
    </div>
    <div className="p-4">
      <div
        className="h-[300px] w-full bg-gray-50 border border-dashed border-gray-300 rounded-md flex items-center justify-center text-gray-400 text-sm">
        {"Graph placeholder – replace with chart"->React.string}
      </div>
    </div>
  </div>
}
