open Typography

module OverviewCard = {
  @react.component
  let make = (~title, ~value) => {
    <div
      className="flex flex-col gap-4 bg-white border border-nd_gray-200 rounded-xl p-4 shadow-xs">
      <div className={`${body.md.medium} text-nd_gray-400`}> {title->React.string} </div>
      <div className={`${heading.md.semibold} text-nd_gray-800`}> {value->React.string} </div>
    </div>
  }
}

module OverviewCardDetails = {
  @react.component
  let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
    open LogicUtils
    open ReconEngineOverviewUtils
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (accountData, setAccountData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])

    let getTransactionsAndAccountData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#ACCOUNTS_LIST,
        )
        let res = await fetchDetails(url)
        let accountData = res->getArrayDataFromJson(accountItemToObjMapper)
        setAccountData(_ => accountData)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#TRANSACTIONS_LIST,
          ~methodType=Get,
          ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
        )
        let res = await fetchDetails(url)
        let transactionsData =
          res->getArrayDataFromJson(ReconEngineTransactionsUtils.getAllTransactionPayload)
        setAllTransactionsData(_ => transactionsData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let (
      (sourceAccountName, sourceAccountCurrency),
      (targetAccountName, targetAccountCurrency),
    ) = React.useMemo(() => {
      let source = ruleDetails.sources->getValueFromArray(0, defaultAccountDetails)
      let target = ruleDetails.targets->getValueFromArray(0, defaultAccountDetails)
      let sourceInfo = getAccountNameAndCurrency(accountData, source.account_id)
      let targetInfo = getAccountNameAndCurrency(accountData, target.account_id)
      (sourceInfo, targetInfo)
    }, (ruleDetails, accountData))

    let ruleTransactionsData = React.useMemo(() => {
      allTransactionsData->Array.filter(transaction =>
        transaction.rule.rule_id === ruleDetails.rule_id
      )
    }, (allTransactionsData, ruleDetails.rule_id))

    let (sourcePostedAmount, targetPostedAmount, netVariance) = React.useMemo(() => {
      calculateAccountAmounts(ruleTransactionsData)
    }, [ruleTransactionsData])

    React.useEffect(() => {
      getTransactionsAndAccountData()->ignore
      None
    }, [])

    <PageLoaderWrapper
      screenState
      customLoader={<div className="h-full flex flex-col justify-center items-center">
        <div className="animate-spin">
          <Icon name="spinner" size=20 />
        </div>
      </div>}>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <OverviewCard
          title={`Expected from ${sourceAccountName}`}
          value={formatAmountWithCurrency(sourcePostedAmount, sourceAccountCurrency)}
        />
        <OverviewCard
          title={`Received by ${targetAccountName}`}
          value={formatAmountWithCurrency(targetPostedAmount, targetAccountCurrency)}
        />
        <OverviewCard
          title="Net Variance" value={formatAmountWithCurrency(netVariance, sourceAccountCurrency)}
        />
      </div>
    </PageLoaderWrapper>
  }
}

