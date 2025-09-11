type status =
  | Pending
  | Processing
  | Processed
  | Failed
  | Discarded
  | StatusNone

type transformationProcessedData = {
  total_count: int,
  transformed_count: int,
  ignored_count: int,
  staging_entry_ids: array<string>,
  errors: array<string>,
}

type transformationData = {
  transformation_result: string,
  total_count: int,
  transformed_count: int,
  ignored_count: int,
  staging_entry_ids: array<string>,
  errors: array<string>,
}

type ingestionHistoryType = {
  id: string,
  ingestion_id: string,
  ingestion_history_id: string,
  file_name: string,
  account_id: string,
  status: string,
  upload_type: string,
  created_at: string,
  ingestion_name: string,
  version: int,
  discarded_at: string,
  discarded_at_status: string,
}

type ingestionConfigType = {
  ingestion_id: string,
  account_id: string,
  is_active: bool,
  name: string,
  last_synced_at: string,
  data: JSON.t,
}

type transformationConfigType = {
  id: string,
  profile_id: string,
  ingestion_id: string,
  account_id: string,
  name: string,
  config: JSON.t,
  is_active: bool,
  created_at: string,
  last_transformed_at: string,
}

type transformationHistoryType = {
  transformation_history_id: string,
  transformation_id: string,
  transformation_name: string,
  ingestion_history_id: string,
  account_id: string,
  status: string,
  data: transformationData,
  processed_at: string,
  created_at: string,
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
