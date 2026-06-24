open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineRulesTypes
  open ReconEngineRulesUtils

  let url = RescriptReactRouter.useUrl()
  let basePath = GlobalVars.appendDashboardPath(~url="v1/recon-engine/overview")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (reconRulesList, setReconRulesList) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let navigateToRule = (ruleId: string) => {
    RescriptReactRouter.push(`${basePath}?rule_id=${ruleId}`)
  }

  let onTitleClick = idx => {
    switch reconRulesList->Array.get(idx - 1) {
    | Some(ruleDetails) => navigateToRule(ruleDetails.rule_id)
    | None => RescriptReactRouter.push(basePath)
    }
  }

  let initialTabIndex = React.useMemo(() => {
    let urlSearch = url.search
    if urlSearch->isNonEmptyString {
      urlSearch
      ->getDictFromUrlSearchParams
      ->getMappedValueFromDict("rule_id", 0, ruleId =>
        reconRulesList
        ->Array.findIndexOpt(rule => rule.rule_id === ruleId)
        ->mapOptionOrDefault(0, idx => idx + 1)
      )
    } else {
      0
    }
  }, (url.search, reconRulesList))

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
    [
      {
        title: "Overview",
        renderContent: () =>
          <FilterContext key="recon-engine-overview-summary" index="recon-engine-overview-summary">
            <ReconEngineOverviewSummary reconRulesList onRuleClick=navigateToRule />
          </FilterContext>,
      },
      ...reconRulesList->Array.map(ruleDetails => {
        title: ruleDetails.rule_name,
        renderContent: () =>
          <FilterContext key="recon-engine-overview-details" index="recon-engine-overview-details">
            <ReconEngineOverviewDetails ruleDetails />
          </FilterContext>,
      }),
    ]
  }, [reconRulesList])

  React.useEffect(() => {
    getReconRulesData()->ignore
    None
  }, [])

  <div className="flex flex-col w-full">
    <PageUtils.PageHeading
      title="Recon Overview" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
    />
    <PageLoaderWrapper screenState>
      <RenderIf condition={reconRulesList->Array.length == 0}>
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
