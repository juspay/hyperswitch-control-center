open ReconEngineOverviewSummaryTypes

type pipelineStatCardTitle =
  | @as("Ingestion Runs") IngestionRuns
  | @as("Processed") ProcessedRuns
  | @as("Failed") FailedRuns
  | @as("Needs Manual Review") NeedsManualReviewEntries

type pipelineStatCardData = {
  pipelineStatCardTitle: pipelineStatCardTitle,
  pipelineStatCardValue: valueType,
  pipelineStatCardIcon: Button.iconType,
  pipelineStatCardDescription: string,
  pipelineStatCardType: statCardType,
}
