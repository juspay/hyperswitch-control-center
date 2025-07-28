open Typography

@react.component
let make = () => {
  open ReconEngineOverviewUtils
  open ReconEngineOverviewTypes
  open APIUtils
  open LogicUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (reconRulesList, setReconRulesList) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let getReconRulesData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#RECON_RULES,
        ~methodType=Get,
      )
      let res = await fetchDetails(url)
      let ruleDetails = res->getArrayDataFromJson(reconRuleItemToObjMapper)
      setReconRulesList(_ => ruleDetails)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    reconRulesList->Array.map(ruleDetails => {
      {
        title: ruleDetails.rule_name,
        renderContent: () => <ReconEngineOverviewDetails ruleDetails />,
      }
    })
  }, [reconRulesList])

  React.useEffect(() => {
    getReconRulesData()->ignore
    None
  }, [])

  <div className="flex flex-col gap-6 w-full">
    <PageUtils.PageHeading
      title="Overview"
      subTitle="Monitor your accounts and transactions with recon rules."
      customSubTitleStyle={body.lg.medium}
      customTitleStyle={`${heading.lg.semibold} py-0`}
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
      <RenderIf condition={reconRulesList->Array.length > 0}>
        <Tabs
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.md.semibold}`}
          selectTabBottomBorderColor="bg-primary"
          customBottomBorderColor="mb-6"
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
