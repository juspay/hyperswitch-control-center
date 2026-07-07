open ReconEngineOverviewSummaryTypes

type pipelineStatCardTitle =
  | @as("Ingestion Runs") IngestionRuns
  | @as("Processed") ProcessedRuns
  | @as("Failed") FailedRuns
  | @as("Needs Manual Review") NeedsManualReviewEntries

type pipelineStatCardClickAction =
  | ClearStatusFilter
  | SetStatusFilter(string)
  | NoAction

type pipelineStatCardData = {
  pipelineStatCardTitle: pipelineStatCardTitle,
  pipelineStatCardValue: valueType,
  pipelineStatCardIcon: Button.iconType,
  pipelineStatCardDescription: string,
  pipelineStatCardType: statCardType,
  pipelineStatCardClickAction: pipelineStatCardClickAction,
}

type fileState<'file> =
  | NoFile
  | FileSelected('file)
  | Uploading('file)

type pipelineDetailStatCardData = {
  pipelineDetailStatCardLabel: string,
  pipelineDetailStatCardValue: int,
  pipelineDetailStatCardDesc: string,
  pipelineDetailStatCardDescColor: string,
  pipelineDetailStatCardOnClick: option<unit => unit>,
}
