type balanceType = {
  value: float,
  currency: string,
}

type accountTypeVariant =
  | @as("credit") Credit
  | @as("debit") Debit
  | UnknownAccountTypeVariant

type accountType = {
  account_name: string,
  account_id: string,
  account_type: accountTypeVariant,
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

type transformationConfigRefType = {
  transformation_config_id: string,
  transformation_config_name: string,
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
  failed_count: int,
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

type sheetSelection =
  | ByIndex(int)
  | ByName(string)
  | UnknownSheetSelection

type parsingConfig =
  | CsvParsingConfig
  | XlsxParsingConfig({headerRowIndex: int, sheetSelection: sheetSelection})
  | FixedWidthParsingConfig
  | UnknownParsingConfig

type skipConditionOperator =
  | Equals
  | NotEquals
  | Contains
  | NotContains
  | StartsWith
  | NotStartsWith
  | EndsWith
  | NotEndsWith
  | UnknownSkipConditionOperator

type skipCondition = {
  identifier: string,
  operator: skipConditionOperator,
  value: string,
}

type skipConfig =
  | RowSkipConfig({lineNumber: int})
  | ConditionalSkipConfig({conditions: array<skipCondition>})

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

type transactionStatus =
  | @as("posted") Posted
  | @as("matched") Matched
  | @as("mismatched") Mismatched
  | @as("expected") Expected
  | @as("archived") Archived
  | @as("void") Void
  | @as("partially_reconciled") PartiallyReconciled
  | @as("unknown") UnknownTransactionStatus

type entryDirectionType =
  | @as("debit") Debit
  | @as("credit") Credit
  | UnknownEntryDirectionType

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

type mismatchedFieldType = {
  field_name: string,
  field_label: option<string>,
  expected_value: string,
  actual_value: string,
}

type transactionDataType = {
  status: transactionStatus,
  matched_data_type: option<matchedDataType>,
  reason: option<string>,
  mismatched_fields: array<mismatchedFieldType>,
}

type domainTransactionMatchedStatus =
  | Auto
  | Manual
  | Force
  | WithTolerance
  | UnknownDomainTransactionMatchedStatus

type domainTransactionPostedStatus =
  | Manual
  | UnknownDomainTransactionPostedStatus

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
  | CurrencyMismatch
  | SplitMismatch
  | Archived
  | Void
  | PartiallyReconciled
  | UnknownDomainTransactionStatus

type linkedTransactionType = {
  transaction_id: string,
  created_at: string,
  transaction_status: domainTransactionStatus,
}

type modifiedByType = {
  id: string,
  name: string,
  email: string,
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
  modified_by: option<modifiedByType>,
  has_more_entries: bool,
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
  transformation_name: option<string>,
}

type processingEntryDiscardedDataType = {reason: string}

type stagingEntryManualReviewData =
  | @as("no_rules_found") NoRulesFound
  | @as("currency_mismatch") CurrencyMismatch
  | @as("missing_search_identifier_value") MissingSearchIdentifierValue
  | @as("duplicate_entry") DuplicateEntry
  | @as("no_expectation_entry_found") NoExpectationEntryFound
  | @as("multiple_expected_entries_found") MultipleExpectedEntriesFound
  | @as("missing_match_field") MissingMatchField
  | @as("missing_unique_field") MissingUniqueField
  | @as("missing_grouping_field") MissingGroupingField
  | @as("internal_error") InternalError
  | @as("unknown") UnknownStagingEntryManualReviewData

type domainStagingEntryStatus =
  | Pending
  | NeedsManualReview(stagingEntryManualReviewData)
  | Processed
  | Void
  | Archived
  | UnknownDomainStagingEntryStatus

type processingEntryType = {
  id: string,
  staging_entry_id: string,
  account: accountRefType,
  entry_type: string,
  amount: float,
  currency: string,
  status: domainStagingEntryStatus,
  processing_mode: string,
  metadata: Js.Json.t,
  transformation_config: transformationConfigRefType,
  transformation_history_id: string,
  effective_at: string,
  order_id: string,
  version: int,
  discarded_status: option<domainStagingEntryStatus>,
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

type majorUnitValidationRule =
  | PositiveOnlyMajorUnit
  | MinValueMajorUnit(float)
  | MaxValueMajorUnit(float)
  | UnknownMajorUnitValidationRule

type replaceMode =
  | ReplaceAll
  | ReplaceSingle({occurrence: int, fromEnd: bool})
  | UnknownReplaceMode

type stringTransformationRule =
  | StrDefaultValue(string)
  | StrToUpperCase
  | StrToLowerCase
  | StrStripPrefix(string)
  | StrStripSuffix(string)
  | StrTrim
  | StrJsonExtract(string)
  | StrRegex({pattern: string, group: option<int>})
  | UnknownStringTransformationRule

type currencyTransformationRule =
  | CurrencyDefaultValue(string)
  | CurrencyTrim
  | CurrencyJsonExtract(string)
  | UnknownCurrencyTransformationRule

type balanceDirectionTransformationRule =
  | BalanceDirectionDefaultValue(string)
  | BalanceDirectionTrim
  | BalanceDirectionJsonExtract(string)
  | BalanceDirectionStartsWith({prefix: string, thenValue: string, otherwise: string})
  | UnknownBalanceDirectionTransformationRule

type numberTransformationRule =
  | NumberTrim
  | NumberJsonExtract(string)
  | UnknownNumberTransformationRule

type minorUnitTransformationRule =
  | MinorUnitTrim
  | MinorUnitJsonExtract(string)
  | MinorUnitAbsolute
  | UnknownMinorUnitTransformationRule

type majorUnitTransformationRule =
  | MajorUnitTrim
  | MajorUnitJsonExtract(string)
  | MajorUnitNegate
  | MajorUnitAbsolute
  | MajorUnitReplaceChar({fromChar: string, toChar: option<string>, mode: replaceMode})
  | UnknownMajorUnitTransformationRule

type dateTimeTransformationRule =
  | DateTimeTrim
  | DateTimeJsonExtract(string)
  | DateTimeRegex({pattern: string, group: option<int>})
  | UnknownDateTimeTransformationRule

type enumTransformationRule =
  | EnumTrim
  | EnumJsonExtract(string)
  | UnknownEnumTransformationRule

type durationUnit =
  | @as("minutes") Minutes
  | @as("hours") Hours
  | @as("days") Days
  | @as("unknown") UnknownDurationUnit

type dateTimeDuration = {value: int, unit: durationUnit}

type truncationPrecision =
  | @as("start_of_hour") StartOfHour
  | @as("start_of_day") StartOfDay
  | @as("start_of_month") StartOfMonth
  | @as("start_of_year") StartOfYear
  | @as("unknown") UnknownTruncationPrecision

type dateTimePostParseRule =
  | PostParseTruncate(truncationPrecision)
  | PostParseAddDuration(dateTimeDuration)
  | PostParseSubtractDuration(dateTimeDuration)
  | UnknownDateTimePostParseRule

type amountDelimiter = DelimiterDot | DelimiterComma | UnknownAmountDelimiter

type fieldRules =
  | StringRules({
      validation: array<stringValidationRule>,
      transformation: array<stringTransformationRule>,
    })
  | NumberRules({
      validation: array<numberValidationRule>,
      transformation: array<numberTransformationRule>,
    })
  | CurrencyRules({transformation: array<currencyTransformationRule>})
  | MinorUnitRules({
      validation: array<minorUnitValidationRule>,
      transformation: array<minorUnitTransformationRule>,
    })
  | MajorUnitRules({
      delimiter: amountDelimiter,
      validation: array<majorUnitValidationRule>,
      transformation: array<majorUnitTransformationRule>,
    })
  | DateTimeRules({
      transformation: array<dateTimeTransformationRule>,
      postParse: array<dateTimePostParseRule>,
    })
  | BalanceDirectionRules({
      creditValues: array<string>,
      debitValues: array<string>,
      transformation: array<balanceDirectionTransformationRule>,
    })
  | EnumRules({mappings: Dict.t<string>, transformation: array<enumTransformationRule>})
  | UnknownFieldRules

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
  rules: fieldRules,
}

type mainFieldType = {
  field_name: string,
  identifier: string,
  credit_values: option<array<string>>,
  debit_values: option<array<string>>,
  rules: fieldRules,
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

type overviewRuleStatusBreakdown = {
  status: domainTransactionStatus,
  count: int,
  credit_amount: balanceType,
  debit_amount: balanceType,
}

type overviewRulesResponse = {
  rule_id: string,
  rule_name: string,
  status_breakdown: array<overviewRuleStatusBreakdown>,
}

type overviewRulesTimeRange = {
  start_time: string,
  end_time: string,
}

type overviewRulesTimeSeries = {
  time_range: overviewRulesTimeRange,
  status_breakdown: array<overviewRuleStatusBreakdown>,
}

type overviewRulesTimeSeriesResponse = {
  rule_id: string,
  rule_name: string,
  time_series: array<overviewRulesTimeSeries>,
}

type stagingEntryOverviewStatusAmount = {
  status: domainStagingEntryStatus,
  count: int,
}

type accountStagingEntriesOverview = {status_breakdown: array<stagingEntryOverviewStatusAmount>}

type ruleAccountTypeVariant =
  | @as("source") Source
  | @as("target") Target
  | UnknownRuleAccountType

type accountStatusBreakdown = {
  status: domainTransactionStatus,
  credit_txn_count: int,
  debit_txn_count: int,
  credit_amount: balanceType,
  debit_amount: balanceType,
}

type accountStatusOverview = {
  account_id: string,
  account_name: string,
  account_type: accountTypeVariant,
  rule_account_type: ruleAccountTypeVariant,
  status_breakdown: array<accountStatusBreakdown>,
}

type ruleAccountsOverview = {
  rule_id: string,
  rule_name: string,
  accounts: array<accountStatusOverview>,
}

type cursorDirection = [#next | #previous]

type cursorValue = {
  @as("effective_at") effectiveAt: string,
  @as("id") cursorId: string,
}

type cursor = {
  @as("sort_field") sortField: string,
  @as("cursor_value") cursorValue: option<cursorValue>,
}

type cursors = {
  next: option<cursor>,
  prev: option<cursor>,
}

type cursorPage<'item> = {
  items: array<'item>,
  cursors: cursors,
}
