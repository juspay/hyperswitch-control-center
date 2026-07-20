open Typography

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineRulesTypes
  open ReconEngineHooks

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let basePath = GlobalVars.appendDashboardPath(~url="v1/recon-engine/transactions")
  let (accountData, setAccountData) = React.useState(_ => [])
  let (reconRulesList, setReconRulesList) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getAccounts = useGetAccounts()
  let getReconRuleList = useGetReconRuleList()

  let onTitleClick = idx => {
    let url =
      reconRulesList
      ->Array.get(idx)
      ->mapOptionOrDefault(basePath, rule => `${basePath}?rule_id=${rule.rule_id}`)
    RescriptReactRouter.push(url)
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

  let getAccountsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accountData = await getAccounts()
      let reconRulesList = await getReconRuleList()
      setAccountData(_ => accountData)
      setReconRulesList(_ => reconRulesList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getAccountsData()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    reconRulesList->Array.map((rule: rulePayload) => {
      {
        title: rule.rule_name,
        renderContent: () =>
          <FilterContext
            key={`recon-engine-transaction-${rule.rule_id}`}
            index={`recon-engine-transaction-${rule.rule_id}`}>
            <ReconEngineTransactionsContent rule accountData reconRulesList />
          </FilterContext>,
      }
    })
  }, (accountData, reconRulesList))

  <div className="flex flex-col w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transactions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0 !mb-2"
      />
      <div className="flex-shrink-0">
        <Button
          text="Generate Report"
          buttonType=Primary
          buttonSize=Large
          buttonState=Disabled
          onClick={_ => {
            mixpanelEvent(~eventName="recon_engine_transactions_generate_reports_clicked")
          }}
        />
      </div>
    </div>
    <PageLoaderWrapper screenState>
      <RenderIf condition={reconRulesList->isEmptyArray}>
        <div className="my-4">
          <NoDataFound
            message="No recon rules found. Please create a recon rule to view the transactions."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={reconRulesList->isNonEmptyArray}>
        <Tabs tabs initialIndex=initialTabIndex onTitleClick />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
