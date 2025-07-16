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

module StackedBarGraph = {
  @react.component
  let make = () => {
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")

    <div
      className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className={`text-nd_gray-400 ${body.sm.medium}`}> {"Total Transaction"->React.string} </p>
      <p className={`text-nd_gray-800 ${heading.lg.semibold}`}> {"2000"->React.string} </p>
      <div className="w-full">
        <StackedBarGraph
          options={StackedBarGraphUtils.getStackedBarGraphOptions(
            ReconEngineTransactionsUtils.getSampleStackedBarGraphData(),
            ~yMax=2000,
            ~labelItemDistance={isMiniLaptopView ? 45 : 90},
          )}
        />
      </div>
    </div>
  }
}

module ReconRuleLineGraph = {
  @react.component
  let make = () => {
    <div className="border rounded-xl border-nd_gray-200">
      <div
        className="flex flex-col space-y-2 items-start px-4 py-2 bg-nd_gray-25 rounded-t-xl border-b border-nd_gray-200">
        <div className={`text-nd_gray-600 ${body.md.semibold} p-2 w-full`}>
          {"Reconciliation Trends"->React.string}
        </div>
      </div>
      <div className="w-full p-2">
        <LineGraph
          options={LineGraphUtils.getLineGraphOptions(
            ReconEngineOverviewUtils.getLineGraphOptions(),
          )}
        />
      </div>
    </div>
  }
}

module ReconRuleTransactions = {
  @react.component
  let make = () => {
    open LogicUtils
    open ReconEngineTransactionsUtils

    let (configuredTransactions, setConfiguredReports) = React.useState(_ => [])
    let (filteredTransactionsData, setFilteredReports) = React.useState(_ => [])
    let (offset, setOffset) = React.useState(_ => 0)
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let (searchText, setSearchText) = React.useState(_ => "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let filterLogic = ReactDebounce.useDebounced(ob => {
      let (searchText, arr) = ob
      let filteredList = if searchText->isNonEmptyString {
        arr->Array.filter((obj: Nullable.t<ReconEngineTransactionsTypes.transactionPayload>) => {
          switch Nullable.toOption(obj) {
          | Some(obj) =>
            isContainingStringLowercase(obj.transaction_id, searchText) ||
            isContainingStringLowercase(obj.transaction_status, searchText)
          | None => false
          }
        })
      } else {
        arr
      }
      setFilteredReports(_ => filteredList)
    }, ~wait=200)

    let getTransactionsList = async _ => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let res = SampleTransactions.data
        let data = res->getDictFromJsonObject->getArrayFromDict("transactions", [])
        let transactionsList = data->getArrayOfTransactionsListPayloadType
        setConfiguredReports(_ => transactionsList)
        setFilteredReports(_ => transactionsList->Array.map(Nullable.make))
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    React.useEffect(() => {
      getTransactionsList()->ignore
      None
    }, [])

    <PageLoaderWrapper screenState>
      <RenderIf condition={configuredTransactions->Array.length > 0}>
        <LoadedTableWithCustomColumns
          title="All Transactions"
          actualData={filteredTransactionsData}
          entity={TransactionsTableEntity.transactionsEntity(
            `v1/recon-engine/transactions`,
            ~authorization=userHasAccess(~groupAccess=UsersManage),
          )}
          resultsPerPage=10
          filters={<TableSearchFilter
            data={configuredTransactions->Array.map(Nullable.make)}
            filterLogic
            placeholder="Search Transaction Id or Status"
            customSearchBarWrapperWidth="w-full lg:w-1/2 mb-2"
            customInputBoxWidth="w-full rounded-xl "
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          totalResults={filteredTransactionsData->Array.length}
          offset
          setOffset
          currrentFetchCount={configuredTransactions->Array.length}
          customColumnMapper=TableAtoms.reconTransactionsDefaultCols
          defaultColumns={TransactionsTableEntity.defaultColumns}
          showSerialNumberInCustomizeColumns=false
          sortingBasedOnDisabled=false
          hideTitle=true
          remoteSortEnabled=true
          customizeColumnButtonIcon="nd-filter-horizontal"
          hideRightTitleElement=true
          showAutoScroll=true
        />
      </RenderIf>
    </PageLoaderWrapper>
  }
}
