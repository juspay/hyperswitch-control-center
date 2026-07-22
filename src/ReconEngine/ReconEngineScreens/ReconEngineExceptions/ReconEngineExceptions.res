open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineRulesUtils

  let url = RescriptReactRouter.useUrl()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (reconRulesList, setReconRulesList) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~range=180,
    ~origin="recon_engine_exception_transaction",
    (),
  )

  let getReconRulesData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#RECON_RULES,
        ~methodType=Get,
      )
      let res = await fetchDetails(url)
      let ruleDetails = res->getArrayDataFromJson(ruleItemToObjMapper)
      setReconRulesList(_ => ruleDetails)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    reconRulesList->Array.map(ruleDetails => {
      title: ruleDetails.rule_name,
      renderContent: () => {
        <ReconEngineExceptionTransaction ruleId={ruleDetails.rule_id} />
      },
    })
  }, [reconRulesList])

  React.useEffect(() => {
    getReconRulesData()->ignore
    let urlFilters = url.search->getDictFromUrlSearchParams
    let startTime = urlFilters->getValueFromDict(startTimeFilterKey, "")
    let endTime = urlFilters->getValueFromDict(endTimeFilterKey, "")
    if startTime->isNonEmptyString || endTime->isNonEmptyString {
      updateExistingKeys(
        Dict.fromArray([(startTimeFilterKey, startTime), (endTimeFilterKey, endTime)]),
      )
    } else {
      setInitialFilters()->ignore
    }
    None
  }, [])

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_exception_transaction_date_filter_opened")
  }

  let initialTabIndex = React.useMemo(() => {
    let urlSearch = url.search
    if urlSearch->isNonEmptyString {
      urlSearch
      ->getDictFromUrlSearchParams
      ->getMappedValueFromDict("rule_id", 0, ruleId =>
        reconRulesList->Array.findIndexOpt(rule => rule.rule_id === ruleId)->Option.getOr(0)
      )
    } else {
      0
    }
  }, (url.search, reconRulesList))

  <div className="flex flex-col gap-4 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Recon Exceptions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
      <div className="flex flex-row items-center gap-4">
        <div className="flex flex-row -ml-1.5">
          <DynamicFilter
            title="ReconEngineExceptionTransactionFilters"
            initialFilters={[]}
            options=[]
            popupFilterFields=[]
            initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
              null,
              ~events=dateDropDownTriggerMixpanelCallback,
            )}
            defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
            tabNames=[]
            key="ReconEngineExceptionTransactionFilters"
            updateUrlWith=updateExistingKeys
            filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
            showCustomFilter=false
            refreshFilters=false
          />
        </div>
        <div className="flex-shrink-0">
          <Button
            text="Generate Report"
            buttonType=Primary
            buttonSize=Large
            buttonState=Disabled
            onClick={_ => {
              mixpanelEvent(~eventName="recon_engine_exceptions_generate_reports_clicked")
            }}
          />
        </div>
      </div>
    </div>
    <PageLoaderWrapper screenState>
      <RenderIf condition={reconRulesList->Array.length == 0}>
        <div className="my-4">
          <NoDataFound
            message="No recon rules found. Please create a recon rule to view the exceptions."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={reconRulesList->Array.length > 0}>
        <Tabs tabs initialIndex={initialTabIndex} />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
