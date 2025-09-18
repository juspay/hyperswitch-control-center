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
  | @as("View File") ViewFile
  | Download
  | Timeline

type buttonAction = {
  @as("type") buttonType: buttonActionType,
  onClick: ReactEvent.Mouse.t => unit,
}

@unboxed
type iconActionType =
  | @as("nd-eye-on") ViewIcon
  | @as("nd-download-down") DownloadIcon
  | @as("nd-graph-chart-gantt") ChartIcon

type iconAction = {
  @as("type") iconType: iconActionType,
  onClick: ReactEvent.Mouse.t => unit,
}
