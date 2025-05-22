open InsightsTypes

@react.component
let make = (~entity: moduleEntity) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (authRateSummaryData, setAuthRateSummaryData) = React.useState(_ => JSON.Encode.array([]))

  let getAuthRateSummary = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryResponse = {
        "success_rate_percent": 72.48,
        "success_orders_percentage": 72.48,
        "soft_declines_percentage": 16.52,
        "hard_declines_percentage": 10.9,
      }->Identity.genericTypeToJson

      setAuthRateSummaryData(_ => primaryResponse->Identity.genericTypeToJson)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getAuthRateSummary()->ignore
    None
  }, [])

  <div className="rounded-xl border border-gray-200 p-4 w-full bg-white">
    <div className="flex items-center justify-start gap-3 mb-4">
      <p className="text-sm text-gray-500"> {"Current Subscription Auth Rate"->React.string} </p>
      <span className="text-sm bg-gray-100 border px-2 py-0.5 rounded-md font-medium">
        {"Without any Retries"->React.string}
      </span>
    </div>
    <p className="text-4xl font-semibold text-gray-800 mb-4"> {"72.48%"->React.string} </p>
  </div>
}
