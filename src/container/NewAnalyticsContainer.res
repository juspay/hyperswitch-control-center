@react.component
let make = () => {
  open NewAnalyticsContainerUtils
  open LogicUtils
  let url = RescriptReactRouter.useUrl()
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let (tabIndex, setTabIndex) = React.useState(_ => url->getPageIndex)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  React.useEffect(() => {
    let url = (getPageFromIndex(tabIndex) :> string)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))
    None
  }, [tabIndex])

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~compareToStartTimeKey,
    ~compareToEndTimeKey,
    ~origin="analytics",
    ~enableCompareTo=Some(true),
    ~range=6,
    ~comparisonKey,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  let tabs: array<Tabs.tab> = [
    {
      title: "Payments",
      renderContent: () =>
        <div className="mt-5">
          <NewPaymentAnalytics />
        </div>,
    },
  ]

  <div>
    <PageUtils.PageHeading title="Insights" />
    <div
      className="-ml-1 sticky top-0 z-30 p-1 backdrop-blur-sm bg-hyperswitch_background/70 py-1 rounded-lg my-2">
      <DynamicFilter
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(
          ~compareWithStartTime=startTimeVal,
          ~compareWithEndTime=endTimeVal,
        )}
        defaultFilterKeys=[
          startTimeFilterKey,
          endTimeFilterKey,
          compareToStartTimeKey,
          compareToEndTimeKey,
          comparisonKey,
        ]
        tabNames=[]
        key="0"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
    <Tabs
      initialIndex={url->getPageIndex}
      tabs
      onTitleClick={tabId => setTabIndex(_ => tabId)}
      disableIndicationArrow=true
      showBorder=true
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      textStyle="text-blue-600"
      selectTabBottomBorderColor="bg-blue-600"
    />
  </div>
}
