open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineRulesUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
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
      let ruleDetails = res->getArrayDataFromJson(getRulePayloadFromDict)
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
          key={`recon-engine-exception-transaction-${ruleDetails.rule_id}`}
          index={`recon-engine-exception-transaction-${ruleDetails.rule_id}`}>
          <ReconEngineExceptionTransaction ruleId={ruleDetails.rule_id} />
        </FilterContext>
      },
    })
  }, [reconRulesList])

  React.useEffect(() => {
    getReconRulesData()->ignore
    None
  }, [])

  <div className="flex flex-col gap-4 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Exceptions" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
      />
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
        <Tabs
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center !text-red-500 ${body.lg.semibold}`}
          selectTabBottomBorderColor="bg-primary"
          customBottomBorderColor="bg-nd_gray-150 mb-4"
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
