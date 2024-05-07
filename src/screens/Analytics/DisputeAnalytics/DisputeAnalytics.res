open DisputeAnalyticsEntity
open APIUtils
open HSAnalyticsUtils

@react.component
let make = () => {
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

  React.useEffect0(() => {
    loadInfo()->ignore
    None
  })

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

  <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
    <Analytics
      pageTitle=title
      pageSubTitle=subTitle
      filterUri={`${Window.env.apiBaseUrl}/analytics/v1/filters/${domain}`}
      key="DisputesAnalytics"
      moduleName="Disputes"
      deltaMetrics={getStringListFromArrayDict(metrics)}
      chartEntity={default: chartEntity(tabKeys)}
      tabKeys
      tabValues
      options
      singleStatEntity={getSingleStatEntity(metrics, ())}
      getTable={getDisputeTable}
      colMapper
      tableEntity={disputeTableEntity()}
      defaultSort="total_volume"
      deltaArray=[]
      tableUpdatedHeading=getUpdatedHeading
      tableGlobalFilter=filterByData
      startTimeFilterKey
      endTimeFilterKey
      initialFilters=initialFilterFields
      initialFixedFilters=initialFixedFilterFields
    />
  </PageLoaderWrapper>
}
