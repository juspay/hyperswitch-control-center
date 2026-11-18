open Typography
open LogicUtils
open APIUtils
open ReconEngineTypes

module StatusRow = {
  @react.component
  let make = (~label, ~data: option<processorQueueStatus>, ~isFetching) => {
    let processorStatus =
      data->mapOptionOrDefault(UnknownReconProcessorStatus, status => status.processor_status)
    let (statusText, dotColor) = switch processorStatus {
    | Running => ("Running", "bg-nd_green-400")
    | Stopped => ("Stopped", "bg-nd_gray-400")
    | UnknownReconProcessorStatus => ("Unavailable", "bg-nd_gray-400")
    }

    let isLoading = isFetching && data->Option.isNone

    <div
      className={`grid grid-cols-[auto_auto] items-center gap-x-2 whitespace-nowrap sm:flex ${body.sm.semibold}`}>
      <span className={`shrink-0 ${body.sm.semibold} text-nd_gray-700 dark:text-nd_gray-200`}>
        {label->React.string}
      </span>
      <RenderIf condition=isLoading>
        <Shimmer styleClass="h-4 w-32 rounded" />
      </RenderIf>
      <RenderIf condition={!isLoading}>
        <span className="flex items-center gap-1.5 text-nd_gray-600 dark:text-nd_gray-300">
          <span className={`h-1.5 w-1.5 shrink-0 rounded-full ${dotColor}`} />
          {statusText->React.string}
        </span>
        <span className="col-span-2 whitespace-nowrap text-nd_gray-600 dark:text-nd_gray-300">
          <span
            className={`tabular-nums ${body.sm.semibold} text-nd_gray-700 dark:text-nd_gray-200`}>
            {data
            ->mapOptionOrDefault("—", status => status.pending_entries->Int.toString)
            ->React.string}
          </span>
          {" pending"->React.string}
        </span>
      </RenderIf>
    </div>
  }
}

module Indicator = {
  @react.component
  let make = () => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod(~showErrorToast=false)
    let showToast = ToastAdapter.useShowToast()
    let (reconStatus, setReconStatus) = React.useState(_ => None)
    let (linkingStatus, setLinkingStatus) = React.useState(_ => None)
    let (isFetching, setIsFetching) = React.useState(_ => true)
    let getAbortSignal = AbortControllerHook.useAbortController()

    let fetchStatus = async (~isRefresh=false) => {
      let signal = getAbortSignal()
      setIsFetching(_ => true)
      let fetchStatusItem = async (~endpoint, ~mapStatus) => {
        try {
          let url = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=endpoint,
          )
          let res = await fetchDetails(url, ~signal)
          Some(res->getDictFromJsonObject->mapStatus)
        } catch {
        | _ => None
        }
      }
      let results = await Promise.all([
        fetchStatusItem(
          ~endpoint=#RECON_ENGINE_STATUS,
          ~mapStatus=ReconEngineUtils.reconEngineStatusItemToObjMapper,
        ),
        fetchStatusItem(
          ~endpoint=#LINKING_PROCESSOR_STATUS,
          ~mapStatus=ReconEngineUtils.linkingProcessorStatusItemToObjMapper,
        ),
      ])
      if !(signal->AbortControllerHook.isAborted) {
        switch results {
        | [recon, linking] =>
          setReconStatus(_ => recon)
          setLinkingStatus(_ => linking)
          if isRefresh && recon->Option.isNone && linking->Option.isNone {
            showToast(
              ~message="Failed to refresh processor statuses. Please try again.",
              ~toastType=ToastError,
            )
          }
        | _ => ()
        }
        setIsFetching(_ => false)
      }
    }

    React.useEffect(() => {
      fetchStatus()->ignore
      None
    }, [])

    let hasReconStatus = reconStatus->Option.isSome
    let hasLinkingStatus = linkingStatus->Option.isSome
    let hasStatus = hasReconStatus || hasLinkingStatus

    <RenderIf condition={hasStatus || isFetching}>
      <div
        role="group"
        ariaLabel="Processor status"
        ariaBusy=isFetching
        className="flex min-h-8 items-stretch rounded-lg sm:h-8 border border-nd_gray-300 bg-nd_gray-0 dark:bg-nd_gray-800 dark:border-nd_gray-600">
        <div className="flex items-center gap-3 py-1 pl-3 pr-1 sm:py-0" ariaLive=#polite>
          <RenderIf condition={!hasStatus && isFetching}>
            <Shimmer styleClass="h-4 w-32 rounded" />
          </RenderIf>
          <RenderIf condition=hasReconStatus>
            <StatusRow label="Recon" data=reconStatus isFetching />
          </RenderIf>
          <RenderIf condition={hasReconStatus && hasLinkingStatus}>
            <span
              ariaHidden=true
              className="w-px shrink-0 self-stretch my-1 bg-nd_gray-300 dark:bg-nd_gray-600 sm:my-2"
            />
          </RenderIf>
          <RenderIf condition=hasLinkingStatus>
            <StatusRow label="Flows" data=linkingStatus isFetching />
          </RenderIf>
        </div>
        <Button
          buttonType=Transparent
          buttonSize=XSmall
          showBorder=false
          ariaLabel="Refresh processor statuses"
          showTooltip=true
          tooltipText="Refresh processor statuses"
          buttonState={isFetching ? Disabled : Normal}
          customBackColor="bg-transparent"
          customRoundedClass="rounded-r-lg"
          customPaddingClass="p-0"
          customHeightClass="h-full"
          customIconMargin="m-0"
          customButtonStyle="!border-0 w-9 shrink-0 text-nd_gray-600 hover:bg-nd_gray-100 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-nd_gray-600 dark:text-nd_gray-300 dark:hover:bg-nd_gray-700"
          leftIcon={CustomIcon(
            <Icon
              name="sync-alt" size=14 className={isFetching ? "motion-safe:animate-spin" : ""}
            />,
          )}
          onClick={_ => fetchStatus(~isRefresh=true)->ignore}
        />
      </div>
    </RenderIf>
  }
}

@react.component
let make = () => {
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  <Indicator key=profileId />
}
