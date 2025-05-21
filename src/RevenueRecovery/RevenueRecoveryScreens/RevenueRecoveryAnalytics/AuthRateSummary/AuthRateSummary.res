open InsightsTypes
open InsightsHelper
open AuthRateSummaryTypes

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    LineGraphTypes.lineGraphPayload,
    LineGraphTypes.lineGraphOptions,
    JSON.t,
  >,
) => {
  open LogicUtils
  open APIUtils
  open InsightsUtils
  open InsightsContainerUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (refundsProcessedData, setAuthRateSummaryData) = React.useState(_ => JSON.Encode.array([]))

  let getAuthRateSummary = async () => {
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
        ->modifyQueryData(~currency)
        ->sortQueryDataByDate
      let primaryMetaData = primaryResponse->getDictFromJsonObject->getArrayFromDict("metaData", [])
      setAuthRateSummaryTableData(_ => primaryData)

      setAuthRateSummaryData(_ =>
        primaryData->Array.concat(secondaryModifiedData)->Identity.genericTypeToJson
      )
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getAuthRateSummary()->ignore
    None
  }, [])

  let params = {
    data: refundsProcessedData,
    xKey: selectedMetric.value->getKeyForModule,
    yKey: Time_Bucket->getStringFromVariant,
    comparison,
    currency,
  }

  let options = chartEntity.getObjects(~params)->chartEntity.getChatOptions

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <div className="mb-5">
          <LineGraph options className="mr-3" />
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
