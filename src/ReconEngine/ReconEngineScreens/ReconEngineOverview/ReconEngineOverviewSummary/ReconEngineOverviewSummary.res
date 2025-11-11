open Typography

@react.component
let make = (~reconRulesList) => {
  open ReconEngineOverviewSummaryHelper
  open ReconEngineOverviewSummaryTypes

  let (viewType, setViewType) = React.useState(_ => Graph)
  let {updateExistingKeys, filterKeys} = React.useContext(FilterContext.filterContext)
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_overview_summary_date_filter_opened")
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_overview_summary",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  <div className="flex flex-col gap-8 mt-8">
    <div className="flex flex-row justify-end">
      <DynamicFilter
        title="ReconEngineOverviewSummaryFilters"
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames=filterKeys
        key="ReconEngineOverviewSummaryFilters"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
    <ReconEngineOverviewSummaryStackedBarGraphs reconRulesList />
    <div className="flex flex-row justify-between items-center">
      <div className="flex flex-col gap-2">
        <p className={`text-nd_gray-800 ${heading.sm.semibold}`}>
          {"Account Balance Breakdown"->React.string}
        </p>
      </div>
      <div className="flex flex-row items-center gap-4">
        <TabSwitch viewType setViewType />
      </div>
    </div>
    {switch viewType {
    | Table => <ReconEngineOverviewSummaryAccountsView reconRulesList />
    | Graph => <ReconEngineOverviewSummaryFlowDiagram reconRulesList />
    }}
  </div>
}
