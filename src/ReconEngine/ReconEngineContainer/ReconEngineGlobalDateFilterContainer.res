@react.component
let make = () => {
  open HSAnalyticsUtils
  open LogicUtils
  open HSwitchUtils
  open UserManagementTypes
  open HyperswitchAtom
  open ReconEngineFilterUtils

  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateExistingKeys, filterKeys, filterValue} = React.useContext(FilterContext.filterContext)
  let setGlobalDateFilters = ReconEngineAtoms.globalDateFiltersAtom->Recoil.useSetRecoilState
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

  <>
    <RenderIf condition={url.path->urlPath->showsGlobalDateFilter}>
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
    {switch url.path->urlPath {
    | list{"v1", "recon-engine", "overview"} =>
      <AccessControl isEnabled={featureFlagDetails.devReconEngineV1} authorization=Access>
        <ReconEngineOverviewContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transactions", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconTransactionsView)}>
        <ReconEngineTransactionContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "exceptions", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconExceptionsView)}>
        <ReconEngineExceptionContainer />
      </AccessControl>
    | list{"v1", "recon-engine", "transformed-entries", ..._} =>
      <AccessControl
        isEnabled={featureFlagDetails.devReconEngineV1}
        authorization={userHasAccess(~groupAccess=ReconSourcesView)}>
        <ReconEngineTransformedEntriesContainer />
      </AccessControl>
    | _ => <EmptyPage path="/v1/recon-engine/overview" />
    }}
  </>
}
