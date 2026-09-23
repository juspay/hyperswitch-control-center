type blocklistBatchJobType =
  | @as("upload") Upload
  | @as("export") Export
  | @as("profile_clone") ProfileClone
  | @as("unknown") UnknownJobType

type cloneTargetMetadata = {
  profile_id: string,
  status: string,
  processed_rows: int,
  error_message: option<string>,
}

type blocklistBatchJob = {
  job_id: string,
  merchant_id: string,
  job_type: blocklistBatchJobType,
  status: string,
  total_rows: int,
  succeeded_rows: int,
  failed_rows: int,
  downloadable: bool,
  created_at: string,
  updated_at: string,
  clone_targets: array<cloneTargetMetadata>,
}

type blocklistBatchStatus =
  | Initiated
  | Processing
  | Completed
  | Failed
  | UnknownStatus

type blocklistBatchColType =
  | JobId
  | JobType
  | Status
  | Targets
  | TotalRows
  | SucceededRows
  | FailedRows
  | CreatedAt
  | UpdatedAt
  | Actions

type blocklistDataKind =
  | CardBin
  | ExtendedCardBin
  | GenericCardBin
  | Fingerprint

type blocklistEntryOperation =
  | AddBlocklistEntry
  | DeleteBlocklistEntry

type blocklistEntry = {
  fingerprint_id: string,
  data_kind: string,
  created_at: string,
}

type blocklistCountResponse = {
  total_count: int,
  counts_by_length: array<(int, int)>,
}

type blocklistCountsByKind = {
  cardBin: blocklistCountResponse,
  fingerprint: blocklistCountResponse,
}

type blocklistCountCard = {
  title: string,
  count: int,
}

type blocklistLookup = {
  data: string,
  blocked: bool,
}
