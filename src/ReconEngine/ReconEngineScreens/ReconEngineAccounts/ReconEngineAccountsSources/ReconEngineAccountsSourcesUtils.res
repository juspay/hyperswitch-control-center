open ReconEngineTypes
open LogicUtils
open ReconEngineUtils

let getIngestionConfigPayloadFromDict = dict => {
  dict->ingestionConfigItemToObjMapper
}

let getIngestionHistoryPayloadFromDict = dict => {
  dict->ingestionHistoryItemToObjMapper
}

let sortByVersion = (c1: ingestionHistoryType, c2: ingestionHistoryType) => {
  compareLogic(c2.version, c1.version)
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
  ->Array.filter(item => item.status == Processed)
  ->Array.length
}

let getFailedCount = (~ingestionHistoryList: array<ingestionHistoryType>): int => {
  ingestionHistoryList
  ->Array.filter(item => item.status == Failed)
  ->Array.length
}

let getTotalCount = (~ingestionHistoryList: array<ingestionHistoryType>): int => {
  ingestionHistoryList
  ->Array.filter(item => item.status !== Discarded)
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

let getFileTimelineState = (
  status: ingestionTransformationStatusType,
  discardedStatus: option<string>,
): ReconEngineAccountsSourcesTypes.fileTimelineState => {
  switch (status, discardedStatus) {
  | (Discarded, Some("pending")) => FileAccepted
  | (Discarded, Some("processing")) => FileProcessed
  | (Processed, _) => FileUploaded
  | (Processing, _) => FileProcessing
  | (Pending, _) => FileReceived
  | (Failed, _) => FileRejected
  | _ => UnknownState
  }
}

let getTimelineConfig = (
  state: ReconEngineAccountsSourcesTypes.fileTimelineState,
): ReconEngineAccountsSourcesTypes.timelineConfig => {
  switch state {
  | FileAccepted => {
      statusText: "File Accepted",
      icon: {name: "nd-check-circle", color: "text-green-500"},
      container: {
        borderColor: "border-nd_green-200",
        backgroundColor: "bg-nd_green-100",
      },
    }
  | FileProcessed => {
      statusText: "File Processed",
      icon: {name: "nd-check-circle", color: "text-green-500"},
      container: {
        borderColor: "border-nd_green-200",
        backgroundColor: "bg-nd_green-100",
      },
    }
  | FileUploaded => {
      statusText: "File Uploaded",
      icon: {name: "nd-check-circle", color: "text-green-500"},
      container: {
        borderColor: "border-nd_green-200",
        backgroundColor: "bg-nd_green-100",
      },
    }
  | FileProcessing => {
      statusText: "File Processing",
      icon: {name: "nd-loading", color: "text-nd_primary_blue-500"},
      container: {
        borderColor: "border-nd_primary_blue-100",
        backgroundColor: "bg-nd_primary_blue-50",
      },
    }
  | FileReceived => {
      statusText: "File Received",
      icon: {name: "nd-hour-glass-outline", color: "text-nd_gray-500"},
      container: {
        borderColor: "border-nd_gray-200",
        backgroundColor: "bg-nd_gray-100",
      },
    }
  | FileRejected => {
      statusText: "File Rejected",
      icon: {name: "nd-multiple-cross", color: "text-nd_red-500"},
      container: {
        borderColor: "border-nd_red-100",
        backgroundColor: "bg-nd_red-50",
      },
    }
  | UnknownState => {
      statusText: "Unknown",
      icon: {name: "help", color: "text-nd_gray-400"},
      container: {
        borderColor: "border-nd_gray-200",
        backgroundColor: "bg-nd_gray-100",
      },
    }
  }
}
