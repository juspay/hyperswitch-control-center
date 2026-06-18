open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let defaultDateRange = HSwitchRemoteFilter.getDateFilteredObject(~range=180)
  let startTime =
    filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, defaultDateRange.start_time)
  let endTime =
    filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, defaultDateRange.end_time)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accounts, setAccounts) = React.useState((_): array<
    ReconEngineRevampedOverviewTypes.overviewAccountEntry,
  > => [])

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#OVERVIEW_ACCOUNTS,
        ~methodType=Get,
        ~queryParameters=Some(queryParams),
      )
      let res = await fetchDetails(url)
      let entries =
        res->getArrayDataFromJson(ReconEngineRevampedOverviewUtils.overviewAccountEntryMapper)
      let sorted =
        entries->Js.Array2.sortInPlaceWith((a, b) =>
          b.status_counts.expected - a.status_counts.expected
        )
      setAccounts(_ => sorted)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      fetchData()->ignore
    }
    None
  }, (startTime, endTime, filterValue))

  let goodColor = "text-nd_green-400"
  let goodBg = "bg-nd_green-400"
  let badColor = "text-nd_red-500"
  let badBg = "bg-nd_red-500"

  let renderRow = (entry: ReconEngineRevampedOverviewTypes.overviewAccountEntry) => {
    let sc = entry.status_counts
    let total = sc.matched + sc.mismatched + sc.pending + sc.expected + sc.posted
    let matchRate = total > 0 ? sc.matched->Int.toFloat /. total->Int.toFloat *. 100.0 : 0.0
    let matchRateStr = matchRate->Float.toFixedWithPrecision(~digits=1)
    let rateTextColor = matchRate == 100.0 ? goodColor : badColor
    let rateBarColor = matchRate == 100.0 ? goodBg : badBg
    let breaksColor = sc.mismatched == 0 ? goodColor : badColor
    let missingColor = sc.expected == 0 ? goodColor : badColor
    let initial = entry.account_name->String.slice(~start=0, ~end=1)->String.toUpperCase

    let matchBar =
      <div className="flex items-center gap-2">
        <div className="w-16 h-1.5 bg-nd_gray-150 rounded-full overflow-hidden">
          <div
            className={`h-full ${rateBarColor} rounded-full`}
            style={ReactDOM.Style.make(~width=`${matchRateStr}%`, ())}
          />
        </div>
        <span className={`${body.sm.medium} ${rateTextColor}`}>
          {`${matchRateStr}%`->React.string}
        </span>
      </div>

    <div
      key={entry.account_id}
      className="grid grid-cols-[1fr_180px_80px_80px] items-center border-b border-nd_gray-100 last:border-0">
      <div className="flex items-center gap-3 pl-5 py-3">
        <div
          className={`w-7 h-7 rounded-md bg-nd_gray-150 flex items-center justify-center flex-shrink-0 ${body.sm.semibold} text-nd_gray-600`}>
          {initial->React.string}
        </div>
        <span className={`${body.sm.semibold} text-nd_gray-800`}>
          {entry.account_name->React.string}
        </span>
      </div>
      <div className="py-3"> {matchBar} </div>
      <div className={`${body.sm.semibold} ${breaksColor} py-3 text-right`}>
        <ReconEngineRevampedHelper.NumberCell value={sc.mismatched} />
      </div>
      <div className={`${body.sm.semibold} ${missingColor} py-3 pr-5 text-right`}>
        <ReconEngineRevampedHelper.NumberCell value={sc.expected} />
      </div>
    </div>
  }

  <div className="border border-nd_gray-200 rounded-xl bg-white">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <p className={`${body.md.semibold} text-nd_gray-800`}>
        {"Accounts needing attention"->React.string}
      </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"Sorted by missing count — accounts with the most unmatched entries first"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-48" message="No account data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-48" />}>
      <div>
        <div
          className="grid grid-cols-[1fr_180px_80px_80px] pt-4 pb-2.5 border-b border-nd_gray-200">
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide pl-5`}>
            {"Account"->React.string}
          </div>
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide`}>
            {"Match Rate"->React.string}
          </div>
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide text-right`}>
            {"Breaks"->React.string}
          </div>
          <div
            className={`${body.xs.medium} text-nd_gray-400 uppercase tracking-wide text-right pr-5`}>
            {"Missing"->React.string}
          </div>
        </div>
        <RenderIf condition={accounts->Array.length > 0}>
          {accounts->Array.map(renderRow)->React.array}
        </RenderIf>
        <RenderIf condition={accounts->Array.length == 0}>
          <div className={`${body.sm.regular} text-nd_gray-400 text-center py-8`}>
            {"No accounts found"->React.string}
          </div>
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
