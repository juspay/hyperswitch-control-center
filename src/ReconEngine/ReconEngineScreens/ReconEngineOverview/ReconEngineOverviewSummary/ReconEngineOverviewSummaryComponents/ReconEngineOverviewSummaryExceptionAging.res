open Typography

@react.component
let make = () => {
  open LogicUtils
  open ReconEngineOverviewSummaryTypes
  open ReconEngineOverviewSummaryUtils

  let getOverviewRules = ReconEngineHooks.useGetOverviewRules()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let defaultDateRange = HSwitchRemoteFilter.getDateFilteredObject(~range=180)
  let startTime =
    filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, defaultDateRange.start_time)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (agingData, setAgingData) = React.useState((_): array<exceptionAgingData> => [])

  let fetchAgingData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let buckets = getExceptionAgingBuckets(~startTime)

      let requests = buckets->Array.map(async bucket => {
        let queryParams = `start_time=${bucket.startTime}&end_time=${bucket.endTime}`
        let overviewRules = await getOverviewRules(~queryParameters=Some(queryParams))
        let total = getExceptionCount(~overviewRules)
        ({label: bucket.label, color: bucket.color, total}: exceptionAgingData)
      })

      let results = await requests->Promise.all
      setAgingData(_ => results)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if !(filterValue->isEmptyDict) {
      fetchAgingData()->ignore
    }
    None
  }, [filterValue])

  let total = agingData->Array.reduce(0, (acc, item) => acc + item.total)

  <div className="border border-nd_gray-200 rounded-xl bg-white h-full">
    <div className="flex flex-col gap-1 px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <p className={`${body.md.semibold} text-nd_gray-800`}> {"Exception aging"->React.string} </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"How long open breaks have been waiting"->React.string}
      </p>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-64" message="No exception data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-64" />}>
      <div className="px-5 py-4">
        <div className="flex items-start gap-3 mb-4">
          <span className={`${heading.xl.bold} text-nd_red-500`}>
            <ReconEngineOverviewSummaryHelper.NumberCell value={total} />
          </span>
        </div>
        <RenderIf condition={total > 0}>
          <div className="flex h-2 w-full rounded-full overflow-hidden mb-5">
            {agingData
            ->Array.filter(item => item.total > 0)
            ->Array.mapWithIndex((item, index) => {
              let pct = item.total->Int.toFloat /. total->Int.toFloat *. 100.0
              let pctStr = pct->Float.toFixedWithPrecision(~digits=0)
              let tooltipContent =
                <div className="flex flex-col gap-0.5 px-1">
                  <p className={body.xs.semibold}> {item.label->React.string} </p>
                  <p className={body.xs.regular}>
                    {`${item.total->Int.toString} exceptions · ${pctStr}%`->React.string}
                  </p>
                </div>
              let segment =
                <div
                  className="h-full cursor-default"
                  style={ReactDOM.Style.make(
                    ~width=`${pct->Float.toFixedWithPrecision(~digits=1)}%`,
                    ~backgroundColor=item.color,
                    (),
                  )}
                />
              <ToolTip
                key={index->Int.toString}
                descriptionComponent=tooltipContent
                toolTipFor=segment
                toolTipPosition=Top
              />
            })
            ->React.array}
          </div>
        </RenderIf>
        <RenderIf condition={total == 0}>
          <div className="h-2 w-full rounded-full bg-nd_gray-150 mb-5" />
        </RenderIf>
        <div className="flex flex-col gap-1">
          {agingData
          ->Array.map(item => {
            let pct = total > 0 ? item.total->Int.toFloat /. total->Int.toFloat *. 100.0 : 0.0
            let pctStr = pct->Float.toFixedWithPrecision(~digits=0)
            <div key={item.label} className="flex items-center justify-between py-1.5">
              <div className="flex items-center gap-2">
                <span
                  className="w-2 h-2 rounded-full flex-shrink-0"
                  style={ReactDOM.Style.make(~backgroundColor=item.color, ())}
                />
                <span className={`${body.sm.regular} text-nd_gray-700`}>
                  {item.label->React.string}
                </span>
              </div>
              <div className="flex items-center gap-4">
                <span className={`${body.sm.regular} text-nd_gray-400 w-8 text-right`}>
                  {`${pctStr}%`->React.string}
                </span>
                <span className={`${body.sm.semibold} text-nd_gray-800 w-8 text-right`}>
                  <ReconEngineOverviewSummaryHelper.NumberCell value={item.total} />
                </span>
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
