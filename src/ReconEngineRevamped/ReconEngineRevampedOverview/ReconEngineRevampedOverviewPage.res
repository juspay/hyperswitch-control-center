@react.component
let make = () => {
  open ReconEngineRevampedHelper

  let {updateExistingKeys, filterKeys} = React.useContext(FilterContext.filterContext)
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_revamped_overview",
    ~range=180,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  <div className="w-full">
    <div className="flex flex-row items-center justify-between w-full">
      <PageHeading title="Overview" />
      <div className="flex flex-row items-center gap-4">
        <div className="-translate-y-1">
          <DynamicFilter
            title="ReconEngineRevampedOverviewFilters"
            initialFilters=[]
            options=[]
            popupFilterFields=[]
            initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(null)}
            defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
            tabNames=filterKeys
            key="ReconEngineRevampedOverviewFilters"
            updateUrlWith=updateExistingKeys
            filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
            showCustomFilter=false
            refreshFilters=false
          />
        </div>
        <Button
          rightIcon={CustomIcon(<Icon name="nd-arrow-right" size=12 />)}
          text="Work Exceptions"
          buttonType=Primary
          buttonSize=Small
          onClick={_ => ()}
          maxButtonWidth="!w-fit"
        />
      </div>
    </div>
    <ReconEngineRevampedOverviewStatCards />
    <div className="flex flex-row mt-5">
      <div className="w-full lg:w-3/5">
        <ReconEngineRevampedOverviewTrendChart />
      </div>
    </div>
  </div>
}
