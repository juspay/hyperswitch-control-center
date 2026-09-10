open Typography
open LogicUtils
open APIUtils
open ReconEngineTypes

@react.component
let make = () => {
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let (statusData, setStatusData) = React.useState(_ => None)
  let (isFetching, setIsFetching) = React.useState(_ => true)

  let isProcessorActive = (status: reconProcessorStatus) =>
    switch status {
    | Running => true
    | Stopped | UnknownReconProcessorStatus => false
    }

  let processorStatusDescription = (status: reconProcessorStatus) =>
    switch status {
    | Running => "Recon processor is running"
    | Stopped => "Recon processor is stopped"
    | UnknownReconProcessorStatus => "Recon processor status is unavailable"
    }

  let fetchStatus = async (~isRefresh=false) => {
    setIsFetching(_ => true)
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#RECON_ENGINE_STATUS,
      )
      let res = await fetchDetails(url)
      let status = res->getDictFromJsonObject->ReconEngineUtils.reconEngineStatusItemToObjMapper
      setStatusData(_ => Some(status))
    } catch {
    | _ =>
      if isRefresh {
        showToast(
          ~message="Failed to refresh recon status. Please try again.",
          ~toastType=ToastError,
        )
      }
    }
    setIsFetching(_ => false)
  }

  React.useEffect(() => {
    setStatusData(_ => None)
    fetchStatus()->ignore
    None
  }, [profileId])

  let isActive =
    statusData->mapOptionOrDefault(false, status => status.processor_status->isProcessorActive)
  let dotColor = isActive ? "bg-nd_green-400" : "bg-nd_gray-400"
  let boxClass = "h-8 bg-white border border-nd_gray-300 rounded-lg"

  let statusDot =
    <span className="relative flex h-2 w-2 cursor-default">
      <RenderIf condition={isActive}>
        <span
          className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${dotColor}`}
        />
      </RenderIf>
      <span className={`relative inline-flex h-2 w-2 rounded-full ${dotColor}`} />
    </span>

  let hasData = statusData->Option.isSome
  let isReloading = isFetching && hasData
  let dotDescription =
    statusData->mapOptionOrDefault("", status =>
      status.processor_status->processorStatusDescription
    )
  let pendingText =
    statusData->mapOptionOrDefault("", status =>
      `${status.pending_staging_entries->Int.toString} Pending`
    )

  <>
    <RenderIf condition={hasData}>
      <div className="flex items-center gap-2">
        <div
          className={`flex items-center gap-2 px-2 whitespace-nowrap ${boxClass} ${isReloading
              ? "opacity-50"
              : ""}`}>
          <ToolTip toolTipPosition=Bottom description=dotDescription toolTipFor=statusDot />
          <span className={`${body.sm.semibold} text-nd_gray-600`}>
            {pendingText->React.string}
          </span>
        </div>
        <div
          className={`flex items-center justify-center w-8 cursor-pointer ${boxClass}`}
          onClick={_ =>
            if !isFetching {
              fetchStatus(~isRefresh=true)->ignore
            }}>
          <Icon
            name="sync-alt"
            size=14
            className={`text-nd_gray-600 ${isFetching
                ? "animate-spin"
                : "hover:rotate-180 transition-transform duration-500"}`}
          />
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={!hasData && isFetching}>
      <Shimmer styleClass="h-4 w-20 rounded" />
    </RenderIf>
  </>
}
