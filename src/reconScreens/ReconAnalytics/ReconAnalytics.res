@react.component
let make = () => {
  open ReconAnalyticsHelper

  let fetchAnalyticsListResponse = AnalyticsData.useFetchAnalyticsList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (analyticsCardData, setAnalyticsCardData) = React.useState(_ => Dict.make())

  let getReportsList = async _ => {
    try {
      let response = await fetchAnalyticsListResponse()
      setAnalyticsCardData(_ => response->Identity.genericTypeToDictOfJson)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getReportsList()->ignore
    None
  }, [])

  <div>
    <PageUtils.PageHeading
      title={"Reconciliation Analytics"} subTitle={"View all the reconciliation analytics here"}
    />
    <PageLoaderWrapper screenState>
      <ReconAnalyticsCards analyticsCardData />
    </PageLoaderWrapper>
  </div>
}
