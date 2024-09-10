open UserJourneyAnalyticsEntity

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
    open LogicUtils
    try {
      let infoUrl = getURL(
        ~entityName=ANALYTICS_USER_JOURNEY,
        ~methodType=Get,
        ~id=Some("sdk_events"),
      )
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
  let getUserJourneysData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      await loadInfo()
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    getUserJourneysData()->ignore
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

  let title = "Know your users"
  let subTitle = "User Journey analytics is a level deeper into payment analytics and aims at providing you a wholesome understanding of the end users and their usage patterns."

  <div>
    <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
      <Analytics
        pageTitle=title
        pageSubTitle=subTitle
        filterUri=Some(`${Window.env.apiBaseUrl}/analytics/v1/filters/sdk_events`)
        key="UserJourneyAnalytics"
        moduleName="UserJourney"
        deltaMetrics={getStringListFromArrayDict(metrics)}
        chartEntity={
          default: commonUserJourneyChartEntity(tabKeys),
          userPieChart: userJourneyChartEntity(tabKeys),
          userBarChart: userJourneyBarChartEntity(tabKeys),
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
        initialFixedFilters=fixedFilterFields
      />
    </PageLoaderWrapper>
  </div>
}
