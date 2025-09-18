open RefundsAnalyticsEntity
open APIUtils
open HSAnalyticsUtils

@react.component
let make = () => {
  let getURL = useGetURL()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let loadInfo = async () => {
    open LogicUtils
    try {
      let infoUrl = getURL(~entityName=V1(ANALYTICS_REFUNDS), ~methodType=Get, ~id=Some(domain))
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
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let getRefundDetails = async () => {
    open LogicUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let refundUrl = getURL(~entityName=V1(REFUNDS), ~methodType=Post, ~id=Some("refund-post"))
      let body = Dict.make()
      body->Dict.set("limit", 100->Int.toFloat->JSON.Encode.float)
      let refundDetails = await updateDetails(refundUrl, body->JSON.Encode.object, Post)
      let data = refundDetails->getDictFromJsonObject->getArrayFromDict("data", [])

      if data->Array.length < 1 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      } else {
        await loadInfo()
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  React.useEffect(() => {
    getRefundDetails()->ignore
    None
  }, [])

  let tabKeys = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)

  let tabValues = tabKeys->Array.mapWithIndex((key, index) => {
    let a: DynamicTabs.tab = {
      title: key->LogicUtils.snakeToTitle,
      value: key,
      isRemovable: index > 2,
    }
    a
  })

  let title = "Refunds Analytics"

  let analyticsfilterUrl = getURL(
    ~entityName=V1(ANALYTICS_FILTERS),
    ~methodType=Post,
    ~id=Some(domain),
  )
  let refundAnalyticsUrl = getURL(
    ~entityName=V1(ANALYTICS_PAYMENTS),
    ~methodType=Post,
    ~id=Some(domain),
  )
  <PageLoaderWrapper screenState customUI={<NoData title />}>
    <Analytics
      pageTitle=title
      filterUri=Some(analyticsfilterUrl)
      key="RefundsAnalytics"
      moduleName="Refunds"
      deltaMetrics=["refund_success_rate", "refund_count", "refund_success_count"]
      chartEntity={default: chartEntity(tabKeys, ~uri=refundAnalyticsUrl)}
      tabKeys
      tabValues
      options={options}
      singleStatEntity={getSingleStatEntity(metrics, refundAnalyticsUrl)}
      getTable={getRefundTable}
      colMapper
      tableEntity={refundTableEntity(~uri=refundAnalyticsUrl)}
      defaultSort="total_volume"
      deltaArray=[]
      tableUpdatedHeading=getUpdatedHeading
      tableGlobalFilter={filterByData}
      startTimeFilterKey={startTimeFilterKey}
      endTimeFilterKey={endTimeFilterKey}
      initialFilters={initialFilterFields}
      initialFixedFilters={initialFixedFilterFields}
    />
  </PageLoaderWrapper>
}
