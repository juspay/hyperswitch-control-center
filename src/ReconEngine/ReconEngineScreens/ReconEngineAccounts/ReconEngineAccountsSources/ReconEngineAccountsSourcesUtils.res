open ReconEngineFileManagementUtils
open ReconEngineAccountsSourcesTypes
open LogicUtils

let sourceConfigLabelToString = (label: sourceConfigLabel): string => {
  switch label {
  | ProcessedFiles => "Processed Files"
  | FailedFiles => "Failed Files"
  | LastSync => "Last Sync"
  | Status => "Status"
  }
}

let getStatusVariantFromString = (status: string): status => {
  switch status {
  | "Active" => Active
  | "Inactive" => Inactive
  | _ => UnknownStatus
  }
}

let getProcessedCount = (
  ~ingestionHistoryList: array<ReconEngineFileManagementTypes.ingestionHistoryType>,
): int => {
  ingestionHistoryList
  ->Array.filter(item => item.status->statusMapper == Processed)
  ->Array.length
}

let getFailedCount = (
  ~ingestionHistoryList: array<ReconEngineFileManagementTypes.ingestionHistoryType>,
): int => {
  ingestionHistoryList
  ->Array.filter(item => item.status->statusMapper == Failed)
  ->Array.length
}

let getHealthyStatus = (
  ~ingestionHistoryList: array<ReconEngineFileManagementTypes.ingestionHistoryType>,
): (string, string, TableUtils.labelColor) => {
  let total = ingestionHistoryList->Array.length->Int.toFloat
  let processed = getProcessedCount(~ingestionHistoryList)->Int.toFloat
  let percentage = total > 0.0 ? valueFormatter(processed *. 100.0 /. total, Rate) : "0%"

  if percentage->Float.fromString >= Some(90.0) {
    (percentage, "Healthy", TableUtils.LabelGreen)
  } else {
    (percentage, "Unhealthy", TableUtils.LabelRed)
  }
}

let getSourceConfigData = (
  ~config: ReconEngineConnectionType.connectionType,
  ~ingestionHistoryList: array<ReconEngineFileManagementTypes.ingestionHistoryType>,
): array<sourceConfigDataType> => {
  let sourceConfigData: array<sourceConfigDataType> = [
    {
      label: ProcessedFiles,
      value: getProcessedCount(~ingestionHistoryList)->Int.toString,
      valueType: #text,
    },
    {
      label: FailedFiles,
      value: getFailedCount(~ingestionHistoryList)->Int.toString,
      valueType: #text,
    },
    {
      label: LastSync,
      value: config.last_synced_at,
      valueType: #date,
    },
    {
      label: Status,
      value: config.is_active ? "Active" : "Inactive",
      valueType: #status,
    },
  ]

  sourceConfigData
}
