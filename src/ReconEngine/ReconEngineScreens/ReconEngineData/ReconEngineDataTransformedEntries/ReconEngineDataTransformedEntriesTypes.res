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

type processingEntryCursorDirection = [#next | #previous]

type processingEntrySearchType =
  | @as("staging_entry_id") SearchStagingEntryId
  | @as("order_id") SearchOrderId
  | @as("unknown") UnknownProcessingEntrySearchType

@unboxed
type processingEntrySortOrder =
  | @as("asc") Asc
  | @as("desc") Desc

type processingEntryCursorValue = {
  @as("effective_at") effectiveAt: string,
  @as("id") cursorId: string,
}

type processingEntryCursor = {
  @as("sort_field") sortField: string,
  @as("cursor_value") cursorValue: option<processingEntryCursorValue>,
}

type processingEntryCursors = {
  next: option<processingEntryCursor>,
  prev: option<processingEntryCursor>,
}

type processingEntriesV2Page = {
  processingEntries: array<ReconEngineTypes.processingEntryType>,
  cursors: processingEntryCursors,
}

type processingEntriesV2CursorPayload = {
  limit: int,
  direction: processingEntryCursorDirection,
  order: processingEntrySortOrder,
  @as("sort_by") sortBy: processingEntryCursor,
}
