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
  let (txnItems, setTxnItems) = React.useState(_ => [])
  let (stagingItems, setStagingItems) = React.useState(_ => [])
  let (txnTotal, setTxnTotal) = React.useState(_ => 0)
  let (stagingTotal, setStagingTotal) = React.useState(_ => 0)
  let (selectedTab, setSelectedTab) = React.useState(_ => 0)

  let fetchTriageData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let overviewRulesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#OVERVIEW_RULES,
        ~methodType=Get,
        ~queryParameters=Some(queryParams),
      )
      let manualReviewUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~queryParameters=Some(`${queryParams}&status=needs_manual_review`),
      )
      let results = await Promise.all([
        fetchDetails(overviewRulesUrl),
        fetchDetails(manualReviewUrl),
      ])
      let overviewRules =
        results
        ->Array.get(0)
        ->Option.getExn
        ->getArrayDataFromJson(ReconEngineRevampedOverviewUtils.overviewRulesResponseMapper)
      let stagingEntries =
        results
        ->Array.get(1)
        ->Option.getExn
        ->getArrayDataFromJson(ReconEngineRevampedOverviewUtils.overviewStagingEntryResponseMapper)

      let txnItems = ReconEngineRevampedOverviewUtils.getExceptionTriageItems(~overviewRules)
      let stagingItems = ReconEngineRevampedOverviewUtils.getStagingTriageItems(~stagingEntries)

      setTxnItems(_ => txnItems)
      setStagingItems(_ => stagingItems)
      setTxnTotal(_ =>
        txnItems->Array.reduce(0, (
          acc,
          item: ReconEngineRevampedOverviewTypes.exceptionTriageItem,
        ) => acc + item.count)
      )
      setStagingTotal(_ =>
        stagingItems->Array.reduce(0, (
          acc,
          item: ReconEngineRevampedOverviewTypes.exceptionTriageItem,
        ) => acc + item.count)
      )
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTime->isNonEmptyString && endTime->isNonEmptyString {
      fetchTriageData()->ignore
    }
    None
  }, (startTime, endTime, filterValue))

  let oldestLabel = {
    let startMs = startTime->Date.fromString->Date.getTime
    let nowMs = Js.Date.now()
    let diffDays = (nowMs -. startMs) /. (1000.0 *. 60.0 *. 60.0 *. 24.0)
    if diffDays < 1.0 {
      "< 1 day ago"
    } else if diffDays < 7.0 {
      `${diffDays->Float.toInt->Int.toString} days ago`
    } else if diffDays < 30.0 {
      let weeks = (diffDays /. 7.0)->Float.toInt
      `${weeks->Int.toString} ${weeks == 1 ? "week" : "weeks"} ago`
    } else {
      let months = (diffDays /. 30.0)->Float.toInt
      `${months->Int.toString} ${months == 1 ? "month" : "months"} ago`
    }
  }

  let renderList = (items: array<ReconEngineRevampedOverviewTypes.exceptionTriageItem>) => {
    let maxCount = items->Array.get(0)->Option.map(item => item.count)->Option.getOr(1)->Int.toFloat
    <div className="flex flex-col gap-1.5 py-3">
      <RenderIf condition={items->Array.length > 0}>
        {items
        ->Array.map(item => {
          let pct = maxCount > 0.0 ? item.count->Int.toFloat /. maxCount *. 100.0 : 0.0
          <div key={item.label} className="relative overflow-hidden rounded-md">
            <div
              className="absolute inset-y-0 left-0 bg-nd_primary_blue-25 rounded-md"
              style={ReactDOM.Style.make(
                ~width=`${pct->Float.toFixedWithPrecision(~digits=1)}%`,
                (),
              )}
            />
            <div className="relative flex items-center justify-between px-3 py-2.5">
              <span className={`${body.sm.regular} text-nd_gray-700`}>
                {item.label->React.string}
              </span>
              <span className={`${body.sm.semibold} text-nd_gray-800`}>
                <ReconEngineRevampedHelper.NumberCell value={item.count} />
              </span>
            </div>
          </div>
        })
        ->React.array}
      </RenderIf>
      <RenderIf condition={items->Array.length == 0}>
        <div className={`${body.sm.regular} text-nd_gray-400 text-center py-8`}>
          {"No exceptions"->React.string}
        </div>
      </RenderIf>
    </div>
  }

  let tabButton = (~label, ~count, ~index) => {
    let isActive = selectedTab == index
    let activeStyle = "bg-white text-nd_gray-800 shadow-sm"
    let inactiveStyle = "text-nd_gray-500"
    <div
      key={index->Int.toString}
      className={`px-3 py-1 rounded-md cursor-pointer ${body.sm.medium} ${isActive
          ? activeStyle
          : inactiveStyle} transition-colors`}
      onClick={_ => setSelectedTab(_ => index)}>
      {`${label} (${count->Int.toString})`->React.string}
    </div>
  }

  <div className="border border-nd_gray-200 rounded-xl bg-white h-full">
    <div
      className="flex items-center justify-between px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <div className="flex flex-col gap-0.5">
        <p className={`${body.md.semibold} text-nd_gray-800`}>
          {"Exception triage"->React.string}
        </p>
        <p className={`${body.sm.regular} text-nd_gray-600`}>
          {`${(txnTotal + stagingTotal)->Int.toString} open · oldest ${oldestLabel}`->React.string}
        </p>
      </div>
      <div className="flex items-center gap-1 bg-nd_gray-50 rounded-lg p-1">
        {tabButton(~label="Transactions", ~count=txnTotal, ~index=0)}
        {tabButton(~label="Staging", ~count=stagingTotal, ~index=1)}
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-64" message="No exception data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-64" />}>
      <div className="px-4">
        <RenderIf condition={selectedTab == 0}> {renderList(txnItems)} </RenderIf>
        <RenderIf condition={selectedTab == 1}> {renderList(stagingItems)} </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
