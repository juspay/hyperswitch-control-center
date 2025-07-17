open Typography

@react.component
let make = () => {
  open ReconEngineOverviewUtils
  open ReconEngineOverviewTypes
  open APIUtils
  open LogicUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (reconRulesList, setReconRulesList) = React.useState(_ => [])
  let (accountData, setAccountData) = React.useState(_ => [])
  let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
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
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let getAccountsData = async _ => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
      )
      let res = await fetchDetails(url)
      let accountData = res->getArrayDataFromJson(accountItemToObjMapper)
      setAccountData(_ => accountData)
    } catch {
    | _ => ()
    }
  }

  let getAllTransactionsData = async _ => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#TRANSACTIONS_LIST,
        ~methodType=Get,
      )
      let res = await fetchDetails(url)
      let transactionsData =
        res->getArrayDataFromJson(ReconEngineTransactionsUtils.getAllTransactionPayload)
      setAllTransactionsData(_ => transactionsData)
    } catch {
    | _ => ()
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    reconRulesList->Array.map(ruleDetails => {
      {
        title: ruleDetails.rule_name,
        renderContent: () =>
          <ReconEngineOverviewDetails
            ruleDetails accountData transactionsData=allTransactionsData
          />,
      }
    })
  }, (reconRulesList, accountData, allTransactionsData))

  React.useEffect(() => {
    getReconRulesData()->ignore
    getAccountsData()->ignore
    getAllTransactionsData()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-6 w-full">
      <PageUtils.PageHeading
        title="Overview"
        subTitle="Monitor the three-accounts reconciliation flow: OMS → Processor → Bank"
        customSubTitleStyle={body.lg.medium}
        customTitleStyle={heading.lg.semibold}
      />
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
    </div>
  </PageLoaderWrapper>
}
