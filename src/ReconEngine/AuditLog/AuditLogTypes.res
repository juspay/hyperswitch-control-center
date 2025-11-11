type accountData = {
  account_id: string,
  account_name: string,
}

type auditEvent =
  | FileUploaded({account: accountData, ingestion_id: string, file_name: string, timestamp: string})
  | IngestionsFailed({account: accountData, count: int, last_failed_at: string})
  | StagingEntriesCreated({account: accountData, count: int, timestamp: string})
  | StagingEntryNeedsManualReview({account: accountData, count: int, timestamp: string})
  | ExpectationsCreated({accounts: array<accountData>, count: int, timestamp: string})
  | TransactionsReconciled({accounts: array<accountData>, count: int, timestamp: string})
  | TransactionsMismatched({accounts: array<accountData>, count: int, timestamp: string})
  | NoAuditEvent

type eventType =
  | EventSuccess
  | EventInfo
  | EventWarning
  | EventError
  | EventNone

type eventMetadata = {
  eventType: eventType,
  color: string,
  title: string,
  description: string,
}
