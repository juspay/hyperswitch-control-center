// Ingestion and Transformation Status enum
type status =
  | Pending
  | Processing
  | Processed
  | Failed
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
  ingestion_id: string,
  ingestion_name: string,
  ingestion_history_id: string,
  file_name: string,
  account_id: string,
  status: string,
  upload_type: string,
  created_at: string,
}

type ingestionConfigType = {
  ingestion_id: string,
  account_id: string,
  name: string,
  description: string,
  is_active: bool,
  profile_id: string,
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
