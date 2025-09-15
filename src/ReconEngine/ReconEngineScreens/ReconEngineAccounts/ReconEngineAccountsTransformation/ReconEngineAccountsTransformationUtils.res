open ReconEngineFileManagementUtils
open ReconEngineAccountsTransformationTypes
open LogicUtils

let getTotalCount = (
  ~transformationHistoryList: array<ReconEngineFileManagementTypes.transformationHistoryType>,
): int => {
  transformationHistoryList->Array.length
}

let getProcessedCount = (
  ~transformationHistoryList: array<ReconEngineFileManagementTypes.transformationHistoryType>,
): int => {
  transformationHistoryList
  ->Array.filter(item => item.status->statusMapper == Processed)
  ->Array.length
}

let getHealthyStatus = (
  ~transformationHistoryList: array<ReconEngineFileManagementTypes.transformationHistoryType>,
): (string, string, TableUtils.labelColor) => {
  let total = getTotalCount(~transformationHistoryList)->Int.toFloat
  let processed = getProcessedCount(~transformationHistoryList)->Int.toFloat
  let percentage = total > 0.0 ? valueFormatter(processed *. 100.0 /. total, Rate) : "0%"

  if percentage->Float.fromString >= Some(90.0) || total == 0.0 {
    (percentage, "Healthy", TableUtils.LabelGreen)
  } else {
    (percentage, "Unhealthy", TableUtils.LabelRed)
  }
}

let getTransformationConfigData = (
  ~config: ReconEngineFileManagementTypes.transformationConfigType,
): array<transformationConfigDataType> => {
  let sourceConfigData: array<transformationConfigDataType> = [
    {
      label: TransformationId,
      value: config.id,
      valueType: #text,
    },
    {
      label: IngestionId,
      value: config.ingestion_id,
      valueType: #text,
    },
    {
      label: LastTransformedAt,
      value: config.last_transformed_at,
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
