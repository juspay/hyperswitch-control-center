open AuthenticationAnalyticsEntity

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
        ~entityName=ANALYTICS_AUTHENTICATION,
        ~methodType=Get,
        ~id=Some(domain),
        (),
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
  let getAuthenticationsData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      await loadInfo()
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    getAuthenticationsData()->ignore
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

  let title = "Authentication Analytics"
  let subTitle = "Know more about how well your users are able to authenticate payments"

  <div>
    <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
      <Analytics
        pageTitle=title
        pageSubTitle=subTitle
        filterUri=None
        key="AuthenticationAnalytics"
        moduleName="Authentication"
        deltaMetrics={getStringListFromArrayDict(metrics)}
        chartEntity={
          default: commonAuthenticationChartEntity(tabKeys),
          userFunnelChart: authenticationFunnelChartEntity(tabKeys),
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