module StackedBarGraph = {
  @react.component
  let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getAllTransactionsData = async _ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#TRANSACTIONS_LIST,
          ~methodType=Get,
          ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
        )
        let res = await fetchDetails(url)
        let transactionsData =
          res->getArrayDataFromJson(ReconEngineTransactionsUtils.getAllTransactionPayload)
        setAllTransactionsData(_ => transactionsData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")
    let (postedCount, mismatchedCount, expectedCount) = React.useMemo(() => {
      ReconEngineOverviewUtils.calculateTransactionCounts(allTransactionsData)
    }, [allTransactionsData])

    let totalTransactions = postedCount + mismatchedCount + expectedCount
    let stackedBarGraphData = React.useMemo(() => {
      ReconEngineOverviewUtils.getStackedBarGraphData(
        ~postedCount,
        ~mismatchedCount,
        ~expectedCount,
      )
    }, [postedCount, mismatchedCount, expectedCount])

    React.useEffect(() => {
      getAllTransactionsData()->ignore
      None
    }, [])

    <PageLoaderWrapper
      screenState
      customLoader={<div className="h-full flex flex-col justify-center items-center">
        <div className="animate-spin">
          <Icon name="spinner" size=20 />
        </div>
      </div>}>
      <div
        className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
        <p className={`text-nd_gray-400 ${body.sm.medium}`}>
          {"Total Transaction"->React.string}
        </p>
        <p className={`text-nd_gray-800 ${heading.lg.semibold}`}>
          {totalTransactions->Int.toString->React.string}
        </p>
        <div className="w-full">
          <StackedBarGraph
            options={StackedBarGraphUtils.getStackedBarGraphOptions(
              stackedBarGraphData,
              ~yMax=totalTransactions,
              ~labelItemDistance={isMiniLaptopView ? 45 : 90},
            )}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

module ReconRuleLineGraph = {
  @react.component
  let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getAllTransactionsData = async _ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#TRANSACTIONS_LIST,
          ~methodType=Get,
          ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
        )
        let res = await fetchDetails(url)
        let transactionsData =
          res->getArrayDataFromJson(ReconEngineTransactionsUtils.getAllTransactionPayload)
        setAllTransactionsData(_ => transactionsData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let lineGraphData = React.useMemo(() => {
      ReconEngineOverviewUtils.processLineGraphData(allTransactionsData)
    }, [allTransactionsData])

    React.useEffect(() => {
      getAllTransactionsData()->ignore
      None
    }, [])

    <PageLoaderWrapper
      screenState
      customLoader={<div className="h-full flex flex-col justify-center items-center">
        <div className="animate-spin">
          <Icon name="spinner" size=20 />
        </div>
      </div>}>
      <div className="border rounded-xl border-nd_gray-200">
        <div
          className="flex flex-col space-y-2 items-start px-4 py-2 bg-nd_gray-25 rounded-t-xl border-b border-nd_gray-200">
          <div className={`text-nd_gray-600 ${body.md.semibold} p-2 w-full`}>
            {"Reconciliation Trends"->React.string}
          </div>
        </div>
        <div className="w-full p-2">
          <LineGraph options={LineGraphUtils.getLineGraphOptions(lineGraphData)} />
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

module ReconRuleTransactions = {
  @react.component
  let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
    open LogicUtils
    open ReconEngineTransactionsUtils
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (configuredTransactions, setConfiguredReports) = React.useState(_ => [])
    let (filteredTransactionsData, setFilteredReports) = React.useState(_ => [])
    let (offset, setOffset) = React.useState(_ => 0)
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let {updateExistingKeys, filterValueJson, filterValue, filterKeys} = React.useContext(
      FilterContext.filterContext,
    )
    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let mixpanelEvent = MixpanelHook.useSendEvent()

    let dateDropDownTriggerMixpanelCallback = () => {
      mixpanelEvent(~eventName="recon_engine_overview_transactions_date_filter_opened")
    }

    let fetchTransactionsData = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let baseQueryString = ReconEngineUtils.buildQueryStringFromFilters(~filterValueJson)
        let queryString = if baseQueryString->isNonEmptyString {
          `${baseQueryString}&rule_id=${ruleDetails.rule_id}`
        } else {
          `rule_id=${ruleDetails.rule_id}`
        }

        let transactionsUrl = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSACTIONS_LIST,
          ~queryParamerters=Some(queryString),
        )

        let res = await fetchDetails(transactionsUrl)
        let transactionsList = res->LogicUtils.getArrayDataFromJson(getAllTransactionPayload)

        let transactionsDataList = transactionsList->Array.map(Nullable.make)
        setConfiguredReports(_ => transactionsDataList)
        setFilteredReports(_ => transactionsDataList)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~origin="recon_engine_overview_transactions",
      (),
    )

    React.useEffect(() => {
      setInitialFilters()
      None
    }, [])

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        fetchTransactionsData()->ignore
      }
      None
    }, [filterValue])

    let topFilterUi = {
      <div className="flex flex-row">
        <DynamicFilter
          title="ReconEngineOverviewTransactionsFilters"
          initialFilters={initialDisplayFilters()}
          options=[]
          popupFilterFields=[]
          initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames=filterKeys
          key="ReconEngineOverviewTransactionsFilters"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
    }

    <div className="flex flex-col gap-4">
      <div className="flex-shrink-0"> {topFilterUi} </div>
      <PageLoaderWrapper screenState>
        <LoadedTableWithCustomColumns
          title="All Transactions"
          actualData={filteredTransactionsData}
          entity={TransactionsTableEntity.transactionsEntity(
            `v1/recon-engine/transactions`,
            ~authorization=Access,
          )}
          resultsPerPage=10
          totalResults={filteredTransactionsData->Array.length}
          offset
          setOffset
          currrentFetchCount={configuredTransactions->Array.length}
          customColumnMapper=TableAtoms.reconTransactionsOverviewDefaultCols
          defaultColumns={TransactionsTableEntity.defaultColumnsOverview}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          remoteSortEnabled=true
          customizeColumnButtonIcon="nd-filter-horizontal"
          hideRightTitleElement=true
          showAutoScroll=true
        />
      </PageLoaderWrapper>
    </div>
  }
}
