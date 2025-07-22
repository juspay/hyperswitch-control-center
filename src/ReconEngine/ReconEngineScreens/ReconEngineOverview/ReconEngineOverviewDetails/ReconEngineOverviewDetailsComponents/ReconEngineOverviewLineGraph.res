open Typography

@react.component
let make = (~ruleDetails: ReconEngineOverviewTypes.reconRuleType) => {
  let (allTransactionsData, setAllTransactionsData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getTransactions = ReconEngineTransactionsHook.useGetTransactions()

  let getAllTransactionsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let transactionsData = await getTransactions(
        ~queryParamerters=Some(`rule_id=${ruleDetails.rule_id}`),
      )
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
