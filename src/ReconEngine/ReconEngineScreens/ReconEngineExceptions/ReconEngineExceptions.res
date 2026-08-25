open Typography

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineRulesTypes

  let url = RescriptReactRouter.useUrl()
  let basePath = GlobalVars.appendDashboardPath(~url="v1/recon-engine/exceptions/recon")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let (reconRulesList, setReconRulesList) = React.useState(_ => [])
  let (reportModal, setReportModal) = React.useState(_ => false)
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let getReconRuleList = ReconEngineHooks.useGetReconRuleList()
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let onTitleClick = idx => {
    let url =
      reconRulesList
      ->Array.get(idx)
      ->mapOptionOrDefault(basePath, rule => `${basePath}?rule_id=${rule.rule_id}`)
    RescriptReactRouter.push(url)
  }

  let getAccountsAndRulesData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let (accounts, ruleDetails) = await Promise.all2((getAccounts(), getReconRuleList()))
      setAccountData(_ => accounts)
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
        <FilterContext
          key={`recon-engine-exception-${ruleDetails.rule_id}`}
          index={`recon-engine-exception-${ruleDetails.rule_id}`}>
          <ReconEngineExceptionTransaction
            ruleId={ruleDetails.rule_id} accountData reconRulesList
          />
        </FilterContext>
      },
    })
  }, (accountData, reconRulesList))

  React.useEffect(() => {
    getAccountsAndRulesData()->ignore
    None
  }, [])

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

  let selectedRule = reconRulesList->Array.get(initialTabIndex)

  <div className="flex flex-col w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Recon Exceptions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
      <div className="flex flex-row items-center gap-4">
        <PortalCapture name=ReconEngineFilterUtils.globalDateFilterPortalName customStyle="-mt-1" />
        <div className="flex-shrink-0">
          <Button
            text="Generate Report"
            buttonType=Primary
            buttonSize=Large
            buttonState={selectedRule->Option.isSome ? Normal : Disabled}
            onClick={_ => {
              setReportModal(_ => true)
              mixpanelEvent(~eventName="recon_engine_exceptions_generate_reports_clicked")
            }}
          />
        </div>
      </div>
    </div>
    {selectedRule->mapOptionOrDefault(React.null, rule =>
      <ReconEngineGenerateReportModal
        showModal=reportModal
        setShowModal=setReportModal
        rule
        hyperswitchReconType=#GENERATE_EXCEPTION_REPORT
        modalHeading="Generate Exception Report"
      />
    )}
    <ReconEngineHelper.GlobalDateFilterBanner />
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
        <Tabs tabs initialIndex={initialTabIndex} onTitleClick />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
