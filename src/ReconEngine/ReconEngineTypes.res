type balanceType = {
  value: float,
  currency: string,
}

type accountType = {
  account_name: string,
  account_id: string,
  account_type: string,
  profile_id: string,
  currency: string,
  initial_balance: balanceType,
  posted_debits: balanceType,
  posted_credits: balanceType,
  pending_debits: balanceType,
  pending_credits: balanceType,
  expected_debits: balanceType,
  expected_credits: balanceType,
  mismatched_debits: balanceType,
  mismatched_credits: balanceType,
}

type accountRefType = {
  account_id: string,
  account_name: string,
}

type reconRuleAccountRefType = {
  id: string,
  account_id: string,
}

type reconRuleType = {
  rule_id: string,
  rule_name: string,
  rule_description: string,
  sources: array<reconRuleAccountRefType>,
  targets: array<reconRuleAccountRefType>,
}

type ingestionTransformationStatusType =
  | Pending
  | Processing
  | Processed
  | Failed
  | Discarded
  | UnknownIngestionTransformationStatus

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
  status: ingestionTransformationStatusType,
  upload_type: string,
  created_at: string,
  ingestion_name: string,
  version: int,
  discarded_at: string,
  discarded_status: string,
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
  last_modified_at: string,
  last_transformed_at: string,
}

type transformationHistoryType = {
  transformation_history_id: string,
  transformation_id: string,
  transformation_name: string,
  ingestion_history_id: string,
  account_id: string,
  status: ingestionTransformationStatusType,
  data: transformationData,
  processed_at: string,
  created_at: string,
}

type ruleType = {
  rule_id: string,
  rule_name: string,
}

type transactionStatus =
  | Posted
  | Mismatched
  | Expected
  | Archived
  | UnknownTransactionStatus

type entryDirectionType =
  | Debit
  | Credit
  | UnknownEntryDirectionType

type entryStatus =
  | Posted
  | Mismatched
  | Expected
  | Archived
  | Pending
  | UnknownEntryStatus

type transactionEntryType = {
  entry_id: string,
  entry_type: entryDirectionType,
  account: accountType,
  amount: balanceType,
  status: entryStatus,
}

type transactionType = {
  id: string,
  transaction_id: string,
  entries: array<transactionEntryType>,
  profile_id: string,
  credit_amount: balanceType,
  debit_amount: balanceType,
  rule: ruleType,
  transaction_status: transactionStatus,
  discarded_status: option<string>,
  version: int,
  created_at: string,
  effective_at: string,
}

type entryType = {
  entry_id: string,
  entry_type: entryDirectionType,
  account_name: string,
  transaction_id: string,
  amount: float,
  currency: string,
  status: entryStatus,
  discarded_status: option<string>,
  metadata: Js.Json.t,
  created_at: string,
  effective_at: string,
}

type processingEntryStatus =
  | Pending
  | Processed
  | NeedsManualReview
  | Archived
  | UnknownProcessingEntryStatus

type processingEntryType = {
  staging_entry_id: string,
  account: accountRefType,
  entry_type: string,
  amount: float,
  currency: string,
  status: processingEntryStatus,
  processing_mode: string,
  metadata: Js.Json.t,
  transformation_id: string,
  transformation_history_id: string,
  effective_at: string,
}

type processedEntryType = {
  entry_id: string,
  entry_type: string,
  amount: float,
  currency: string,
  status: string,
  expected: string,
  effective_at: string,
  created_at: string,
}
