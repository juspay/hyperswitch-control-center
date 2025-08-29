open Typography
open LogicUtils

module IngestionConfigDetails = {
  @react.component
  let make = (~config: ReconEngineConnectionType.connectionType) => {
    let lastSyncedAt = config.last_synced_at->getNonEmptyString
    let dataDict = config.data->getDictFromJsonObject
    let allKeyValuePairs = getKeyValuePairsFromDict(dataDict)
    let keyValuePairs = allKeyValuePairs->Array.filter(((key, _)) => {
      !(key->LogicUtils.titleToSnake == "ingestion_type")
    })
    <div className="max-w-4xl p-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-6">
        <div className="flex flex-col gap-2">
          <ReconEngineRuleDetails.StatusBadge isActive=config.is_active />
        </div>
        <div className="flex flex-col gap-2">
          <span className={`${body.md.medium} text-nd_gray-500`}>
            {"Last Sync"->React.string}
          </span>
          <span className={`${body.md.semibold} text-nd_gray-800`}>
            <TableUtils.DateCell timestamp={lastSyncedAt->Option.getOr("N/A")} textAlign={Left} />
          </span>
        </div>
        {keyValuePairs
        ->Array.map(((key, value)) => {
          <div key={key} className="flex flex-col gap-2">
            <span className={`${body.md.medium} text-nd_gray-500`}> {key->React.string} </span>
            <span className={`${body.md.semibold} text-nd_gray-800 truncate whitespace-pre`}>
              {value->React.string}
            </span>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~accountId: string) => {
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configData, setConfigData) = React.useState(_ => [])

  let getIngestionConfig = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
        ~queryParamerters=Some(`account_id=${accountId}`),
      )
      let res = await fetchDetails(url)
      let configs =
        res->LogicUtils.getArrayDataFromJson(ReconEngineConnectionType.connectionTypeToObjMapper)
      setConfigData(_ => configs)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch ingestion config"))
    }
  }

  React.useEffect(() => {
    getIngestionConfig()->ignore
    None
  }, [accountId])

  let accordionItems: array<Accordion.accordion> = configData->Array.map(config => {
    let accordionItem: Accordion.accordion = {
      title: config.name,
      renderContent: () => <IngestionConfigDetails config />,
      renderContentOnTop: None,
    }
    accordionItem
  })

  let initialExpandedArray = configData->Array.mapWithIndex((_, index) => index)
  let accordianTitleCss = `${body.lg.semibold} text-nd_gray-800`
  let accordianContainerCss = "border border-nd_gray-150 rounded-lg"

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-4">
      <RenderIf condition={configData->Array.length == 0}>
        <div className="text-center py-12">
          <span className={`${body.lg.medium} text-nd_gray-500`}>
            {"No ingestion configurations found for this account"->React.string}
          </span>
        </div>
      </RenderIf>
      <RenderIf condition={configData->Array.length > 0}>
        <Accordion
          accordion=accordionItems
          initialExpandedArray
          accordianTopContainerCss={`${accordianContainerCss}`}
          accordianBottomContainerCss="p-4"
          contentExpandCss="p-0"
          titleStyle={`${accordianTitleCss}`}
          gapClass="space-y-4"
        />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
