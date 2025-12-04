type cardDetail = {
  title: string,
  value: string,
}

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
