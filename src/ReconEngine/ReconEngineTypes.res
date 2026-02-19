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
  matched_debits: balanceType,
  matched_credits: balanceType,
  posted_credits: balanceType,
  posted_debits: balanceType,
  pending_debits: balanceType,
  pending_credits: balanceType,
  expected_debits: balanceType,
  expected_credits: balanceType,
  mismatched_debits: balanceType,
  mismatched_credits: balanceType,
  created_at: string,
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
  created_at: string,
}

type transformationConfigType = {
  transformation_id: string,
  profile_id: string,
  ingestion_id: string,
  account_id: string,
  name: string,
  config: JSON.t,
  is_active: bool,
  metadata_schema_id: string,
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
  | @as("matched") Matched
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
  | @as("matched") Matched
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
  order_id: string,
}

type matchedDataType =
  | @as("auto") Auto
  | @as("force") Force
  | @as("manual") Manual
  | @as("unknown") UnknownMatchedDataType

type transactionDataType = {
  status: transactionStatus,
  matched_data_type: option<matchedDataType>,
  reason: option<string>,
}

@unboxed
type domainTransactionMatchedStatus =
  | Auto
  | Manual
  | Force
  | UnknownDomainTransactionMatchedStatus

@unboxed
type domainTransactionPostedStatus =
  | Manual
  | UnknownDomainTransactionPostedStatus

@unboxed
type domainTransactionAmountMismatchStatus =
  | Expected
  | Mismatch
  | UnknownDomainTransactionAmountMismatchStatus

type domainTransactionStatus =
  | Expected
  | Posted(domainTransactionPostedStatus)
  | Matched(domainTransactionMatchedStatus)
  | OverAmount(domainTransactionAmountMismatchStatus)
  | UnderAmount(domainTransactionAmountMismatchStatus)
  | Missing
  | DataMismatch
  | Archived
  | Void
  | PartiallyReconciled
  | UnknownDomainTransactionStatus

type linkedTransactionType = {
  transaction_id: string,
  created_at: string,
  transaction_status: domainTransactionStatus,
}

type transactionType = {
  id: string,
  transaction_id: string,
  entries: array<transactionEntryType>,
  profile_id: string,
  credit_amount: balanceType,
  debit_amount: balanceType,
  rule: ruleType,
  transaction_status: domainTransactionStatus,
  discarded_status: option<domainTransactionStatus>,
  version: int,
  created_at: string,
  effective_at: string,
  data: transactionDataType,
  linked_transaction: option<linkedTransactionType>,
}

type entryType = {
  entry_id: string,
  entry_type: entryDirectionType,
  account_id: string,
  account_name: string,
  transaction_id: string,
  amount: float,
  currency: string,
  order_id: string,
  status: entryStatus,
  discarded_status: option<string>,
  metadata: Js.Json.t,
  data: Js.Json.t,
  version: int,
  created_at: string,
  effective_at: string,
  staging_entry_id: option<string>,
  transformation_id: option<string>,
}

type processingEntryStatus =
  | @as("pending") Pending
  | @as("processed") Processed
  | @as("needs_manual_review") NeedsManualReview
  | @as("archived") Archived
  | @as("void") Void
  | @as("unknown") UnknownProcessingEntryStatus

@unboxed
type needsManualReviewType =
  | @as("no_rules_found") NoRulesFound
  | @as("staging_entry_currency_mismatch") StagingEntryCurrencyMismatch
  | @as("missing_search_identifier_value") MissingSearchIdentifierValue
  | @as("duplicate_entry") DuplicateEntry
  | @as("no_expectation_entry_found") NoExpectationEntryFound
  | @as("multiple_excepted_entries_found") MultipleExceptedEntriesFound
  | @as("missing_match_field") MissingMatchField
  | @as("missing_unique_field") MissingUniqueField
  | @as("missing_grouping_field") MissingGroupingField
  | @as("unknown") UnknownNeedsManualReviewType

type processingEntryDataType = {
  status: processingEntryStatus,
  needs_manual_review_type: needsManualReviewType,
}

type processingEntryDiscardedDataType = {
  status: processingEntryStatus,
  reason: string,
}

type processingEntryType = {
  id: string,
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
  order_id: string,
  version: int,
  discarded_status: option<string>,
  data: processingEntryDataType,
  discarded_data: option<processingEntryDiscardedDataType>,
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

type stringValidationRule =
  | MaxLength(int)
  | MinLength(int)
  | UnknownStringValidationRule

type numberValidationRule =
  | MinValue(float)
  | MaxValue(float)
  | UnknownNumberValidationRule

type minorUnitValidationRule =
  | PositiveOnly
  | MinValueMinorUnit(int)
  | MaxValueMinorUnit(int)
  | UnknownMinorUnitValidationRule

type fieldTypeVariant =
  | StringField(array<stringValidationRule>)
  | NumberField(array<numberValidationRule>)
  | CurrencyField
  | MinorUnitField(array<minorUnitValidationRule>)
  | DateTimeField
  | BalanceDirectionField({credit_values: array<string>, debit_values: array<string>})
  | UnknownFieldType

type entryField =
  | String
  | Metadata(string)

type metadataFieldType = {
  identifier: string,
  field_name: entryField,
  field_type: fieldTypeVariant,
  required: bool,
  description: string,
}

type mainFieldType = {
  field_name: string,
  identifier: string,
  credit_values: option<array<string>>,
  debit_values: option<array<string>>,
}

type uniqueConstraintTypeVariant =
  | SingleField(string)
  | UnknownConstraint

type uniqueConstraintType = {
  unique_constraint_type: uniqueConstraintTypeVariant,
  description: string,
}

type schemaFieldsType = {
  main_fields: array<mainFieldType>,
  metadata_fields: array<metadataFieldType>,
}

type schemaDataType = {
  schema_type: string,
  fields: schemaFieldsType,
  unique_constraint: uniqueConstraintType,
  processing_mode: string,
}

type metadataSchemaType = {
  id: string,
  schema_id: string,
  profile_id: string,
  account_id: string,
  schema_data: schemaDataType,
  version: int,
  created_at: string,
  last_modified_at: string,
}

type columnMappingTabs = [#default | #advanced]
