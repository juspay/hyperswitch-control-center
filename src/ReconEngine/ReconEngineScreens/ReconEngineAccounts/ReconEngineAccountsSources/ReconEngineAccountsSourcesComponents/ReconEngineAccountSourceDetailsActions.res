open ReconEngineTypes
open Typography

module TimelineItem = {
  @react.component
  let make = (~item: ingestionHistoryType, ~isLast: bool) => {
    open LogicUtils
    open ReconEngineAccountsSourcesUtils

    let fileState = getFileTimelineState(item.status, Some(item.discarded_status))
    let config = getTimelineConfig(fileState)

    <div key={item.id} className="relative">
      <div className="flex items-start">
        <div className="flex flex-col items-center mr-4">
          <div
            className={`w-8 h-8 rounded-lg flex items-center justify-center border ${config.container.borderColor} ${config.container.backgroundColor}`}>
            <Icon name={config.icon.name} className={config.icon.color} size=16 />
          </div>
          <RenderIf condition={!isLast}>
            <div className="w-1-px h-16 bg-nd_gray-150" />
          </RenderIf>
        </div>
        <div className="flex-1 pb-8">
          <div className="flex flex-col">
            <p className={`${body.lg.semibold} text-nd_gray-800 mb-1`}>
              {config.statusText->React.string}
            </p>
            <div className={`${body.md.medium} text-nd_gray-400`}>
              <TableUtils.DateCell
                timestamp={item.discarded_at->isEmptyString ? item.created_at : item.discarded_at}
                textAlign=Left
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~ingestionHistory: ingestionHistoryType) => {
  open ReconEngineAccountsSourcesTypes
  open ReconEngineAccountsSourcesUtils

  let (showModal, setShowModal) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
  let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ => [
    Dict.make()->getIngestionHistoryPayloadFromDict,
  ])

  let ingestionHistoryIconActions = [
    {
      iconType: ViewIcon,
      onClick: _ => (),
    },
    {
      iconType: DownloadIcon,
      onClick: _ => (),
    },
    {
      iconType: ChartIcon,
      onClick: ev => {
        ev->ReactEvent.Mouse.stopPropagation
        setShowModal(_ => true)
      },
    },
  ]

  let fetchIngestionHistoryData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let queryString = `ingestion_history_id=${ingestionHistory.ingestion_history_id}`
      let ingestionHistoryList = await getIngestionHistory(~queryParamerters=Some(queryString))
      if ingestionHistoryList->Array.length > 0 {
        ingestionHistoryList->Array.sort(sortByVersion)
        setIngestionHistoryData(_ => ingestionHistoryList)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if showModal {
      fetchIngestionHistoryData()->ignore
    }
    None
  }, [showModal])

  <div className="flex flex-row gap-4">
    <Modal
      setShowModal
      showModal
      closeOnOutsideClick=true
      modalClass="flex flex-col justify-start h-screen w-1/3 float-right overflow-hidden !bg-white"
      modalHeading="File Timeline"
      modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold}`}
      childClass="relative h-full">
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-52" message="No data available." />}
        customLoader={<div className="h-full flex flex-col justify-center items-center">
          <div className="animate-spin mb-1">
            <Icon name="spinner" size=20 />
          </div>
        </div>}>
        <div className="h-full relative">
          <div className="absolute inset-0 overflow-y-auto p-4">
            <div className="p-4">
              <RenderIf condition={ingestionHistoryData->Array.length > 0}>
                {ingestionHistoryData
                ->Array.mapWithIndex((item, index) => {
                  let isLast = index === ingestionHistoryData->Array.length - 1
                  <TimelineItem key={item.id} item isLast />
                })
                ->React.array}
              </RenderIf>
            </div>
          </div>
          <div className="absolute bottom-3 left-0 right-0 bg-white p-4">
            <Button
              customButtonStyle="!w-full"
              buttonType=Button.Primary
              onClick={_ => setShowModal(_ => false)}
              text="OK"
            />
          </div>
        </div>
      </PageLoaderWrapper>
    </Modal>
    {ingestionHistoryIconActions
    ->Array.mapWithIndex((action, index) =>
      <Icon
        key={index->Int.toString}
        name={(action.iconType :> string)}
        size=16
        onClick={action.onClick}
      />
    )
    ->React.array}
  </div>
}
