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

@unboxed
type mismatchType =
  | @as("amount_mismatch") AmountMismatch
  | @as("balance_direction_mismatch") BalanceDirectionMismatch
  | @as("currency_mismatch") CurrencyMismatch
  | @as("metadata_mismatch") MetadataMismatch
  | @as("unknown") UnknownMismatchType

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
  transformation_id: string,
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

@unboxed
type transactionStatus =
  | @as("posted") Posted
  | @as("mismatched") Mismatched
  | @as("expected") Expected
  | @as("archived") Archived
  | @as("void") Void
  | @as("partially_reconciled") PartiallyReconciled
  | @as("unknown") UnknownTransactionStatus

@unboxed
type entryDirectionType =
  | @as("debit") Debit
  | @as("credit") Credit
  | UnknownEntryDirectionType

@unboxed
type entryStatus =
  | @as("posted") Posted
  | @as("mismatched") Mismatched
  | @as("expected") Expected
  | @as("archived") Archived
  | @as("pending") Pending
  | @as("void") Void
  | @as("unknown") UnknownEntryStatus

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
  account_id: string,
  account_name: string,
  transaction_id: string,
  amount: float,
  currency: string,
  status: entryStatus,
  discarded_status: option<string>,
  metadata: Js.Json.t,
  data: Js.Json.t,
  version: int,
  created_at: string,
  effective_at: string,
}

type processingEntryStatus =
  | Pending
  | Processed
  | NeedsManualReview
  | Archived
  | Void
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
