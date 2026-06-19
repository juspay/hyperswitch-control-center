open Typography

let triageColors = ["#8B97A8", "#E8956A", "#5BAD91", "#4A90E2", "#C87880", "#7BABC8", "#D4AA55"]

let tooltipFormatter = (~totalCount) =>
  (
    @this
    (this: PieGraphTypes.pointFormatter) => {
      let pct =
        totalCount > 0 ? Math.round(this.y /. totalCount->Int.toFloat *. 100.0)->Float.toInt : 0
      `<div style="min-width:190px;border-radius:12px;background:#1A1F2E;box-shadow:0 8px 24px rgba(0,0,0,.25);overflow:hidden;">
        <div style="padding:10px 14px;">
          <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
            <div style="display:flex;align-items:center;gap:7px;">
              <span style="width:8px;height:8px;border-radius:2px;background:${this.color};flex-shrink:0;"></span>
              <span style="font-size:12px;color:rgba(255,255,255,.7);">${this.point.name}</span>
            </div>
            <span style="font-size:12px;font-weight:600;color:rgba(255,255,255,.9);">${this.y
        ->Float.toInt
        ->Int.toString}</span>
          </div>
          <div style="margin-top:6px;padding-top:6px;border-top:1px solid rgba(255,255,255,.08);display:flex;align-items:center;justify-content:space-between;">
            <span style="font-size:11px;color:rgba(255,255,255,.4);text-transform:uppercase;letter-spacing:0.4px;">exceptions</span>
            <span style="font-size:11px;font-weight:600;color:${this.color};">${pct->Int.toString}%</span>
          </div>
        </div>
      </div>`
    }
  )->PieGraphTypes.asTooltipPointFormatter

let makePieOptions = (
  items: array<ReconEngineRevampedOverviewTypes.exceptionTriageItem>,
  totalCount: int,
): PieGraphTypes.pieGraphOptions<int> => {
  let data: array<PieGraphTypes.pieGraphDataType> = items->Array.mapWithIndex((item, i) => {
    let point: PieGraphTypes.pieGraphDataType = {
      name: item.label,
      y: item.count->Int.toFloat,
      color: triageColors
      ->Array.get(i->mod(triageColors->Array.length))
      ->Option.getOr("#D95F5F"),
    }
    point
  })

  let payload: PieGraphTypes.pieGraphPayload<int> = {
    data: [
      {
        \"type": "pie",
        innerSize: "72%",
        showInLegend: false,
        name: "Exception triage",
        data,
      },
    ],
    title: {text: ""},
    tooltipFormatter: tooltipFormatter(~totalCount),
    legendFormatter: PieGraphUtils.pieGraphLegendFormatter(),
    chartSize: "88%",
    startAngle: 0,
    endAngle: 360,
    legend: {enabled: false},
  }

  let options = payload->PieGraphUtils.getPieChartOptions
  {
    ...options,
    chart: {...options.chart, width: 220, height: 220},
    title: {
      text: `<div style="display:flex;flex-direction:column;align-items:center;">
        <span style="font-size:22px;font-weight:600;color:#1F2937;line-height:26px;">${totalCount->ReconEngineRevampedUtils.formatNumber}</span>
        <span style="font-size:11px;font-weight:400;color:#667085;line-height:16px;">exceptions</span>
      </div>`,
      align: "center",
      verticalAlign: "middle",
      y: 8,
      x: 0,
      useHTML: true,
    },
  }
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

  let tabButton = (~label, ~count, ~index) => {
    let isActive = selectedTab == index
    <div
      key={index->Int.toString}
      className={`px-3 py-1 rounded-md cursor-pointer ${body.sm.medium} ${isActive
          ? "bg-white text-nd_gray-800 shadow-sm"
          : "text-nd_gray-500"} transition-colors`}
      onClick={_ => setSelectedTab(_ => index)}>
      {`${label} (${count->Int.toString})`->React.string}
    </div>
  }

  let activeItems = selectedTab == 0 ? txnItems : stagingItems
  let activeTotal = selectedTab == 0 ? txnTotal : stagingTotal

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
      <RenderIf condition={activeItems->Array.length > 0}>
        <div
          className="flex flex-col sm:flex-row items-center justify-center gap-6 px-6 py-4 min-h-56">
          <PieGraph options={makePieOptions(activeItems, activeTotal)} className="shrink-0" />
          <div className="flex flex-col gap-2.5 w-full max-w-52">
            {activeItems
            ->Array.mapWithIndex((item, i) => {
              let color =
                triageColors
                ->Array.get(i->mod(triageColors->Array.length))
                ->Option.getOr("#D95F5F")
              let pct =
                activeTotal > 0
                  ? Math.round(
                      item.count->Int.toFloat /. activeTotal->Int.toFloat *. 100.0,
                    )->Float.toInt
                  : 0
              <div key={item.label} className="flex items-center justify-between gap-3">
                <div className="flex items-center gap-2 min-w-0">
                  <span
                    className="w-2.5 h-2.5 rounded-sm shrink-0"
                    style={ReactDOM.Style.make(~backgroundColor=color, ())}
                  />
                  <span className={`${body.sm.regular} text-nd_gray-700 truncate`}>
                    {item.label->React.string}
                  </span>
                </div>
                <div className="text-right shrink-0">
                  <p className={`${body.sm.semibold} text-nd_gray-800`}>
                    {`${pct->Int.toString}%`->React.string}
                  </p>
                  <p className={`${body.xs.regular} text-nd_gray-500`}>
                    {item.count->ReconEngineRevampedUtils.formatNumber->React.string}
                  </p>
                </div>
              </div>
            })
            ->React.array}
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={activeItems->Array.length == 0}>
        <div className={`${body.sm.regular} text-nd_gray-400 text-center py-10`}>
          {"No exceptions"->React.string}
        </div>
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
