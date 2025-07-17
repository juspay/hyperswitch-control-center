open Typography

module AccountCard = {
  open ReconEngineOverviewUtils
  @react.component
  let make = (~account: ReconEngineOverviewTypes.accountType, ~index) => {
    let iconName = getAccountIcon(index)
    let handleCardClick = _ => {
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`v1/recon-engine/overview/${account.account_id}`),
      )
    }
    <div
      className="bg-white border border-nd_gray-200 rounded-lg p-6 shadow-sm hover:shadow-md transition-shadow cursor-pointer"
      onClick={handleCardClick}>
      <div className="flex items-center gap-3 mb-6">
        <div className="w-8 h-8 bg-purple-100 rounded flex items-center justify-center">
          <Icon name=iconName size=16 className="text-purple-600" />
        </div>
        <div className={`${body.lg.semibold} text-nd_gray-800`}>
          {account.account_name->React.string}
        </div>
      </div>
      <div className="grid grid-cols-2 gap-6 mb-4">
        <div>
          <div className={`${body.sm.regular} text-nd_gray-500 mb-1`}>
            {"Currency"->React.string}
          </div>
          <div className={`${body.md.medium} text-nd_gray-900`}>
            {account.currency->React.string}
          </div>
        </div>
      </div>
      <div className="grid grid-cols-2 gap-6 mb-4">
        <div>
          <div className={`${body.sm.regular} text-nd_gray-500 mb-1`}>
            {"Posted Balance"->React.string}
          </div>
          <div className={`${body.md.medium} text-nd_gray-900`}>
            {account.posted_balance->React.string}
          </div>
        </div>
        <div>
          <div className={`${body.sm.regular} text-nd_gray-500 mb-1`}>
            {"Pending Balance"->React.string}
          </div>
          <div className={`${body.md.medium} text-nd_gray-900`}>
            {account.pending_balance->React.string}
          </div>
        </div>
      </div>
    </div>
  }
}

module ReconRuleTransactionInfo = {
  @react.component
  let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
    open ReconEngineOverviewHelper
    open LogicUtils
    open ReconEngineTransactionsUtils
    open APIUtils
    open ReconEngineOverviewUtils

    let (transactionsData, setTransactionsData) = React.useState(_ => [])
    let (accountData, setAccountData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

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
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let getTransactionsList = async _ => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#TRANSACTIONS_LIST,
          ~methodType=Get,
          ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
        )
        let res = await fetchDetails(url)
        let transactionsData = res->getArrayDataFromJson(getAllTransactionPayload)
        setTransactionsData(_ => transactionsData)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let sourceAccountName = React.useMemo(() => {
      let source = ruleDetails.sources->getValueFromArray(0, defaultAccountDetails)
      getAccountName(accountData, source.account_id)
    }, [ruleDetails])

    let targetAccountName = React.useMemo(() => {
      let target = ruleDetails.targets->getValueFromArray(0, defaultAccountDetails)
      getAccountName(accountData, target.account_id)
    }, [ruleDetails])

    React.useEffect(() => {
      getAccountsData()->ignore
      getTransactionsList()->ignore
      None
    }, [])

    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <OverviewCard title={`Expected from ${sourceAccountName}`} value="100" />
          <OverviewCard title={`Received by ${targetAccountName}`} value="200" />
          <OverviewCard title="Net Variance" value="300" />
        </div>
        <StackedBarGraph transactionsData />
        <ReconRuleLineGraph transactionsData />
        <ReconRuleTransactions ruleDetails={ruleDetails} />
      </div>
    </PageLoaderWrapper>
  }
}

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
  let getAccountData = async _ => {
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

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    reconRulesList->Array.map(ruleDetails => {
      {
        title: ruleDetails.rule_name,
        renderContent: () => <ReconRuleTransactionInfo ruleDetails={ruleDetails} />,
      }
    })
  }, [reconRulesList])

  React.useEffect(() => {
    getAccountData()->ignore
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
