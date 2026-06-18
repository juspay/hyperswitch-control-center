open Typography

type ruleActivityItem = {
  rule: ReconEngineRevampedOverviewTypes.overviewRulesResponse,
  volume: int,
  exceptions: int,
  matchRate: float,
}

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
  let (rules, setRules) = React.useState((_): array<
    ReconEngineRevampedOverviewTypes.overviewRulesResponse,
  > => [])

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#OVERVIEW_RULES,
        ~methodType=Get,
        ~queryParameters=Some(queryParams),
      )
      let res = await fetchDetails(url)
      let entries =
        res->getArrayDataFromJson(ReconEngineRevampedOverviewUtils.overviewRulesResponseMapper)
      setRules(_ => entries)
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

  let computedRules = React.useMemo(() => {
    rules
    ->Array.map(rule => {
      open ReconEngineRevampedOverviewTypes
      let volume = rule.statuses->Array.reduce(0, (acc, s) => acc + s.count)
      let exceptions = rule.statuses->Array.reduce(
        0,
        (acc, s) =>
          switch s.status {
          | OverAmountExpected
          | UnderAmountExpected
          | OverAmountMismatch
          | UnderAmountMismatch
          | DataMismatch
          | CurrencyMismatch
          | SplitMismatch
          | PartiallyReconciled
          | Missing =>
            acc + s.count
          | _ => acc
          },
      )
      let matched = rule.statuses->Array.reduce(
        0,
        (acc, s) =>
          switch s.status {
          | MatchedAuto | MatchedManual | MatchedForce | MatchedWithTolerance | PostedManual =>
            acc + s.count
          | _ => acc
          },
      )
      let matchRate = volume > 0 ? matched->Int.toFloat /. volume->Int.toFloat *. 100.0 : 0.0
      {rule, volume, exceptions, matchRate}
    })
    ->Js.Array2.sortInPlaceWith((a, b) => b.volume - a.volume)
  }, [rules])

  let ruleRow = (item: ruleActivityItem, index: int) => {
    let matchRateStr = item.matchRate->Float.toFixedWithPrecision(~digits=1)
    let rateTextColor = item.matchRate == 100.0 ? "text-nd_green-400" : "text-nd_red-500"
    let rateBarColor = item.matchRate == 100.0 ? "bg-nd_green-400" : "bg-nd_red-500"
    let excColor = item.exceptions == 0 ? "text-nd_green-400" : "text-nd_red-500"

    <div
      key={item.rule.rule_id}
      className="grid grid-cols-[40px_1fr_80px_90px_150px] items-center border-b border-nd_gray-100 last:border-0">
      <div className="pl-5 py-2 flex items-center">
        <div
          className={`w-5 h-5 rounded-full bg-nd_gray-100 flex items-center justify-center flex-shrink-0 ${body.xs.semibold} text-nd_gray-500`}>
          {(index + 1)->Int.toString->React.string}
        </div>
      </div>
      <div className={`${body.sm.medium} text-nd_gray-800 py-2 truncate pr-3`}>
        {item.rule.rule_name->React.string}
      </div>
      <div className={`${body.sm.semibold} text-nd_gray-700 py-2 text-right pr-3`}>
        <ReconEngineRevampedHelper.NumberCell value={item.volume} />
      </div>
      <div className={`${body.sm.semibold} ${excColor} py-2 text-right pr-3`}>
        <ReconEngineRevampedHelper.NumberCell value={item.exceptions} />
      </div>
      <div className="flex items-center gap-2 py-2 pl-3 pr-5">
        <div className="w-14 h-1.5 bg-nd_gray-150 rounded-full overflow-hidden flex-shrink-0">
          <div
            className={`h-full ${rateBarColor} rounded-full`}
            style={ReactDOM.Style.make(~width=`${matchRateStr}%`, ())}
          />
        </div>
        <span className={`${body.sm.medium} ${rateTextColor}`}>
          {`${matchRateStr}%`->React.string}
        </span>
      </div>
    </div>
  }

  <div className="border border-nd_gray-200 rounded-xl bg-white h-full">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <p className={`${body.md.semibold} text-nd_gray-800`}>
        {"Top rules by activity"->React.string}
      </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"Sorted by total transaction volume"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-48" message="No rules data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-48" />}>
      <div>
        <div
          className="grid grid-cols-[40px_1fr_80px_90px_150px] pt-3 pb-2 border-b border-nd_gray-200">
          <div className="pl-5" />
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase`}>
            {"Rule"->React.string}
          </div>
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase text-right pr-3`}>
            {"Vol"->React.string}
          </div>
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase text-right pr-3`}>
            {"Exc"->React.string}
          </div>
          <div className={`${body.xs.medium} text-nd_gray-400 uppercase pl-3 pr-5`}>
            {"Match Rate"->React.string}
          </div>
        </div>
        <div className="max-h-72 overflow-y-auto">
          <RenderIf condition={computedRules->Array.length > 0}>
            {computedRules->Array.mapWithIndex(ruleRow)->React.array}
          </RenderIf>
          <RenderIf condition={computedRules->Array.length == 0}>
            <div className={`${body.sm.regular} text-nd_gray-400 text-center py-8`}>
              {"No rules found"->React.string}
            </div>
          </RenderIf>
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
