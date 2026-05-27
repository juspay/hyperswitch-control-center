open Typography
open ReconEngineAuditLogDrawerTypes
open ReconEngineAuditLogDrawerUtils

let dotBgClass = (et: eventType): string =>
  switch et {
  | EventSuccess => "bg-nd_green-500"
  | EventInfo => "bg-nd_primary_blue-500"
  | EventWarning => "bg-nd_orange-400"
  | EventError => "bg-nd_red-500"
  | EventNone => "bg-nd_gray-300"
  }

/* Compact relative formatter (just now / 2m / 1h / 3d / Jan 4). */
let relative = (timestamp: string): string => {
  if timestamp === "" {
    "—"
  } else {
    let date = Js.Date.fromString(timestamp)
    let now = Js.Date.now()
    let diffMs = now -. date->Js.Date.getTime
    let diffMin = diffMs /. 60_000.0
    let diffHour = diffMin /. 60.0
    let diffDay = diffHour /. 24.0
    if diffMin < 1.0 {
      "just now"
    } else if diffMin < 60.0 {
      `${diffMin->Float.toInt->Int.toString}m`
    } else if diffHour < 24.0 {
      `${diffHour->Float.toInt->Int.toString}h`
    } else if diffDay < 7.0 {
      `${diffDay->Float.toInt->Int.toString}d`
    } else {
      let months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ]
      let m =
        months
        ->Array.get(date->Js.Date.getMonth->Float.toInt)
        ->Option.getOr("")
      let d = date->Js.Date.getDate->Float.toInt->Int.toString
      `${m} ${d}`
    }
  }
}

module Item = {
  @react.component
  let make = (~event: auditEvent) => {
    let meta = getEventMetadata(event)
    let ts = getTimestamp(event)
    let isError = switch meta.eventType {
    | EventError => true
    | _ => false
    }
    <div className="flex flex-row items-start gap-3 px-5 py-3 border-b border-nd_gray-100">
      <div className="relative flex h-2 w-2 mt-1.5 flex-shrink-0">
        {isError
          ? <span
              className={`animate-ping absolute inline-flex h-full w-full rounded-full ${meta.eventType->dotBgClass} opacity-70`}
            />
          : React.null}
        <span
          className={`relative inline-flex rounded-full h-2 w-2 ${meta.eventType->dotBgClass}`}
        />
      </div>
      <div className="flex flex-col gap-0.5 min-w-0 flex-1">
        <div className="flex flex-row items-center gap-2 justify-between">
          <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
            {meta.title->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-400 tabular-nums flex-shrink-0`}>
            {ts->relative->React.string}
          </span>
        </div>
        <span className={`${body.xs.medium} text-nd_gray-500 truncate`}>
          {meta.description->React.string}
        </span>
      </div>
    </div>
  }
}

module EmptyState = {
  @react.component
  let make = () =>
    <div className="flex flex-col items-center justify-center gap-3 py-12 px-6 text-center">
      <div className="w-10 h-10 rounded-full bg-nd_gray-50 grid place-items-center">
        <Icon name="notification_bell" size=18 customIconColor="#A1A8B8" />
      </div>
      <p className={`${body.sm.semibold} text-nd_gray-600`}> {"No activity yet"->React.string} </p>
      <p className={`${body.xs.medium} text-nd_gray-400 max-w-xs`}>
        {"As files land and rules fire, recent events will appear here."->React.string}
      </p>
    </div>
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (events, setEvents) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let fetchEvents = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#AUDIT_TRAIL,
        ~methodType=Get,
      )
      let response = await fetchDetails(url)
      let parsed = response->getArrayFromJson([])->Array.map(getEventTypeFromJson)
      parsed->Array.sort(sortByTimeStamp)
      /* Newest first — sortByTimeStamp compares strings ascending; we reverse so
       freshest events sit at the top of the rail. */
      let newestFirst = parsed->Array.toReversed
      setEvents(_ => newestFirst)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect0(() => {
    fetchEvents()->ignore
    None
  })

  let cappedEvents = events->Array.slice(~start=0, ~end=30)
  let displayedCount = cappedEvents->Array.length

  <aside
    className="hidden xl:flex flex-shrink-0 w-[340px] flex-col bg-white border-l border-nd_gray-150 overflow-hidden">
    <div
      className="flex flex-row items-center gap-2 px-5 h-12 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <Icon name="notification_bell" size=14 customIconColor="#606B85" />
      <span className={`${body.sm.semibold} text-nd_gray-700`}> {"Activity"->React.string} </span>
      <span className="flex-1" />
      <button
        type_="button"
        onClick={_ => fetchEvents()->ignore}
        className="w-7 h-7 rounded-md border border-nd_gray-150 bg-white text-nd_gray-500 hover:bg-nd_gray-50 grid place-items-center"
        title="Refresh">
        <Icon name="sync-alt" size=12 customIconColor="#606B85" />
      </button>
    </div>
    <div className="flex-1 overflow-y-auto">
      <PageLoaderWrapper
        screenState
        customLoader={<div className="h-32 flex items-center justify-center">
          <div className="animate-spin">
            <Icon name="spinner" size=18 customIconColor="#A1A8B8" />
          </div>
        </div>}
        customUI={<EmptyState />}>
        {displayedCount === 0
          ? <EmptyState />
          : <div className="flex flex-col">
              {cappedEvents
              ->Array.mapWithIndex((event, idx) => <Item key={idx->Int.toString} event />)
              ->React.array}
              {events->Array.length > displayedCount
                ? <div className={`${body.xs.medium} text-nd_gray-400 px-5 py-3 text-center`}>
                    {`Showing ${displayedCount->Int.toString} of ${events
                      ->Array.length
                      ->Int.toString} events`->React.string}
                  </div>
                : React.null}
            </div>}
      </PageLoaderWrapper>
    </div>
  </aside>
}
