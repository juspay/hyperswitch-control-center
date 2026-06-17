open Typography
open LogicUtils

module PageHeading = {
  @react.component
  let make = (~title, ~subTitle=?) => {
    let isMiniLaptopView = MatchMedia.useScreenSizeChecker(~screenSize="1300")

    let titleClass = isMiniLaptopView ? heading.sm.semibold : heading.md.semibold

    <div className="flex flex-col gap-1.5">
      <div className="flex items-center gap-4">
        <div className={`${titleClass} text-nd_gray-800`}> {title->React.string} </div>
        <OMPPermaLinkButton />
      </div>
      {switch subTitle {
      | Some(text) =>
        <RenderIf condition={text->isNonEmptyString}>
          <div className={`${body.md.regular} text-nd_gray-600`}> {text->React.string} </div>
        </RenderIf>
      | None => React.null
      }}
    </div>
  }
}

module ReconEngineStatus = {
  @react.component
  let make = () => {
    open APIUtils
    open ReconEngineRevampedUtils
    open ReconEngineRevampedTypes

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let (engineStatus, setEngineStatus) = React.useState(_ => Stopped)

    let fetchEngineStatus = async () => {
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#RECON_STATUS,
          ~methodType=Get,
        )
        let res = await fetchDetails(url)
        let reconStatus = res->getDictFromJsonObject->reconStatusResponseMapper
        setEngineStatus(_ => reconStatus.status)
      } catch {
      | _ => setEngineStatus(_ => Stopped)
      }
    }

    React.useEffect(() => {
      fetchEngineStatus()->ignore
      let intervalId = Js.Global.setInterval(() => {
        fetchEngineStatus()->ignore
      }, 10000)

      Some(() => Js.Global.clearInterval(intervalId))
    }, [])

    let (label, borderClass, dotClass, showPulse) = switch engineStatus {
    | Running => ("Engine Running", "border-nd_green-200", "bg-nd_green-500", true)
    | Stopped => ("Engine Stopped", "border-nd_red-100", "bg-nd_red-500", false)
    }

    <div className="fixed top-6 right-5">
      <div
        className={`flex items-center gap-2 rounded-full border ${borderClass} bg-white/95 px-3 py-1.5 shadow-sm backdrop-blur`}>
        <div className="relative flex h-2 w-2">
          <RenderIf condition={showPulse}>
            <span
              className={`absolute inline-flex h-full w-full animate-ping rounded-full ${dotClass} opacity-70`}
            />
          </RenderIf>
          <span className={`relative inline-flex h-2 w-2 rounded-full ${dotClass}`} />
        </div>
        <div className={`${body.sm.medium} text-nd_gray-700`}> {label->React.string} </div>
      </div>
    </div>
  }
}
