@react.component
let make = () => {
  open NewAnalyticsContainerUtils
  let url = RescriptReactRouter.useUrl()
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let (tabIndex, setTabIndex) = React.useState(_ => url->getPageIndex)

  React.useEffect(() => {
    let url = (getPageFromIndex(tabIndex) :> string)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))
    None
  }, [tabIndex])

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="analytics",
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
    <PageUtils.PageHeading title="Analytics" />
    <div
      className="-ml-1 sticky top-0 z-30 p-1 bg-hyperswitch_background py-1 rounded-lg border my-2">
      <DynamicFilter
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields()}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
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
      disableIndicationArrow=true
      showBorder=true
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      onTitleClick={tabId => setTabIndex(_ => tabId)}
    />
  </div>
}
