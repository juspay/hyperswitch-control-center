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

type ingestionHistorySortOption = [#MostRecent | #NeedsAttention | #FileName]

type pipelineStatCardData = {
  pipelineStatCardTitle: pipelineStatCardTitle,
  pipelineStatCardValue: valueType,
  pipelineStatCardIcon: Button.iconType,
  pipelineStatCardDescription: string,
  pipelineStatCardType: statCardType,
  pipelineStatCardClickAction: pipelineStatCardClickAction,
}

type fileUploadStatus = Idle | UploadFailed(string)

type selectedFileItem<'file> = {
  fileId: string,
  file: 'file,
  status: fileUploadStatus,
}

type pipelineDetailStatCardTitle =
  | @as("Transformation Runs") DetailTransformationRuns
  | @as("Rows Transformed") DetailRowsTransformed
  | @as("Rows Ignored") DetailRowsIgnored
  | @as("Errors") DetailErrors

type pipelineDetailStatCardData = {
  pipelineDetailStatCardLabel: pipelineDetailStatCardTitle,
  pipelineDetailStatCardValue: int,
  pipelineDetailStatCardDesc: string,
  pipelineDetailStatCardType: statCardType,
  pipelineDetailStatCardOnClick: option<unit => unit>,
}

type stagingEntrySearchType =
  | @as("staging_entry_id") SearchStagingEntryId
  | @as("order_id") SearchOrderId
  | @as("unknown") UnknownStagingEntrySearchType

@unboxed
type stagingEntrySortOrder =
  | @as("asc") Asc
  | @as("desc") Desc

type stagingEntriesCursorPayload = {
  limit: int,
  direction: ReconEngineTypes.cursorDirection,
  order: stagingEntrySortOrder,
  @as("sort_by") sortBy: ReconEngineTypes.cursor,
}

type displayField = {
  label: string,
  target: string,
  fieldIdentifier: string,
  isRequired: bool,
  typeLabel: string,
  ruleSet: ReconEngineTypes.fieldRules,
}
