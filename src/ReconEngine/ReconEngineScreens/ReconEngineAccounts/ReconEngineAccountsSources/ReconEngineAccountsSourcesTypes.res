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
