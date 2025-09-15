open ReconEngineAccountsUtils
open ReconEngineTypes
open LogicUtils
open ReconEngineUtils

let getIngestionConfigPayloadFromDict = dict => {
  dict->ingestionConfigItemToObjMapper
}

let getIngestionHistoryPayloadFromDict = dict => {
  dict->ingestionHistoryItemToObjMapper
}

let sourceConfigLabelToString = (
  label: ReconEngineAccountsSourcesTypes.sourceConfigLabel,
): string => {
  switch label {
  | ProcessedFiles => "Processed Files"
  | FailedFiles => "Failed Files"
  | LastSync => "Last Sync"
  | Status => "Status"
  }
}

let getProcessedCount = (~ingestionHistoryList: array<ingestionHistoryType>): int => {
  ingestionHistoryList
  ->Array.filter(item =>
    item.status->getIngestionAndTransformationStatusVariantFromString == Processed
  )
  ->Array.length
}

let getFailedCount = (~ingestionHistoryList: array<ingestionHistoryType>): int => {
  ingestionHistoryList
  ->Array.filter(item =>
    item.status->getIngestionAndTransformationStatusVariantFromString == Failed
  )
  ->Array.length
}

let getTotalCount = (~ingestionHistoryList: array<ingestionHistoryType>): int => {
  ingestionHistoryList
  ->Array.filter(item =>
    item.status->getIngestionAndTransformationStatusVariantFromString !== Discarded
  )
  ->Array.length
}

let getHealthyStatus = (~ingestionHistoryList: array<ingestionHistoryType>): (
  string,
  string,
  TableUtils.labelColor,
) => {
  let total = getTotalCount(~ingestionHistoryList)->Int.toFloat
  let processed = getProcessedCount(~ingestionHistoryList)->Int.toFloat
  let percentage = total > 0.0 ? valueFormatter(processed *. 100.0 /. total, Rate) : "0%"

  if percentage->Float.fromString >= Some(90.0) || total == 0.0 {
    (percentage, "Healthy", TableUtils.LabelGreen)
  } else {
    (percentage, "Unhealthy", TableUtils.LabelRed)
  }
}

let getSourceConfigData = (
  ~config: ingestionConfigType,
  ~ingestionHistoryList: array<ingestionHistoryType>,
): array<ReconEngineAccountsSourcesTypes.sourceConfigDataType> => {
  let sourceConfigData: array<ReconEngineAccountsSourcesTypes.sourceConfigDataType> = [
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

let getStatusOptions = (statusList: array<ingestionTransformationStatusType>): array<
  FilterSelectBox.dropdownOption,
> => {
  statusList->Array.map(status => {
    let value: string = (status :> string)->String.toLowerCase
    let label = (status :> string)->capitalizeString
    {
      FilterSelectBox.label,
      value,
    }
  })
}

let initialIngestionDisplayFilters = () => {
  let statusOptions = getStatusOptions([Pending, Processing, Processed, Failed])

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="status",
          ~name="status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}
