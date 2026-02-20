type accountData = {
  account_id: string,
  account_name: string,
}

type fileUploadType = {
  account: accountData,
  ingestion_id: string,
  file_name: string,
  timestamp: string,
}

type commonEventData = {
  accounts: array<accountData>,
  count: int,
  timestamp: string,
}

type ingestionFailedEventType = {
  account: accountData,
  count: int,
  last_failed_at: string,
}

type stagingEntriesEventType = {
  account: accountData,
  count: int,
  timestamp: string,
}

type auditEvent =
  | FileUploaded(fileUploadType)
  | IngestionsFailed(ingestionFailedEventType)
  | StagingEntriesCreated(stagingEntriesEventType)
  | StagingEntryNeedsManualReview(stagingEntriesEventType)
  | ExpectationsCreated(commonEventData)
  | TransactionsMatched(commonEventData)
  | TransactionsReconciled(commonEventData)
  | TransactionsMismatched(commonEventData)
  | UnknownAuditEvent

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
