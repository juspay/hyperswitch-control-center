open UserJourneyAnalyticsEntity

open APIUtils
open HSAnalyticsUtils

@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let fetchDetails = useGetMethod()

  let loadInfo = async () => {
    open LogicUtils
    try {
      let infoUrl = getURL(
        ~entityName=ANALYTICS_USER_JOURNEY,
        ~methodType=Get,
        ~id=Some(domain),
        (),
      )
      let infoDetails = await fetchDetails(infoUrl)
      setMetrics(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("metrics", []))
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  let getUserJourneysData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      await loadInfo()
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    getUserJourneysData()->ignore
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

  <div className="flex flex-col flex-1 overflow-scroll">
    <PageLoaderWrapper screenState customUI={<NoData />}>
      <Analytics
        pageTitle="Know your users"
        pageSubTitle="User analytics is a level deeper into payment analytics and aims at providing you a wholesome understanding of the end users and their usage patterns."
        filterUri={`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/filters/${domain}`}
        key="UserJourneyAnalytics"
        moduleName="UserJourney"
        deltaMetrics={getStringListFromArrayDict(metrics)}
        chartEntity={
          default: paymentChartEntity(tabKeys),
          userPieChart: userChartEntity(tabKeys),
          userBarChart: userBarChartEntity(tabKeys),
          userFunnelChart: userJourneyFunnelChartEntity(tabKeys),
        }
        tabKeys
        tabValues
        options
        singleStatEntity={getSingleStatEntity(metrics)}
        getTable={_ => []}
        colMapper={_ => ""}
        defaultSort="total_volume"
        deltaArray=[]
        tableGlobalFilter=filterByData
        startTimeFilterKey
        endTimeFilterKey
        initialFilters=initialFilterFields
        initialFixedFilters=initialFixedFilterFields
      />
    </PageLoaderWrapper>
  </div>
}
