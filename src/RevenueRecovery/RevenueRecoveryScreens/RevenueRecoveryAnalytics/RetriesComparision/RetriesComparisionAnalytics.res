open InsightsTypes

@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (retriesComparisionData, setRetriesComparisionData) = React.useState(_ =>
    JSON.Encode.array([])
  )

  let getRetriesComparision = async () => {
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

      setRetriesComparisionData(_ => primaryData->Identity.genericTypeToJson)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getRetriesComparision()->ignore
    None
  }, [])

  <div>
    <div className="space-y-1 mb-5">
      <h2 className="text-xl font-semibold text-gray-900"> {entity.title->React.string} </h2>
      <p className="text-gray-500">
        {"Static Retries are executed based on predefined rules, whereas Smart Retries are dynamically triggered"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-2 gap-5">
      <div className="rounded-xl border border-gray-200 w-full bg-white">
        <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
          <h2 className="font-medium text-gray-800"> {"Static Current Retries"->React.string} </h2>
        </div>
        <div className="p-4">
          <div
            className="h-[300px] w-full bg-gray-50 border border-dashed border-gray-300 rounded-md flex items-center justify-center text-gray-400 text-sm">
            {"Graph placeholder – replace with chart"->React.string}
          </div>
        </div>
      </div>
      <div className="rounded-xl border border-gray-200 w-full bg-white">
        <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
          <h2 className="font-medium text-gray-800"> {"Smart Retries"->React.string} </h2>
        </div>
        <div className="p-4">
          <div
            className="h-[300px] w-full bg-gray-50 border border-dashed border-gray-300 rounded-md flex items-center justify-center text-gray-400 text-sm">
            {"Graph placeholder – replace with chart"->React.string}
          </div>
        </div>
      </div>
    </div>
  </div>
}
