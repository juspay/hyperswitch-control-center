open Typography

@react.component
let make = () => {
  open PageUtils
  open HSAnalyticsUtils

  let getAccounts = ReconEngineHooks.useGetAccounts()
  let {updateExistingKeys, filterKeys} = React.useContext(FilterContext.filterContext)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_pipelines_date_filter_opened")
  }

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let (refreshTrigger, setRefreshTrigger) = React.useState(_ => false)

  let fetchAccounts = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch accounts"))
    }
  }

  React.useEffect(() => {
    fetchAccounts()->ignore
    None
  }, [])

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_pipelines",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  <div className="flex flex-col">
    <div className="flex flex-row justify-between items-center">
      <PageHeading
        title="Pipelines" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
      />
      <div className="flex flex-row items-start gap-3">
        <DynamicFilter
          title="ReconEnginePipelinesFilters"
          initialFilters=[]
          options=[]
          popupFilterFields=[]
          initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames=filterKeys
          key="ReconEnginePipelinesFilters"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
        <div className="mt-5">
          <ReconEnginePipelinesUploadModal
            accountData onClose={() => setRefreshTrigger(prev => !prev)}
          />
        </div>
      </div>
    </div>
    <ReconEnginePipelinesStatCards refreshTrigger />
    <PageLoaderWrapper screenState>
      <ReconEnginePipelinesTable accountData refreshTrigger />
    </PageLoaderWrapper>
  </div>
}
