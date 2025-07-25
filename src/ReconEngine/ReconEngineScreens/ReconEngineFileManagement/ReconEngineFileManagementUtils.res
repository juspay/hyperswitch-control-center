open ReconEngineFileManagementTypes
open LogicUtils

let getStatusOptions = (statusList: array<status>): array<FilterSelectBox.dropdownOption> => {
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

let statusMapper = statusStr => {
  switch statusStr {
  | "pending" => Pending
  | "processing" => Processing
  | "processed" => Processed
  | "failed" => Failed
  | _ => StatusNone
  }
}

let getStatusStringFromVariant = status => {
  switch status {
  | Pending => "pending"
  | Processing => "processing"
  | Processed => "processed"
  | Failed => "failed"
  | StatusNone => "unknown"
  }
}

let ingestionHistoryItemToObjMapper = (dict): ingestionHistoryType => {
  {
    ingestion_id: dict->getString("ingestion_id", ""),
    ingestion_name: dict->getString("ingestion_name", ""),
    ingestion_history_id: dict->getString("ingestion_history_id", ""),
    file_name: dict->getString("file_name", "N/A"),
    account_id: dict->getString("account_id", ""),
    status: dict->getString("status", ""),
    upload_type: dict->getString("upload_type", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let transformationDataMapper = (dict): transformationData => {
  {
    total_count: dict->getInt("total_count", 0),
    transformed_count: dict->getInt("transformed_count", 0),
    transformation_result: dict->getString("transformation_result", ""),
    ignored_count: dict->getInt("ignored_count", 0),
    staging_entry_ids: dict->getStrArrayFromDict("staging_entry_ids", []),
    errors: dict->getStrArrayFromDict("errors", []),
  }
}

let transformationHistoryItemToObjMapper = (dict): transformationHistoryType => {
  {
    transformation_history_id: dict->getString("transformation_history_id", ""),
    transformation_id: dict->getString("transformation_id", ""),
    account_id: dict->getString("account_id", ""),
    ingestion_history_id: dict->getString("ingestion_history_id", ""),
    transformation_name: dict->getString("transformation_name", ""),
    status: dict->getString("status", ""),
    data: dict
    ->getJsonObjectFromDict("data")
    ->getDictFromJsonObject
    ->transformationDataMapper,
    processed_at: dict->getString("processed_at", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let ingestionDataTypeMapper = (dict): ingestionDataType => {
  {
    ingestion_type: dict->getString("ingestion_type", ""),
  }
}

let ingestionConfigItemToObjMapper = (dict): ingestionConfigType => {
  {
    ingestion_id: dict->getString("ingestion_id", ""),
    is_active: dict->getBool("is_active", false),
    name: dict->getString("name", ""),
    last_synced_at: dict->getString("last_synced_at", ""),
    data: dict
    ->getJsonObjectFromDict("data")
    ->getDictFromJsonObject
    ->ingestionDataTypeMapper,
  }
}
