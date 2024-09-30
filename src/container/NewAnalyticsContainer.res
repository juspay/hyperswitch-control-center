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

  <div>
    <PageUtils.PageHeading title="Analytics" />
    <DynamicFilter
      initialFilters=[]
      options=[]
      popupFilterFields=[]
      initialFixedFilters={initialFixedFilterFields()}
      defaultFilterKeys=[]
      tabNames=[]
      updateUrlWith=updateExistingKeys //
      key="1"
      filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
      showCustomFilter=false
      refreshFilters=false
    />
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
