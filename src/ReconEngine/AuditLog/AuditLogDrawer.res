open Typography
open AuditLogTypes
open AuditLogUtils

module EventCard = {
  @react.component
  let make = (~event: auditEvent, ~isLast: bool) => {
    let metadata = getEventMetadata(event)

    <div className="flex gap-4 px-6">
      <div className="flex flex-col items-center flex-shrink-0 pb-6 w-2">
        <div className="relative flex h-2 w-2 mt-2">
          <RenderIf condition={metadata.eventType == EventError}>
            <span
              className={`animate-ping absolute inline-flex h-full w-full rounded-full ${metadata.color} opacity-75`}
            />
          </RenderIf>
          <span className={`relative inline-flex rounded-full h-2 w-2 ${metadata.color}`} />
        </div>
        <RenderIf condition={!isLast}>
          <div className="w-px flex-1 bg-nd_gray-300 mt-1" />
        </RenderIf>
      </div>
      <div className="flex-1 pt-0 pb-6">
        <div className="flex items-start justify-between mb-2">
          <div className={`${body.md.semibold} text-nd_gray-800`}>
            {metadata.title->React.string}
          </div>
          <div className={`${body.xs.medium} text-nd_gray-500 ml-4 flex-shrink-0`}>
            <TableUtils.DateCell timestamp={getTimestamp(event)} textAlign={Left} />
          </div>
        </div>
        <div className={`${body.sm.medium} text-nd_gray-600`}>
          {metadata.description->React.string}
        </div>
      </div>
    </div>
  }
}

module EmptyState = {
  @react.component
  let make = () => {
    <div className="flex flex-col items-center justify-center h-full py-16 px-6">
      <Icon name="notification_bell" size=48 className="text-nd_gray-200 mb-4" />
      <div className={`${body.lg.semibold} text-nd_gray-800 mb-2`}>
        {"No Activity Yet"->React.string}
      </div>
      <div className={`${body.md.medium} text-nd_gray-500 text-center`}>
        {"Audit events will appear here when actions are performed"->React.string}
      </div>
    </div>
  }
}

@react.component
let make = (~showDrawer: bool) => {
  open APIUtils
  open LogicUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (auditEvents, setAuditEvents) = React.useState(_ => [])
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let fetchAuditEvents = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#AUDIT_TRAIL,
        ~methodType=Get,
      )
      let response = await fetchDetails(url)
      let events = response->getArrayFromJson([])->Array.map(getEventTypeFromJson)
      events->Array.sort(sortByTimeStamp)
      setAuditEvents(_ => events)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if showDrawer {
      fetchAuditEvents()->ignore
    }
    None
  }, [showDrawer])

  let transitionClass = showDrawer ? "translate-x-0" : "translate-x-full"

  <>
    <div
      className={`fixed right-0 top-0 h-full w-500-px bg-white shadow-2xl rounded-l-xl overflow-hidden transform transition-all duration-300 ease-in-out flex flex-col z-20 ${transitionClass}`}>
      <div className="flex flex-col gap-2 p-6 border-b border-nd_br_gray-150 bg-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Icon name="notification_bell" size=20 className="text-nd_gray-600" />
            <div className={`${heading.sm.semibold} text-nd_gray-700`}>
              {"Activity"->React.string}
            </div>
          </div>
          <Icon
            onClick={_ => fetchAuditEvents()->ignore}
            name="sync-alt"
            size=16
            className="hover:rotate-180 transition-transform duration-500 cursor-pointer text-nd_gray-600"
          />
        </div>
      </div>
      <div className="flex-1 overflow-y-auto overflow-x-hidden">
        <PageLoaderWrapper
          screenState
          customLoader={<div className="h-full flex flex-col justify-center items-center">
            <div className="animate-spin mb-1">
              <Icon name="spinner" size=20 />
            </div>
          </div>}
          customUI={<NewAnalyticsHelper.NoData height="h-44" message="No data available." />}>
          <RenderIf condition={auditEvents->Array.length == 0}>
            <EmptyState />
          </RenderIf>
          <RenderIf condition={auditEvents->Array.length > 0}>
            <div className="flex flex-col pt-4">
              {auditEvents
              ->Array.mapWithIndex((event, index) => {
                let isLast = index === auditEvents->Array.length - 1
                <EventCard key={index->Int.toString} event isLast />
              })
              ->React.array}
            </div>
          </RenderIf>
        </PageLoaderWrapper>
      </div>
    </div>
  </>
}
