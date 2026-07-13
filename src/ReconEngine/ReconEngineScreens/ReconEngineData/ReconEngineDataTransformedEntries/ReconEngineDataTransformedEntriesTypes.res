@unboxed
type iconActionType =
  | @as("nd-eye-on") ViewIcon
  | @as("nd-graph-chart-gantt") ChartIcon
  | UnknownIcon

type modalContentType =
  | MetadataContent(Js.Json.t)
  | LineageContent(ReconEngineTypes.processingEntryType)
  | UnknownModalContent

type modalState = {
  showModal: bool,
  content: modalContentType,
}

type iconAction = {
  @as("type") iconType: iconActionType,
  modalContent: modalContentType,
}

type lineageFieldType = {
  lineageFieldLabel: string,
  lineageFieldValue: string,
  lineageFileCopyable: bool,
}

type lineageSectionType = {
  lineageSectionTitle: string,
  lineageSectionFields: array<lineageFieldType>,
}

type transformedEntriesViewType =
  | AllViewType
  | ProcessedViewType
  | NeedsManualReviewViewType
  | UnknownTransformedEntriesViewType

type cardDetail = {
  title: string,
  value: string,
  viewType: transformedEntriesViewType,
}

type processingEntrySearchType =
  | @as("staging_entry_id") SearchStagingEntryId
  | @as("order_id") SearchOrderId
  | @as("unknown") UnknownProcessingEntrySearchType

@unboxed
type processingEntrySortOrder =
  | @as("asc") Asc
  | @as("desc") Desc

type processingEntriesV2CursorPayload = {
  limit: int,
  direction: ReconEngineTypes.cursorDirection,
  order: processingEntrySortOrder,
  @as("sort_by") sortBy: ReconEngineTypes.cursor,
}
