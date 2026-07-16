open Typography

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineOverviewSummaryTypes
  open ReconEngineOverviewSummaryUtils
  open ReconEngineOverviewSummaryHelper

  let getOverviewRules = ReconEngineHooks.useGetOverviewRules()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (txnItems, setTxnItems) = React.useState(_ => [])

  let fetchTriageData = async () => {
    open ReconEngineFilterUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = buildQueryStringFromFilters(~filterValueJson)
      let overviewRules = await getOverviewRules(~queryParameters=Some(queryParams))
      setTxnItems(_ => getExceptionTriageItems(~overviewRules))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchTriageData()->ignore
    }
    None
  }, [filterValue])

  let activeTotal = txnItems->Array.reduce(0, (acc, item) => acc + item.total)

  <div className="border border-nd_gray-200 rounded-xl bg-white h-full">
    <div
      className="flex items-center justify-between px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <div className="flex flex-col gap-0.5">
        <p className={`${body.md.semibold} text-nd_gray-800`}>
          {"Exception triage"->React.string}
        </p>
        <p className={`${body.sm.regular} text-nd_gray-600`}>
          {`${activeTotal->Int.toString} open exceptions`->React.string}
        </p>
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-64" message="No exception data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-64" />}>
      <RenderIf condition={txnItems->Array.length > 0}>
        <div
          className="flex flex-col sm:flex-row items-center justify-center gap-6 px-6 py-4 min-h-56">
          <PieGraph
            options={getExceptionTriagePieOptions(~items=txnItems, ~totalCount=activeTotal)}
            className="shrink-0"
          />
          <div className="flex flex-col gap-2.5 w-full max-w-52">
            {txnItems
            ->Array.mapWithIndex((item, index) =>
              <ExceptionTriageRow key={item.label} item total=activeTotal index />
            )
            ->React.array}
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={txnItems->isEmptyArray}>
        <NewAnalyticsHelper.NoData height="h-64" message="No exception data for this date range." />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
