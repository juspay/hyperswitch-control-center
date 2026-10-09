@react.component
let make = () => {
  open HSAnalyticsUtils
  open LogicUtils
  open ReconEngineFilterUtils

  let {updateExistingKeys, filterKeys, filterValue} = React.useContext(FilterContext.filterContext)
  let setGlobalDateFilters = ReconEngineAtoms.globalDateFiltersAtom->Recoil.useSetRecoilState
  let portalNodes = PortalState.portalNodes->Recoil.useRecoilValueFromAtom
  let hasGlobalDateFilterPortal =
    portalNodes->getOptionValFromDict(globalDateFilterPortalName)->Option.isSome
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_global_date_filter_opened")
  }

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_global",
    (),
  )

  React.useEffect(() => {
    if filterValue->isEmptyDict {
      setInitialFilters()
    } else {
      let dateFilters = filterValue->getGlobalDateFilterFromDict

      if dateFilters.startTime->isNonEmptyString || dateFilters.endTime->isNonEmptyString {
        setGlobalDateFilters(prev =>
          prev.startTime == dateFilters.startTime && prev.endTime == dateFilters.endTime
            ? prev
            : dateFilters
        )
      }
    }
    None
  }, [filterValue])

  <RenderIf condition={hasGlobalDateFilterPortal}>
    <Portal to=globalDateFilterPortalName>
      <DynamicFilter
        title="ReconEngineGlobalDateFilter"
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(
          null,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=globalDateFilterKeys
        tabNames=filterKeys
        key="ReconEngineGlobalDateFilter"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName
        showCustomFilter=false
        refreshFilters=false
      />
    </Portal>
  </RenderIf>
}
