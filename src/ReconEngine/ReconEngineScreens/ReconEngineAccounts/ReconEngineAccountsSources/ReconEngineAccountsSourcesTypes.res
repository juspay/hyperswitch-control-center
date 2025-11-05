type sourceConfigLabel =
  | ProcessedFiles
  | FailedFiles
  | LastSync
  | Status

type sourceConfigDataType = {
  label: sourceConfigLabel,
  value: string,
  valueType: [#text | #date | #status],
}

@unboxed
type buttonActionType =
  | Download
  | Timeline

type buttonAction = {
  @as("type") buttonType: buttonActionType,
  onClick: ReactEvent.Mouse.t => unit,
  disabled: bool,
}

@unboxed
type iconActionType =
  | @as("nd-download-down") DownloadIcon
  | @as("nd-graph-chart-gantt") ChartIcon

type iconAction = {
  @as("type") iconType: iconActionType,
  onClick: ReactEvent.Mouse.t => unit,
  disabled: bool,
}

type timelineIconConfig = {
  name: string,
  color: string,
}

type timelineContainerConfig = {
  borderColor: string,
  backgroundColor: string,
}

type timelineConfig = {
  statusText: string,
  icon: timelineIconConfig,
  container: timelineContainerConfig,
}

type fileTimelineState =
  | FileAccepted
  | FileProcessed
  | FileUploaded
  | FileProcessing
  | FileReceived
  | FileRejected
  | UnknownState
