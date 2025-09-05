type sourceConfigLabel =
  | ProcessedFiles
  | FailedFiles
  | LastSync
  | Status

type status =
  | Active
  | Inactive
  | UnknownStatus

type sourceConfigDataType = {
  label: sourceConfigLabel,
  value: string,
  valueType: [#text | #date | #status],
}
