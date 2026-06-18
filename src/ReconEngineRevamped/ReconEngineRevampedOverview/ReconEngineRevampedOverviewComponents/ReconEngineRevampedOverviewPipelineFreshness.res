open Typography

type pipelineSourceItem = {
  name: string,
  latestAt: string,
  failedCount: int,
}

let formatTimeAgo = (isoString: string) => {
  if isoString == "" {
    "unknown"
  } else {
    let diffMs = Js.Date.now() -. isoString->Date.fromString->Date.getTime
    let diffMins = (diffMs /. 60000.0)->Float.toInt
    if diffMins < 1 {
      "just now"
    } else if diffMins < 60 {
      `${diffMins->Int.toString}m ago`
    } else if diffMins < 1440 {
      let hours = diffMins / 60
      `${hours->Int.toString}h ago`
    } else {
      let days = diffMins / 1440
      `${days->Int.toString}d ago`
    }
  }
}

let groupIngestions = (
  history: array<ReconEngineRevampedOverviewTypes.overviewIngestionHistoryResponse>,
): array<pipelineSourceItem> => {
  let grouped: Dict.t<pipelineSourceItem> = Dict.make()
  history->Array.forEach(item => {
    let name = item.ingestion_name
    let existing = grouped->Dict.get(name)
    let latestAt = switch existing {
    | Some(e) => item.created_at > e.latestAt ? item.created_at : e.latestAt
    | None => item.created_at
    }
    let prevFailed = switch existing {
    | Some(e) => e.failedCount
    | None => 0
    }
    let failedCount = prevFailed + (item.status == "failed" ? 1 : 0)
    grouped->Dict.set(name, {name, latestAt, failedCount})
  })
  grouped
  ->Dict.valuesToArray
  ->Js.Array2.sortInPlaceWith((a, b) => b.failedCount - a.failedCount)
}

let groupTransformations = (
  history: array<ReconEngineRevampedOverviewTypes.overviewTransformationHistoryResponse>,
): array<pipelineSourceItem> => {
  let grouped: Dict.t<pipelineSourceItem> = Dict.make()
  history->Array.forEach(item => {
    let name = item.transformation_name
    let existing = grouped->Dict.get(name)
    let latestAt = switch existing {
    | Some(e) => item.created_at > e.latestAt ? item.created_at : e.latestAt
    | None => item.created_at
    }
    let prevFailed = switch existing {
    | Some(e) => e.failedCount
    | None => 0
    }
    let failedCount = prevFailed + (item.status == "failed" ? 1 : 0)
    grouped->Dict.set(name, {name, latestAt, failedCount})
  })
  grouped
  ->Dict.valuesToArray
  ->Js.Array2.sortInPlaceWith((a, b) => b.failedCount - a.failedCount)
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
  let (ingestions, setIngestions) = React.useState(_ => [])
  let (transformations, setTransformations) = React.useState(_ => [])
  let (selectedTab, setSelectedTab) = React.useState(_ => 0)

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryParams = ReconEngineRevampedUtils.getQueryParamFromFilters(~filterValueJson)
      let ingestionUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~queryParameters=Some(queryParams),
      )
      let transformationUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParameters=Some(queryParams),
      )
      let results = await Promise.all([fetchDetails(ingestionUrl), fetchDetails(transformationUrl)])
      let ingestionHistory =
        results
        ->Array.get(0)
        ->Option.getExn
        ->getArrayDataFromJson(
          ReconEngineRevampedOverviewUtils.overviewIngestionHistoryResponseMapper,
        )
      let transformationHistory =
        results
        ->Array.get(1)
        ->Option.getExn
        ->getArrayDataFromJson(
          ReconEngineRevampedOverviewUtils.overviewTransformationHistoryResponseMapper,
        )
      setIngestions(_ => groupIngestions(ingestionHistory))
      setTransformations(_ => groupTransformations(transformationHistory))
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

  let tabButton = (~label, ~index) => {
    let isActive = selectedTab == index
    let activeStyle = "bg-white text-nd_gray-800 shadow-sm"
    let inactiveStyle = "text-nd_gray-500"
    <div
      key={index->Int.toString}
      className={`px-3 py-1 rounded-md cursor-pointer ${body.sm.medium} ${isActive
          ? activeStyle
          : inactiveStyle} transition-colors`}
      onClick={_ => setSelectedTab(_ => index)}>
      {label->React.string}
    </div>
  }

  let renderSourceItem = (item: pipelineSourceItem) => {
    let isAttention = item.failedCount > 0
    let iconBg = isAttention ? "bg-nd_red-50" : "bg-nd_green-50"
    let iconColor = isAttention ? "text-nd_red-500" : "text-nd_green-400"
    let badgeColor = isAttention ? "text-nd_red-500" : "text-nd_green-400"
    let badgeLabel = isAttention ? "Attention" : "Healthy"
    let timeAgo = formatTimeAgo(item.latestAt)
    let subtitle =
      item.failedCount > 0
        ? `last run ${timeAgo} · ${item.failedCount->Int.toString} failed`
        : `last run ${timeAgo} · no failures`

    <div
      key={item.name}
      className="flex items-center gap-3 px-5 py-2.5 border-b border-nd_gray-100 last:border-0">
      <div
        className={`w-8 h-8 rounded-lg ${iconBg} flex items-center justify-center flex-shrink-0 ${iconColor}`}>
        <Icon name={isAttention ? "nd-alert-triangle" : "nd-check-circle"} size=16 />
      </div>
      <div className="flex-1 min-w-0">
        <p className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
          {item.name->React.string}
        </p>
        <p className={`${body.xs.regular} text-nd_gray-500 mt-0.5`}> {subtitle->React.string} </p>
      </div>
      <div className={`${body.xs.semibold} ${badgeColor} flex items-center gap-1 flex-shrink-0`}>
        <span> {"•"->React.string} </span>
        <span> {badgeLabel->React.string} </span>
      </div>
    </div>
  }

  let renderList = (items: array<pipelineSourceItem>) => {
    <div className="max-h-72 overflow-y-auto">
      <RenderIf condition={items->Array.length > 0}>
        {items->Array.map(renderSourceItem)->React.array}
      </RenderIf>
      <RenderIf condition={items->Array.length == 0}>
        <div className={`${body.sm.regular} text-nd_gray-400 text-center py-8`}>
          {"No pipeline sources found"->React.string}
        </div>
      </RenderIf>
    </div>
  }

  <div className="border border-nd_gray-200 rounded-xl bg-white h-full">
    <div
      className="flex items-center justify-between px-5 py-3.5 border-b border-nd_gray-200 shadow-sm">
      <div className="flex flex-col gap-0.5">
        <p className={`${body.md.semibold} text-nd_gray-800`}>
          {"Pipeline freshness"->React.string}
        </p>
        <p className={`${body.sm.regular} text-nd_gray-600`}>
          {"Latest run per source"->React.string}
        </p>
      </div>
      <div className="flex items-center gap-1 bg-nd_gray-50 rounded-lg p-1">
        {tabButton(~label="Ingestions", ~index=0)}
        {tabButton(~label="Transformations", ~index=1)}
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-48" message="No pipeline data for this date range."
      />}
      customLoader={<Shimmer styleClass="w-full h-48" />}>
      <RenderIf condition={selectedTab == 0}> {renderList(ingestions)} </RenderIf>
      <RenderIf condition={selectedTab == 1}> {renderList(transformations)} </RenderIf>
    </PageLoaderWrapper>
  </div>
}
