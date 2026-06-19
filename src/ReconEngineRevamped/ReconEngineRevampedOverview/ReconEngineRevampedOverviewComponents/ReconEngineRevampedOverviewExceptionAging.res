open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open ReconEngineRevampedOverviewUtils
  open ReconEngineRevampedOverviewTypes

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let defaultDateRange = HSwitchRemoteFilter.getDateFilteredObject(~range=180)
  let startTime =
    filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, defaultDateRange.start_time)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (agingData, setAgingData) = React.useState((_): array<exceptionAgingData> => [])

  let dayMs = 24.0 *. 60.0 *. 60.0 *. 1000.0

  let fetchAgingData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let now = Js.Date.now()
      let nowIso = now->Js.Date.fromFloat->Js.Date.toISOString
      let minus1d = (now -. dayMs)->Js.Date.fromFloat->Js.Date.toISOString
      let minus3d = (now -. 3.0 *. dayMs)->Js.Date.fromFloat->Js.Date.toISOString
      let minus7d = (now -. 7.0 *. dayMs)->Js.Date.fromFloat->Js.Date.toISOString

      let buckets: array<exceptionAgingBucket> = [
        {label: "< 24h", color: "#CBD5E1", startTime: minus1d, endTime: nowIso},
        {label: "1–3 days", color: "#FCA5A5", startTime: minus3d, endTime: minus1d},
        {label: "3–7 days", color: "#F87171", startTime: minus7d, endTime: minus3d},
        {label: "> 7 days", color: "#DC2626", startTime, endTime: minus7d},
      ]

      let requests = buckets->Array.map(bucket => {
        let filters = filterValueJson->Dict.copy
        filters->Dict.set("startTime", bucket.startTime->JSON.Encode.string)
        filters->Dict.set("endTime", bucket.endTime->JSON.Encode.string)
        let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(
          ~filterValueJson=filters,
        )
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#OVERVIEW_RULES,
          ~methodType=Get,
          ~queryParameters=Some(queryParams),
        )
        fetchDetails(url)->Promise.thenResolve(response => {
          let overviewRules = response->getArrayDataFromJson(overviewRulesResponseMapper)
          let count = getExceptionCount(~overviewRules)
          ({label: bucket.label, color: bucket.color, count}: exceptionAgingData)
        })
      })

      let results = await requests->Promise.all
      setAgingData(_ => results)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTime->isNonEmptyString {
      fetchAgingData()->ignore
    }
    None
  }, (startTime, filterValue))

  let total = agingData->Array.reduce(0, (acc, item) => acc + item.count)
  let agedOver3Days = agingData->Array.reduce(0, (acc, item) =>
    if item.label == "3–7 days" || item.label == "> 7 days" {
      acc + item.count
    } else {
      acc
    }
  )

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
          <span className={`text-4xl font-bold text-nd_red-500`}>
            <ReconEngineRevampedHelper.NumberCell value={agedOver3Days} />
          </span>
          <div className="flex flex-col pt-1">
            <span className={`${body.sm.semibold} text-nd_gray-800`}>
              {"breaks aged"->React.string}
            </span>
            <span className={`${body.sm.regular} text-nd_gray-500`}>
              {`of ${total->Int.toString} open`->React.string}
            </span>
          </div>
        </div>
        <RenderIf condition={total > 0}>
          <div className="flex h-2 w-full rounded-full overflow-hidden mb-5">
            {agingData
            ->Array.filter(item => item.count > 0)
            ->Array.mapWithIndex((item, i) => {
              let pct = item.count->Int.toFloat /. total->Int.toFloat *. 100.0
              let pctStr = pct->Float.toFixedWithPrecision(~digits=0)
              let tooltipContent =
                <div className="flex flex-col gap-0.5 px-1">
                  <p className={body.xs.semibold}> {item.label->React.string} </p>
                  <p className={body.xs.regular}>
                    {`${item.count->Int.toString} exceptions · ${pctStr}%`->React.string}
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
                key={i->Int.toString}
                descriptionComponent=tooltipContent
                toolTipFor=segment
                toolTipPosition={ToolTip.Top}
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
            let pct = total > 0 ? item.count->Int.toFloat /. total->Int.toFloat *. 100.0 : 0.0
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
                  <ReconEngineRevampedHelper.NumberCell value={item.count} />
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
