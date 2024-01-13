open RefundsAnalyticsEntity
open APIUtils
open HSAnalyticsUtils

@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let loadInfo = async () => {
    open LogicUtils
    try {
      let infoUrl = getURL(~entityName=ANALYTICS_REFUNDS, ~methodType=Get, ~id=Some(domain), ())
      let infoDetails = await fetchDetails(infoUrl)
      setMetrics(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("metrics", []))
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let getRefundDetails = async () => {
    open LogicUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let refundUrl = getURL(~entityName=REFUNDS, ~methodType=Post, ~id=Some("refund-post"), ())
      let body = Dict.make()
      body->Dict.set("limit", 100->Belt.Int.toFloat->Js.Json.number)
      let refundDetails = await updateDetails(refundUrl, body->Js.Json.object_, Post)
      let data = refundDetails->getDictFromJsonObject->getArrayFromDict("data", [])

      if data->Array.length < 1 {
        setScreenState(_ => PageLoaderWrapper.Custom)
      } else {
        await loadInfo()
      }
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  React.useEffect0(() => {
    getRefundDetails()->ignore
    None
  })

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
  let subTitle = "Uncover patterns and drive business performance through data-driven insights with refund analytics"

  <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
    <Analytics
      pageTitle=title
      pageSubTitle=subTitle
      filterUri={`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/filters/${domain}`}
      key="RefundsAnalytics"
      moduleName="Refunds"
      deltaMetrics={getStringListFromArrayDict(metrics)}
      chartEntity={default: chartEntity(tabKeys)}
      tabKeys
      tabValues
      options={options}
      singleStatEntity={getSingleStatEntity(metrics)}
      getTable={getRefundTable}
      colMapper
      tableEntity={refundTableEntity}
      defaultSort="total_volume"
      deltaArray=[]
      tableUpdatedHeading=getUpdatedHeading
      tableGlobalFilter={filterByData}
      startTimeFilterKey={startTimeFilterKey}
      endTimeFilterKey={endTimeFilterKey}
      initialFilters={initialFilterFields}
      initialFixedFilters={initialFixedFilterFields}
      generateReportType={REFUND_REPORT}
    />
  </PageLoaderWrapper>
}
