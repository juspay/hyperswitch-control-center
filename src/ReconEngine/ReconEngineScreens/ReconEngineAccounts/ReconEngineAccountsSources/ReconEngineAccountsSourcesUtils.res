open ReconEngineAccountsSourcesTypes
open ReconEngineFileManagementUtils

let sourceConfigLabelToString = (label: sourceConfigLabel): string => {
  switch label {
  | ProcessedFiles => "Processed Files"
  | FailedFiles => "Failed Files"
  | LastSync => "Last Sync"
  | Status => "Status"
  }
}

let getSourceConfigData = (
  ~config: ReconEngineConnectionType.connectionType,
  ~ingestionHistoryList: array<ReconEngineFileManagementTypes.ingestionHistoryType>,
): array<sourceConfigDataType> => {
  let (processedCount: int, failedCount: int) = ingestionHistoryList->Array.reduce((0, 0), (
    (processedCount: int, failedCount: int),
    item: ReconEngineFileManagementTypes.ingestionHistoryType,
  ): (int, int) => {
    let status: ReconEngineFileManagementTypes.status = item.status->statusMapper
    switch status {
    | Processed => (processedCount + 1, failedCount)
    | Failed => (processedCount, failedCount + 1)
    | _ => (processedCount, failedCount)
    }
  })

  let sourceConfigData: array<sourceConfigDataType> = [
    {
      label: ProcessedFiles,
      value: processedCount->Int.toString,
      valueType: #text,
    },
    {
      label: FailedFiles,
      value: failedCount->Int.toString,
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
