open LogicUtils
open Typography

module LineageCard = {
  @react.component
  let make = (~title: string, ~children: React.element) => {
    <div className="flex flex-col gap-4 justify-center p-3 border rounded-lg bg-nd_gray-25">
      <p className={`${body.lg.semibold} text-nd_gray-800`}> {title->React.string} </p>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6"> {children} </div>
    </div>
  }
}

module LineageField = {
  @react.component
  let make = (~label: string, ~value: string, ~copyable: bool=false) => {
    <div className="flex flex-col gap-2">
      <p className={`${body.md.medium} text-nd_gray-400`}> {label->React.string} </p>
      {if copyable {
        <HelperComponents.CopyTextCustomComp
          customParentClass="flex flex-row items-center gap-x-2"
          displayValue=Some(value)
          customTextCss={`${body.lg.medium} text-nd_gray-600 truncate`}
          copyValue={Some(value)}
          customIconCss=""
        />
      } else {
        <p className={`${body.lg.medium} text-nd_gray-600`}> {value->React.string} </p>
      }}
    </div>
  }
}

module LineageContent = {
  @react.component
  let make = (~entry: ReconEngineTypes.entryType) => {
    open APIUtils
    open ReconEngineTransactionsUtils
    open ReconEngineTransactionsTypes

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (transformationHistoryData, setTransformationHistoryData) = React.useState(_ =>
      Dict.make()->getTransactionsTransformationHistoryPayloadFromDict
    )
    let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ =>
      Dict.make()->getTransactionsIngestionHistoryPayloadFromDict
    )
    let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
    let (processingEntryData, setProcessingEntryData) = React.useState(_ =>
      Dict.make()->getTransactionsProcessingEntryPayloadFromDict
    )

    let fetchLineageData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let entryUrl = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
          ~queryParameters=None,
          ~id=entry.staging_entry_id,
        )
        let processingEntry = await fetchDetails(entryUrl)
        let processingEntryData =
          processingEntry
          ->getDictFromJsonObject
          ->getTransactionsProcessingEntryPayloadFromDict
        setProcessingEntryData(_ => processingEntryData)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
          ~queryParameters=None,
          ~id=Some(processingEntryData.transformation_history_id),
        )
        let res = await fetchDetails(url)
        let transformationHistoryData =
          res
          ->getDictFromJsonObject
          ->getTransactionsTransformationHistoryPayloadFromDict
        let ingestionHistoryData = await getIngestionHistory(
          ~queryParameters=Some(
            `ingestion_history_id=${transformationHistoryData.ingestion_history_id}`,
          ),
        )
        ingestionHistoryData->Array.sort((ingestionHistory1, ingestionHistory2) =>
          compareLogic(ingestionHistory1.version, ingestionHistory2.version)
        )
        let latestIngestionHistory =
          ingestionHistoryData->getValueFromArray(
            0,
            Dict.make()->getTransactionsIngestionHistoryPayloadFromDict,
          )
        if (
          latestIngestionHistory.ingestion_history_id->isNonEmptyString ||
            transformationHistoryData.transformation_id->isNonEmptyString
        ) {
          setTransformationHistoryData(_ => transformationHistoryData)
          setIngestionHistoryData(_ => latestIngestionHistory)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          setScreenState(_ => PageLoaderWrapper.Custom)
        }
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    React.useEffect(() => {
      fetchLineageData()->ignore
      None
    }, [entry.staging_entry_id])

    let lineageSections = React.useMemo(() => {
      getLineageSections(
        ~ingestionHistoryData,
        ~transformationHistoryData,
        ~processingEntry=processingEntryData,
        ~entry,
      )
    }, (ingestionHistoryData, transformationHistoryData, entry))

    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-52" message="Lineage not available for manually created entries."
      />}
      customLoader={<Shimmer styleClass="h-52 w-full rounded-lg" />}>
      <div className="flex flex-col gap-4">
        {lineageSections
        ->Array.mapWithIndex((section, sectionIndex) => {
          <React.Fragment key={sectionIndex->Int.toString}>
            <LineageCard title={section.lineageSectionTitle}>
              <React.Fragment>
                {section.lineageSectionFields
                ->Array.mapWithIndex((field, fieldIndex) =>
                  <LineageField
                    key={fieldIndex->Int.toString}
                    label={field.lineageFieldLabel}
                    value={field.lineageFieldValue}
                    copyable={field.lineageFileCopyable}
                  />
                )
                ->React.array}
              </React.Fragment>
            </LineageCard>
            <RenderIf condition={sectionIndex < Array.length(lineageSections) - 1}>
              <Icon name="arrow-down" className="text-nd_gray-400 self-center" size=16 />
            </RenderIf>
          </React.Fragment>
        })
        ->React.array}
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~entry: ReconEngineTypes.entryType) => {
  let (showModal, setShowModal) = React.useState(_ => false)

  <RenderIf condition={entry.staging_entry_id->Option.isSome}>
    <Icon
      name="nd-graph-chart-gantt"
      className="text-nd_gray-600 hover:text-nd_gray-800 hover:scale-110 cursor-pointer"
      size=16
      onClick={ev => {
        ev->ReactEvent.Mouse.stopPropagation
        setShowModal(_ => true)
      }}
    />
    <Modal
      setShowModal
      showModal
      closeOnOutsideClick=true
      modalHeading="Lineage"
      modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold}`}
      modalClass="flex flex-col justify-start h-screen w-1/3 float-right overflow-hidden !bg-white"
      childClass="relative h-full">
      <div className="h-full p-6 flex flex-col justify-between">
        <div className="flex flex-col max-h-750-px overflow-y-auto">
          <LineageContent entry />
        </div>
        <Button
          customButtonStyle="!w-full"
          buttonType=Primary
          onClick={_ => setShowModal(_ => false)}
          text="OK"
        />
      </div>
    </Modal>
  </RenderIf>
}
