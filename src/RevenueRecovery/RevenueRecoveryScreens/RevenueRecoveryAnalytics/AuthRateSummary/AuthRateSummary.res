open InsightsTypes
open LogicUtils
open AuthRateSummaryUtils
open BarGraphTypes
open AuthRateSummaryTypes

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<barGraphPayload, barGraphOptions, JSON.t>,
) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (authRateSummaryData, setAuthRateSummaryData) = React.useState(_ => JSON.Encode.array([]))

  let getAuthRateSummary = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryResponse = {
        "success_rate_percent": 72.49,
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

  let extractSuccessRate = data => {
    (
      data
      ->getDictFromJsonObject
      ->itemToAuthRateSummaryObjMapper
    ).success_rate_percent
  }

  let params = {
    data: authRateSummaryData,
    xKey: SuccessOrdersPercentage->getStringFromVariant,
    yKey: SuccessOrdersPercentage->getStringFromVariant,
  }

  let options = chartEntity.getChatOptions(chartEntity.getObjects(~params))

  <PageLoaderWrapper
    screenState
    customLoader={<InsightsHelper.Shimmer layoutId=entity.title className="h-48 rounded-lg" />}
    customUI={<InsightsHelper.NoData />}>
    <div className="rounded-xl border border-gray-200 p-4 w-full bg-white">
      <div className="flex items-center justify-start gap-3 mb-4">
        <p className="text-sm text-gray-500"> {"Current Subscription Auth Rate"->React.string} </p>
        <span className="text-sm bg-gray-100 border px-2 py-0.5 rounded-md font-medium">
          {"Without any Retries"->React.string}
        </span>
      </div>
      <p className="text-4xl font-semibold text-gray-800">
        {extractSuccessRate(authRateSummaryData)
        ->LogicUtils.valueFormatter(Rate)
        ->React.string}
      </p>
      <BarGraph options className="" />
    </div>
  </PageLoaderWrapper>
}
