open InsightsTypes
open RetriesComparisionAnalyticsUtils
open RetriesComparisionAnalyticsTypes

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    LineScatterGraphTypes.lineScatterGraphPayload,
    LineScatterGraphTypes.lineScatterGraphOptions,
    JSON.t,
  >,
) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (staticRetryData, setStaticRetryData) = React.useState(_ => JSON.Encode.array([]))
  let (smartRetryData, setSmartRetryData) = React.useState(_ => JSON.Encode.array([]))

  let getRetryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(~entityName=V1(RETRY_ATTEMPTS_TREND), ~methodType=Get)
      let primaryResponse = await fetchDetails(url, ~version=V1)

      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getObj((#retry_attempts_trend: retryAttemptsTrendKeys :> string), Dict.make())

      let staticRetryData = primaryData->getArrayFromDict(StaticRetries->getStringFromVariant, [])

      let smartRetryData = primaryData->getArrayFromDict(SmartRetries->getStringFromVariant, [])

      setStaticRetryData(_ => staticRetryData->Identity.genericTypeToJson)
      setSmartRetryData(_ => smartRetryData->Identity.genericTypeToJson)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    getRetryData()->ignore
    None
  }, [])

  let params1 = {
    data: staticRetryData,
    xKey: StaticRetries->getStringFromVariant->snakeToTitle,
    yKey: TimeBucket->getStringFromVariant,
  }

  let params2 = {
    data: smartRetryData,
    xKey: SmartRetries->getStringFromVariant->snakeToTitle,
    yKey: TimeBucket->getStringFromVariant,
  }

  let staticRetryGraphOptions = chartEntity.getChatOptions(chartEntity.getObjects(~params=params1))

  let smartRetryGraphOptions = chartEntity.getChatOptions(
    smartRetriesComparisionMapper(~params=params2),
  )

  <div>
    <div className="space-y-1 mb-5">
      <h2 className="text-xl font-semibold text-gray-900"> {entity.title->React.string} </h2>
      <p className="text-gray-500">
        {"Static Retries are executed based on predefined rules, whereas Smart Retries are dynamically triggered"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customLoader={<InsightsHelper.Shimmer layoutId=entity.title className="h-64 rounded-lg" />}
      customUI={<InsightsHelper.NoData height="h-64 p-0 -m-0" />}>
      <div className="grid grid-cols-2 gap-5">
        <div className="rounded-xl border border-gray-200 w-full bg-white">
          <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
            <h2 className="font-medium text-gray-800">
              {"Static Current Retries"->React.string}
            </h2>
          </div>
          <div className="p-4">
            <LineScatterGraph options={staticRetryGraphOptions} className="mr-3" />
          </div>
        </div>
        <div className="rounded-xl border border-gray-200 w-full bg-white">
          <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
            <h2 className="font-medium text-gray-800"> {"Smart Retries"->React.string} </h2>
          </div>
          <div className="p-4">
            <LineScatterGraph options={smartRetryGraphOptions} className="mr-3" />
          </div>
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
