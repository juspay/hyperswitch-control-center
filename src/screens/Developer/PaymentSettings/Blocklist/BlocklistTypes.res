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

type blocklistCount = {
  total_count: int,
  counts_by_length: array<(int, int)>,
}

type blocklistCounts = {
  cardBin: blocklistCount,
  fingerprint: blocklistCount,
}

type blocklistLookup = {
  data: string,
  blocked: bool,
}
