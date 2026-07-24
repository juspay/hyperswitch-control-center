type blocklistBatchJob = {
  job_id: string,
  merchant_id: string,
  status: string,
  total_rows: int,
  succeeded_rows: int,
  failed_rows: int,
  created_at: string,
  updated_at: string,
}

type blocklistBatchStatus =
  | Initiated
  | Processing
  | Completed
  | Failed
  | UnknownStatus

type blocklistBatchColType =
  | JobId
  | Status
  | TotalRows
  | SucceededRows
  | FailedRows
  | CreatedAt
  | UpdatedAt
  | Actions
