open DisputeAnalyticsEntity
open APIUtils
open HSAnalyticsUtils

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
      let infoUrl = getURL(~entityName=V1(ANALYTICS_DISPUTES), ~methodType=Get, ~id=Some("dispute"))
      let infoDetails = await fetchDetails(infoUrl)
      let metrics =
        infoDetails
        ->getDictFromJsonObject
        ->getArrayFromDict("metrics", [])
        ->AnalyticsUtils.filterMetrics
      setMetrics(_ => metrics)
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

  let analyticsfilterUrl = getURL(
    ~entityName=V1(ANALYTICS_FILTERS),
    ~methodType=Post,
    ~id=Some(domain),
  )
  let disputeAnalyticsUrl = getURL(
    ~entityName=V1(ANALYTICS_PAYMENTS),
    ~methodType=Post,
    ~id=Some(domain),
  )
  <PageLoaderWrapper screenState customUI={<NoData title />}>
    <Analytics
      pageTitle=title
      filterUri=Some(analyticsfilterUrl)
      key="DisputesAnalytics"
      moduleName="Disputes"
      deltaMetrics={getStringListFromArrayDict(metrics)}
      chartEntity={default: chartEntity(tabKeys, ~uri=disputeAnalyticsUrl)}
      tabKeys
      tabValues
      options
      singleStatEntity={getSingleStatEntity(metrics, ~uri=disputeAnalyticsUrl)}
      getTable={getDisputeTable}
      colMapper
      tableEntity={disputeTableEntity(~uri=disputeAnalyticsUrl)}
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
