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

type fileUploadStatus = Idle | Failed(string)

type selectedFileItem<'file> = {
  fileId: string,
  file: 'file,
  status: fileUploadStatus,
}
