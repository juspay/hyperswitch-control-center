open RefundsAnalyticsEntity
open APIUtils
open AnalyticsUtils

@react.component
let make = () => {
  let getURL = useGetURL()
  let {generateReport} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
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
      let refundUrl = getURL(~entityName=REFUNDS, ~methodType=Post, ~id=Some("refund-post"), ())
      let body = Dict.make()
      body->Dict.set("limit", 100->Int.toFloat->JSON.Encode.float)
      let refundDetails = await updateDetails(refundUrl, body->JSON.Encode.object, Post, ())
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

  let tabKeys = getStringListFromArrayDict(dimensions)

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

  open AnalyticsNew
  <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
    <div className="flex flex-col gap-5">
      <div className="flex items-center justify-between ">
        <PageUtils.PageHeading title subTitle />
        <UIUtils.RenderIf condition={generateReport}>
          <GenerateReport entityName={REFUND_REPORT} />
        </UIUtils.RenderIf>
      </div>
      <div
        className="-ml-1 sticky top-1 z-30  p-1 bg-hyperswitch_background py-3 -mt-3 rounded-lg border">
        <FilterComponent startTimeFilterKey endTimeFilterKey domain tabKeys />
      </div>
      <div className="flex flex-col gap-14">
        <MetricsState
          heading="Refunds Overview"
          singleStatEntity={metrics->getSingleStatEntity}
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
          getTable={getRefundTable}
          colMapper
          tableEntity={refundTableEntity()->Some}
          deltaMetrics={getStringListFromArrayDict(metrics)}
          deltaArray=[]
          tableGlobalFilter=filterByData
          startTimeFilterKey
          endTimeFilterKey
          heading="Refunds Trends"
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
