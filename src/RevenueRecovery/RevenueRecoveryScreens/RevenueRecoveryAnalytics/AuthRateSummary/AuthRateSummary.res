open InsightsTypes
open LogicUtils
open AuthRateSummaryUtils
open BarGraphTypes
open AuthRateSummaryTypes

module LegendItem = {
  @react.component
  let make = (~value, ~itemType: authRateSummaryCols) => {
    let bgColor = switch itemType {
    | SuccessOrdersPercentage => "bg-[#5AAAE3]"
    | SoftDeclinesPercentage => "bg-[#E9BE74]"
    | HardDeclinesPercentage | _ => "bg-[#F8B3AA]"
    }

    <div className="flex items-center space-x-2">
      <span className={`w-4 h-4 ${bgColor} rounded-[4px]`} />
      <div className="flex gap-2">
        <span className="font-medium"> {itemType->getTitleForColumn->React.string} </span>
        <span className="text-gray-500"> {`| ${value->valueFormatter(Rate)}`->React.string} </span>
      </div>
    </div>
  }
}

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
    data
    ->getDictFromJsonObject
    ->itemToAuthRateSummaryObjMapper
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
        {extractSuccessRate(authRateSummaryData).success_rate_percent
        ->valueFormatter(Rate)
        ->React.string}
      </p>
      <BarGraph options className="" />
      <div className="flex gap-7 px-2">
        <LegendItem
          value={extractSuccessRate(authRateSummaryData).success_orders_percentage}
          itemType=SuccessOrdersPercentage
        />
        <LegendItem
          value={extractSuccessRate(authRateSummaryData).soft_declines_percentage}
          itemType=SoftDeclinesPercentage
        />
        <LegendItem
          value={extractSuccessRate(authRateSummaryData).hard_declines_percentage}
          itemType=HardDeclinesPercentage
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
