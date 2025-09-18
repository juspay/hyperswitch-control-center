open ReconEngineTypes
open Typography
open LogicUtils
open ReconEngineAccountsTransformedEntriesTypes

module MetadataView = {
  @react.component
  let make = (~metadata) => {
    <div className="relative border rounded-lg p-2 bg-nd_gray-25">
      <HelperComponents.CopyTextCustomComp
        customParentClass="flex flex-row items-center gap-x-2 absolute right-4"
        displayValue=Some("Copy")
        customTextCss={`${Typography.body.sm.medium} text-nd_gray-600`}
        copyValue={Some(metadata->JSON.stringify)}
      />
      <PrettyPrintJson jsonToDisplay={metadata->JSON.stringify} />
    </div>
  }
}

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
  let make = (~entry: ReconEngineTypes.processingEntryType) => {
    open APIUtils
    open ReconEngineAccountsTransformedEntriesUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (transformationHistoryData, setTransformationHistoryData) = React.useState(_ =>
      Dict.make()->getTransformedEntriesTransformationHistoryPayloadFromDict
    )
    let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ =>
      Dict.make()->getTransformedEntriesIngestionHistoryPayloadFromDict
    )
    let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

    let fetchLineageData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
          ~queryParamerters=None,
          ~id=Some(entry.transformation_history_id),
        )
        let res = await fetchDetails(url)
        let transformationHistoryData =
          res
          ->getDictFromJsonObject
          ->getTransformedEntriesTransformationHistoryPayloadFromDict
        let ingestionHistoryData = await getIngestionHistory(
          ~queryParamerters=Some(
            `ingestion_history_id=${transformationHistoryData.ingestion_history_id}`,
          ),
        )
        ingestionHistoryData->Array.sort((ingestionHistory1, ingestionHistory2) =>
          compareLogic(ingestionHistory1.version, ingestionHistory2.version)
        )
        let latestIngestionHistory =
          ingestionHistoryData->getValueFromArray(
            0,
            Dict.make()->getTransformedEntriesIngestionHistoryPayloadFromDict,
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
    }, [entry.transformation_history_id])

    let lineageSections = React.useMemo(() => {
      getLineageSections(~ingestionHistoryData, ~transformationHistoryData, ~entry)
    }, (ingestionHistoryData, transformationHistoryData, entry))

    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-52" message="No data available." />}
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

module ModalContentRenderer = {
  @react.component
  let make = (~content: modalContentType, ~onClose: unit => unit) => {
    <div className="h-full relative p-6">
      {switch content {
      | MetadataContent(metadata) => <MetadataView metadata />
      | LineageContent(entry) => <LineageContent entry />
      | UnknownModalContent => React.null
      }}
      <div className="absolute bottom-0 left-0 right-0 bg-white p-4">
        <Button
          customButtonStyle="!w-full" buttonType=Button.Primary onClick={_ => onClose()} text="OK"
        />
      </div>
    </div>
  }
}

@react.component
let make = (~processingEntry: processingEntryType) => {
  let (modalState, setModalState) = React.useState(_ => {
    showModal: false,
    content: UnknownModalContent,
  })

  let openModal = (content: modalContentType) => {
    setModalState(_ => {showModal: true, content})
  }

  let closeModal = () => {
    setModalState(_ => {showModal: false, content: UnknownModalContent})
  }

  let transformedEntriesActions = [
    {
      iconType: ViewIcon,
      modalContent: MetadataContent(processingEntry.metadata),
    },
    {
      iconType: ChartIcon,
      modalContent: LineageContent(processingEntry),
    },
  ]

  let getModalHeading = (content: modalContentType) => {
    switch content {
    | MetadataContent(_) => "Metadata"
    | LineageContent(_) => "Lineage"
    | UnknownModalContent => ""
    }
  }

  <div className="flex flex-row gap-4">
    {transformedEntriesActions
    ->Array.mapWithIndex((action, index) =>
      <Icon
        key={index->Int.toString}
        name={(action.iconType :> string)}
        className="text-nd_gray-600 hover:text-nd_gray-800 hover:scale-110 cursor-pointer"
        size=16
        onClick={ev => {
          ev->ReactEvent.Mouse.stopPropagation
          openModal(action.modalContent)
        }}
      />
    )
    ->React.array}
    <Modal
      setShowModal={_ => closeModal()}
      showModal={modalState.showModal}
      closeOnOutsideClick=true
      modalHeading={getModalHeading(modalState.content)}
      modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold}`}
      modalClass="flex flex-col justify-start h-screen w-1/3 float-right overflow-hidden !bg-white"
      childClass="relative h-full">
      <ModalContentRenderer content={modalState.content} onClose={closeModal} />
    </Modal>
  </div>
}
