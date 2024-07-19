open DisputeAnalyticsEntity
open APIUtils
open AnalyticsUtils

@react.component
let make = () => {
  let getURL = useGetURL()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let fetchDetails = useGetMethod()

  let loadInfo = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    open LogicUtils
    try {
      let infoUrl = getURL(~entityName=ANALYTICS_DISPUTES, ~methodType=Get, ~id=Some("dispute"), ())
      let infoDetails = await fetchDetails(infoUrl)
      setMetrics(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("metrics", []))
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    loadInfo()->ignore
    None
  }, [])

  let tabKeys = getStringListFromArrayDict(dimensions)

  let tabValues = tabKeys->Array.mapWithIndex((key, index) => {
    let a: DynamicTabs.tab = {
      title: key->LogicUtils.snakeToTitle,
      value: key,
      isRemovable: index > 2,
    }
    a
  })

  let title = "Disputes Analytics"
  let subTitle = "Gain Insights, monitor performance and make Informed Decisions with Dispute Analytics."

  open AnalyticsNew
  <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
    <div className="flex flex-col gap-5">
      <div className="flex items-center justify-between ">
        <PageUtils.PageHeading title subTitle />
      </div>
      <div
        className="-ml-1 sticky top-1 z-30  p-1 bg-hyperswitch_background py-3 -mt-3 rounded-lg border">
        <FilterComponent startTimeFilterKey endTimeFilterKey domain tabKeys />
      </div>
      <div className="flex flex-col gap-14">
        <MetricsState
          heading="Disputes Overview"
          singleStatEntity={getSingleStatEntity(metrics, ())}
          filterKeys=tabKeys
          startTimeFilterKey
          endTimeFilterKey
          moduleName="general_metrics"
        />
        <OverallSummary
          filteredTabVales=tabValues
          moduleName="overall_summary"
          filteredTabKeys={tabKeys}
          chartEntity={chartEntity(tabKeys)}
          defaultSort="total_volume"
          getTable={getDisputeTable}
          colMapper
          tableEntity={disputeTableEntity()->Some}
          deltaMetrics={getStringListFromArrayDict(metrics)}
          deltaArray=[]
          tableGlobalFilter=filterByData
          startTimeFilterKey
          endTimeFilterKey
          heading="Disputes Trends"
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
