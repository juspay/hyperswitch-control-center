open Typography
open ReconEngineTypes

module SourceIngestionHeader = {
  @react.component
  let make = (~ingestionHistoryData: ingestionHistoryType) => {
    <div className="flex flex-row items-center justify-between w-full px-6">
      <p className={`${body.lg.semibold} text-nd_gray-800`}>
        {"Source & Ingestion Config"->React.string}
      </p>
      {switch ingestionHistoryData.status {
      | Processed =>
        <Table.TableCell
          cell={ReconEngineAccountsUtils.getStatusLabel(ingestionHistoryData.status)}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      | _ =>
        <Table.TableCell
          cell={Label({
            title: "Attention Required",
            color: LabelOrange,
          })}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      }}
    </div>
  }
}

module TransformationHeader = {
  @react.component
  let make = (~transformationStatus) => {
    <div className="flex flex-row items-center justify-between w-full px-6">
      <p className={`${body.lg.semibold} text-nd_gray-800`}>
        {"Transformation History"->React.string}
      </p>
      {switch transformationStatus {
      | #Loading => <Shimmer styleClass="h-5 w-24 rounded-lg" />
      | #Processed =>
        <Table.TableCell
          cell={ReconEngineExceptionEntity.getStatusLabel(Processed)}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      | #AttentionRequired =>
        <Table.TableCell
          cell={Label({
            title: "Attention Required",
            color: LabelOrange,
          })}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      }}
    </div>
  }
}

module StagingEntryHeader = {
  @react.component
  let make = (~manualReviewStatus) => {
    <div className="flex flex-row items-center justify-between w-full px-6">
      <div className="flex flex-row items-center gap-2">
        <p className={`${body.lg.semibold} text-nd_gray-800`}> {"Staging Entry"->React.string} </p>
      </div>
      {switch manualReviewStatus {
      | #Loading => <Shimmer styleClass="h-5 w-24 rounded-lg" />
      | #AttentionRequired =>
        <Table.TableCell
          cell={Label({
            title: "Attention Required",
            color: LabelOrange,
          })}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      | #Processed =>
        <Table.TableCell
          cell={ReconEngineExceptionEntity.getStatusLabel(Processed)}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      }}
    </div>
  }
}

let getAccordionConfig = (
  ~ingestionHistoryData: ingestionHistoryType,
  ~transformationStatus,
  ~setTransformationStatus,
  ~selectedTransformationHistoryId,
  ~setSelectedTransformationHistoryId,
  ~manualReviewStatus,
  ~setManualReviewStatus,
  ~stagingEntryId,
  ~transformationHistoryId,
): array<Accordion.accordion> => {
  [
    {
      title: "Source & Ingestion Config",
      renderContent: () =>
        <ReconEngineAccountsOverviewIngestion ingestionId=ingestionHistoryData.ingestion_id />,
      renderContentOnTop: Some(() => <SourceIngestionHeader ingestionHistoryData />),
    },
    {
      title: "Transformation Config",
      renderContent: () =>
        <ReconEngineAccountsOverviewTransformation
          ingestionHistoryId=ingestionHistoryData.ingestion_history_id
          setSelectedTransformationHistoryId
          onTransformationStatusChange={isProcessed =>
            setTransformationStatus(_ => isProcessed ? #Processed : #AttentionRequired)}
          transformationHistoryId
        />,
      renderContentOnTop: Some(() => <TransformationHeader transformationStatus />),
    },
    {
      title: "Staging Entry",
      renderContent: () => {
        <FilterContext
          key={`recon-engine-accounts-sources-staging-${selectedTransformationHistoryId}`}
          index="recon-engine-accounts-sources-staging">
          <ReconEngineAccountsOverviewTransformedEntries
            selectedTransformationHistoryId
            onNeedsManualReviewPresent={isPresent =>
              setManualReviewStatus(_ => isPresent ? #AttentionRequired : #Processed)}
            stagingEntryId
          />
        </FilterContext>
      },
      renderContentOnTop: Some(() => <StagingEntryHeader manualReviewStatus />),
    },
  ]
}
