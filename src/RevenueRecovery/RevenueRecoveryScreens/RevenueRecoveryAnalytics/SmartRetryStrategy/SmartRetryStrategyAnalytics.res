open InsightsTypes
open SmartRetryStrategyAnalyticsUtils
@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overallSRData, setOverallSRData) = React.useState(_ => [])
  let (groupSRData, setGroupSRData) = React.useState(_ => [])

  let getOverallSR = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(~entityName=V1(ERROR_CATEGORY_ANALYSIS), ~methodType=Get)
      let primaryResponse = await fetchDetails(url, ~version=V1)

      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getObj("error_category_analysis", Dict.make())

      let overallData = primaryData->getArrayFromDict(OverallSuccessRate->getStringFromVariant, [])
      let groupWiseData = primaryData->getArrayFromDict(GroupwiseData->getStringFromVariant, [])

      setOverallSRData(_ => overallData)
      setGroupSRData(_ => groupWiseData)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getOverallSR()->ignore
    None
  }, [])

  let getSmartRetryGraphOptions = data => {
    data->Array.map(item => {
      let params = {
        data: item,
        xKey: "",
        yKey: TimeBucket->getStringFromVariant,
      }

      let itemDict = item->getDictFromJsonObject
      let title = itemDict->getString(GroupName->getStringFromVariant, "")

      (title, LineScatterGraphUtils.getLineGraphOptions(smartRetriesMapper(~params)))
    })
  }

  let getMainChartOptions = data => {
    let params = {
      data: data->Identity.genericTypeToJson,
      xKey: SuccessRate->getStringFromVariant,
      yKey: TimeBucket->getStringFromVariant,
    }

    LineGraphUtils.getLineGraphOptions(overallSRMapper(~params))
  }

  <div>
    <div className="space-y-1 mb-5">
      <h2 className="text-xl font-semibold text-gray-900 mb-2"> {entity.title->React.string} </h2>
      <div className="bg-gray-50 text-gray-700 p-3 rounded-md border flex gap-2">
        <Icon size=15 name="info-circle-unfilled" />
        {"Smart retries are attempted by targeting specific error groups where the probability of success is highest."->React.string}
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customLoader={<InsightsHelper.Shimmer layoutId=entity.title className="h-64 rounded-lg" />}
      customUI={<InsightsHelper.NoData height="h-64 p-0 -m-0" />}>
      <div className="flex flex-col gap-5">
        <div className="rounded-xl border border-gray-200 w-full bg-white">
          <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
            <h2 className="font-medium text-gray-800">
              {"Error Category : Do Not Honor"->React.string}
            </h2>
          </div>
          <div className="p-4">
            <LineGraph options={overallSRData->getMainChartOptions} className="mr-3" />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-5">
          {groupSRData
          ->getSmartRetryGraphOptions
          ->Array.map(item => {
            let (title, options) = item

            <div className="rounded-xl border border-gray-200 w-full bg-white">
              <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
                <h2 className="font-medium text-gray-800"> {title->React.string} </h2>
              </div>
              <div className="p-4">
                <LineScatterGraph options className="mr-3" />
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
