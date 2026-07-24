open ReconEngineTypes
open LogicUtils

let pluralText = (~count) => count == 1 ? "" : "s"

let getTransactionStatusVariantFromString = (status: string): transactionStatus => {
  switch status {
  | "posted" => Posted
  | "matched" => Matched
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | "void" => Void
  | "partially_reconciled" => PartiallyReconciled
  | _ => UnknownTransactionStatus
  }
}

let getMatchedDataTypeVariantFromString = (matchedType: string): matchedDataType => {
  switch matchedType->String.toLowerCase {
  | "auto" => Auto
  | "force" => Force
  | "manual" => Manual
  | _ => UnknownMatchedDataType
  }
}

let getEntryStatusVariantFromString = (entryType: string): entryStatus => {
  switch entryType->String.toLowerCase {
  | "posted" => Posted
  | "matched" => Matched
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | "pending" => Pending
  | "void" => Void
  | _ => UnknownEntryStatus
  }
}

let cursorFromDict = (dict): cursor => {
  let cursorValueDict = dict->getDictfromDict("cursor_value")
  {
    sortField: dict->getString("sort_field", "effective_at"),
    cursorValue: Some({
      effectiveAt: cursorValueDict->getString("effective_at", ""),
      cursorId: cursorValueDict->getString("id", ""),
    }),
  }
}

let defaultCursorSortBy: cursor = {sortField: "effective_at", cursorValue: None}

let cursorsFromDict = (dict): cursors => {
  let getCursor = key => dict->getOptionObj(key)->Option.map(cursorFromDict)
  {next: getCursor("next_cursor"), prev: getCursor("prev_cursor")}
}

let getProcessingEntryStatusVariantFromString = (status: string): processingEntryStatus => {
  switch status->String.toLowerCase {
  | "pending" => Pending
  | "processed" => Processed
  | "archived" => Archived
  | "needs_manual_review" => NeedsManualReview
  | "void" => Void
  | _ => UnknownProcessingEntryStatus
  }
}

let getMismatchTypeVariantFromString = (mismatchType: string): mismatchType => {
  switch mismatchType->String.toLowerCase {
  | "amount_mismatch" => AmountMismatch
  | "balance_direction_mismatch" => BalanceDirectionMismatch
  | "currency_mismatch" => CurrencyMismatch
  | "metadata_mismatch" => MetadataMismatch
  | _ => UnknownMismatchType
  }
}

let getNeedsManualReviewTypeVariantFromString = (reviewType: string): needsManualReviewType => {
  switch reviewType->String.toLowerCase {
  | "no_rules_found" => NoRulesFound
  | "staging_entry_currency_mismatch" => StagingEntryCurrencyMismatch
  | "duplicate_entry" => DuplicateEntry
  | "no_expectation_entry_found" => NoExpectationEntryFound
  | "missing_search_identifier_value" => MissingSearchIdentifierValue
  | "missing_unique_field" => MissingUniqueField
  | _ => UnknownNeedsManualReviewType
  }
}

let ingestionAndTransformationStatusTypeFromString = (
  status: string,
): ingestionTransformationStatusType => {
  switch status->String.toLowerCase {
  | "pending" => Pending
  | "processing" => Processing
  | "processed" => Processed
  | "failed" => Failed
  | "discarded" => Discarded
  | _ => UnknownIngestionTransformationStatus
  }
}

let getAmountPayload = dict => {
  {
    value: dict->getFloat("value", 0.0),
    currency: dict->getString("currency", ""),
  }
}

let getDomainTransactionPostedStatusFromString = (
  status: string,
): domainTransactionPostedStatus => {
  switch status->String.toLowerCase {
  | "manual" => Manual
  | _ => UnknownDomainTransactionPostedStatus
  }
}

let getDomainTransactionMatchedStatusFromString = (
  status: string,
): domainTransactionMatchedStatus => {
  switch status->String.toLowerCase {
  | "auto" => Auto
  | "manual" => Manual
  | "force" => Force
  | _ => UnknownDomainTransactionMatchedStatus
  }
}

let getDomainTransactionAmountMismatchStatusFromString = (
  status: string,
): domainTransactionAmountMismatchStatus => {
  switch status->String.toLowerCase {
  | "expected" => Expected
  | "mismatch" => Mismatch
  | _ => UnknownDomainTransactionAmountMismatchStatus
  }
}

let getDomainTransactionStatus = (
  status: string,
  dict: Js.Dict.t<Js.Json.t>,
): domainTransactionStatus => {
  let subStatus = dict->getString("sub_status", "")
  switch status->String.toLowerCase {
  | "expected" => Expected
  | "missing" => Missing
  | "posted" => Posted(subStatus->getDomainTransactionPostedStatusFromString)
  | "matched" => Matched(subStatus->getDomainTransactionMatchedStatusFromString)
  | "over_amount" => OverAmount(subStatus->getDomainTransactionAmountMismatchStatusFromString)
  | "under_amount" => UnderAmount(subStatus->getDomainTransactionAmountMismatchStatusFromString)
  | "data_mismatch" => DataMismatch
  | "archived" => Archived
  | "void" => Void
  | "partially_reconciled" => PartiallyReconciled
  | _ => UnknownDomainTransactionStatus
  }
}

let getAccountTypeVariantFromString = (accountType: string): accountTypeVariant => {
  switch accountType->String.toLowerCase {
  | "credit" => Credit
  | "debit" => Debit
  | _ => UnknownAccountTypeVariant
  }
}

let getRuleAccountTypeVariantFromString = (ruleAccountType: string): ruleAccountTypeVariant => {
  switch ruleAccountType->String.toLowerCase {
  | "source" => Source
  | "target" => Target
  | _ => UnknownRuleAccountType
  }
}

let accountItemToObjMapper = dict => {
  {
    account_name: dict->getString("account_name", ""),
    account_id: dict->getString("account_id", ""),
    account_type: dict->getString("account_type", "")->getAccountTypeVariantFromString,
    profile_id: dict->getString("profile_id", ""),
    currency: dict->getDictfromDict("initial_balance")->getString("currency", ""),
    initial_balance: dict
    ->getDictfromDict("initial_balance")
    ->getAmountPayload,
    matched_debits: dict
    ->getDictfromDict("matched_debits")
    ->getAmountPayload,
    matched_credits: dict
    ->getDictfromDict("matched_credits")
    ->getAmountPayload,
    posted_debits: dict
    ->getDictfromDict("posted_debits")
    ->getAmountPayload,
    posted_credits: dict
    ->getDictfromDict("posted_credits")
    ->getAmountPayload,
    pending_debits: dict
    ->getDictfromDict("pending_debits")
    ->getAmountPayload,
    pending_credits: dict
    ->getDictfromDict("pending_credits")
    ->getAmountPayload,
    expected_debits: dict
    ->getDictfromDict("expected_debits")
    ->getAmountPayload,
    expected_credits: dict
    ->getDictfromDict("expected_credits")
    ->getAmountPayload,
    mismatched_debits: dict
    ->getDictfromDict("mismatched_debits")
    ->getAmountPayload,
    mismatched_credits: dict
    ->getDictfromDict("mismatched_credits")
    ->getAmountPayload,
    created_at: dict->getString("created_at", ""),
  }
}

let accountRefItemToObjMapper = dict => {
  {
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
  }
}

let ruleAccountRefItemToObjMapper = dict => {
  {
    id: dict->getString("id", ""),
    account_id: dict->getString("account_id", ""),
  }
}

let reconRuleRefItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
  }
}

let reconRuleItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
    sources: dict
    ->getArrayFromDict("sources", [])
    ->Array.map(item => item->getDictFromJsonObject->ruleAccountRefItemToObjMapper),
    targets: dict
    ->getArrayFromDict("targets", [])
    ->Array.map(item => item->getDictFromJsonObject->ruleAccountRefItemToObjMapper),
  }
}

let ingestionHistoryItemToObjMapper = (dict): ingestionHistoryType => {
  {
    id: dict->getString("id", ""),
    ingestion_id: dict->getString("ingestion_id", ""),
    ingestion_history_id: dict->getString("ingestion_history_id", ""),
    file_name: dict->getString("file_name", "N/A"),
    account_id: dict->getString("account_id", ""),
    status: dict->getString("status", "")->ingestionAndTransformationStatusTypeFromString,
    upload_type: dict->getString("upload_type", ""),
    created_at: dict->getString("created_at", ""),
    ingestion_name: dict->getString("ingestion_name", ""),
    version: dict->getInt("version", 0),
    discarded_at: dict->getString("discarded_at", ""),
    discarded_status: dict->getString("discarded_status", ""),
  }
}

let transformationDataMapper = (dict): transformationData => {
  {
    total_count: dict->getInt("total_count", 0),
    transformed_count: dict->getInt("transformed_count", 0),
    transformation_result: dict->getString("transformation_result", ""),
    ignored_count: dict->getInt("ignored_count", 0),
    staging_entry_ids: dict->getStrArrayFromDict("staging_entry_ids", []),
    errors: dict->getStrArrayFromDict("errors", []),
  }
}

let transformationHistoryItemToObjMapper = (dict): transformationHistoryType => {
  {
    transformation_history_id: dict->getString("transformation_history_id", ""),
    transformation_id: dict->getString("transformation_id", ""),
    account_id: dict->getString("account_id", ""),
    ingestion_history_id: dict->getString("ingestion_history_id", ""),
    transformation_name: dict->getString("transformation_name", ""),
    status: dict->getString("status", "")->ingestionAndTransformationStatusTypeFromString,
    data: dict
    ->getJsonObjectFromDict("data")
    ->getDictFromJsonObject
    ->transformationDataMapper,
    processed_at: dict->getString("processed_at", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let ingestionConfigItemToObjMapper = (dict): ingestionConfigType => {
  {
    ingestion_id: dict->getString("ingestion_id", ""),
    account_id: dict->getString("account_id", ""),
    is_active: dict->getBool("is_active", false),
    name: dict->getString("name", ""),
    last_synced_at: dict->getString("last_synced_at", ""),
    data: dict->getJsonObjectFromDict("data"),
    created_at: dict->getString("created_at", ""),
  }
}

let sheetSelectionMapper = (dict): sheetSelection => {
  switch dict->getString("sheet_selection_type", "") {
  | "by_index" => ByIndex(dict->getInt("value", 0))
  | "by_name" => ByName(dict->getString("value", ""))
  | _ => UnknownSheetSelection
  }
}

let parsingConfigMapper = (dict): parsingConfig => {
  switch dict->getString("file_format", "") {
  | "csv" => CsvParsingConfig
  | "xlsx" =>
    XlsxParsingConfig({
      headerRowIndex: dict->getInt("header_row_index", 0),
      sheetSelection: dict->getDictfromDict("sheet_selection")->sheetSelectionMapper,
    })
  | "fixed_width" => FixedWidthParsingConfig
  | _ => UnknownParsingConfig
  }
}

let transformationConfigItemToObjMapper = (dict): transformationConfigType => {
  {
    transformation_id: dict->getString("transformation_id", ""),
    profile_id: dict->getString("profile_id", ""),
    ingestion_id: dict->getString("ingestion_id", ""),
    account_id: dict->getString("account_id", ""),
    name: dict->getString("name", ""),
    config: dict->getJsonObjectFromDict("config"),
    is_active: dict->getBool("is_active", false),
    created_at: dict->getString("created_at", ""),
    metadata_schema_id: dict->getString("metadata_schema_id", ""),
    last_transformed_at: dict->getString("last_transformed_at", ""),
    last_modified_at: dict->getString("last_modified_at", ""),
  }
}

let getEntryTypeVariantFromString = (entryType: string): entryDirectionType => {
  switch entryType->String.toLowerCase {
  | "debit" => Debit
  | "credit" => Credit
  | _ => UnknownEntryDirectionType
  }
}

let transactionsEntryItemToObjMapper = dict => {
  {
    entry_id: dict->getString("entry_id", ""),
    entry_type: dict->getString("entry_type", "")->getEntryTypeVariantFromString,
    account: dict
    ->getDictfromDict("account")
    ->accountItemToObjMapper,
    amount: dict->getDictfromDict("amount")->getAmountPayload,
    status: dict->getString("status", "NA")->getEntryStatusVariantFromString,
    order_id: dict->getString("order_id", ""),
  }
}

let getArrayOfTransactionsEntriesListPayloadType = json => {
  json->Array.map(entriesJson => {
    entriesJson->getDictFromJsonObject->transactionsEntryItemToObjMapper
  })
}

let linkedTransactionItemToObjMapper = dict => {
  {
    transaction_id: dict->getString("transaction_id", ""),
    created_at: dict->getString("created_at", ""),
    transaction_status: dict->getString("status", "")->getDomainTransactionStatus(dict),
  }
}

let transactionItemToObjMapper = (dict): transactionType => {
  let linkedTransactionDict = dict->getDictfromDict("linked_transaction")
  {
    id: dict->getString("id", ""),
    transaction_id: dict->getString("transaction_id", ""),
    profile_id: dict->getString("profile_id", ""),
    entries: dict
    ->getArrayFromDict("entries", [])
    ->getArrayOfTransactionsEntriesListPayloadType,
    credit_amount: dict->getDictfromDict("credit_amount")->getAmountPayload,
    debit_amount: dict->getDictfromDict("debit_amount")->getAmountPayload,
    rule: dict->getDictfromDict("rule")->reconRuleRefItemToObjMapper,
    transaction_status: dict
    ->getString("status", "")
    ->getDomainTransactionStatus(dict),
    data: {
      status: dict
      ->getDictfromDict("data")
      ->getString("status", "")
      ->getTransactionStatusVariantFromString,
      matched_data_type: switch dict
      ->getDictfromDict("data")
      ->getOptionString("matched_data_type") {
      | Some(matchedDataType) => Some(matchedDataType->getMatchedDataTypeVariantFromString)
      | None => None
      },
      reason: dict
      ->getDictfromDict("data")
      ->getOptionString("reason"),
    },
    discarded_status: dict
    ->getDictfromDict("discarded_status")
    ->getOptionString("status")
    ->Option.map(status =>
      status->getDomainTransactionStatus(dict->getDictfromDict("discarded_status"))
    ),
    version: dict->getInt("version", 0),
    created_at: dict->getString("created_at", ""),
    effective_at: dict->getString("effective_at", ""),
    linked_transaction: linkedTransactionDict->isEmptyDict
      ? None
      : Some(linkedTransactionDict->linkedTransactionItemToObjMapper),
  }
}

let entryItemToObjMapper = dict => {
  {
    entry_id: dict->getString("entry_id", ""),
    entry_type: dict->getString("entry_type", "")->getEntryTypeVariantFromString,
    transaction_id: dict->getString("transaction_id", ""),
    account_id: dict->getString("account_id", ""),
    account_name: dict->getDictfromDict("account")->getString("account_name", "N/A"),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", "N/A"),
    order_id: dict->getString("order_id", ""),
    status: dict->getString("status", "")->getEntryStatusVariantFromString,
    discarded_status: dict->getOptionString("discarded_status"),
    version: dict->getInt("version", 0),
    metadata: dict->getJsonObjectFromDict("metadata"),
    data: dict->getJsonObjectFromDict("data"),
    created_at: dict->getString("created_at", ""),
    effective_at: dict->getString("effective_at", ""),
    staging_entry_id: dict->getOptionString("staging_entry_id"),
    transformation_id: dict->getOptionString("transformation_id"),
  }
}

let processingEntryDataItemToObjMapper = (dataDict): processingEntryDataType => {
  {
    status: dataDict->getString("status", "")->getProcessingEntryStatusVariantFromString,
    needs_manual_review_type: dataDict
    ->getString("needs_manual_review_type", "")
    ->getNeedsManualReviewTypeVariantFromString,
  }
}

let processingEntryDiscardedDataItemToObjMapper = (dataDict): processingEntryDiscardedDataType => {
  {
    reason: dataDict->getString("reason", ""),
    status: dataDict->getString("status", "")->getProcessingEntryStatusVariantFromString,
  }
}

let processingItemToObjMapper = (dict): processingEntryType => {
  let discardedDataDict =
    dict->getDictfromDict("discarded_data")->processingEntryDiscardedDataItemToObjMapper
  {
    id: dict->getString("id", ""),
    staging_entry_id: dict->getString("staging_entry_id", ""),
    account: dict
    ->getDictfromDict("account")
    ->accountRefItemToObjMapper,
    entry_type: dict->getString("entry_type", ""),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", ""),
    status: dict->getString("status", "")->getProcessingEntryStatusVariantFromString,
    effective_at: dict->getString("effective_at", ""),
    processing_mode: dict->getString("processing_mode", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
    transformation_id: dict->getString("transformation_id", ""),
    transformation_history_id: dict->getString("transformation_history_id", ""),
    order_id: dict->getString("order_id", ""),
    version: dict->getInt("version", 0),
    discarded_status: dict->getOptionString("discarded_status"),
    data: dict->getDictfromDict("data")->processingEntryDataItemToObjMapper,
    discarded_data: discardedDataDict.status != UnknownProcessingEntryStatus
      ? Some(discardedDataDict)
      : None,
  }
}

let stringValidationRuleMapper = (dict): stringValidationRule => {
  let ruleType = dict->getString("validation_rule_type", "")
  switch ruleType {
  | "max_length" => MaxLength(dict->getInt("value", 0))
  | "min_length" => MinLength(dict->getInt("value", 0))
  | _ => UnknownStringValidationRule
  }
}

let numberValidationRuleMapper = (dict): numberValidationRule => {
  let ruleType = dict->getString("validation_rule_type", "")
  switch ruleType {
  | "min_value" => MinValue(dict->getFloat("value", 0.0))
  | "max_value" => MaxValue(dict->getFloat("value", 0.0))
  | _ => UnknownNumberValidationRule
  }
}

let minorUnitValidationRuleMapper = (dict): minorUnitValidationRule => {
  let ruleType = dict->getString("validation_rule_type", "")
  switch ruleType {
  | "positive_only" => PositiveOnly
  | "min_value" => MinValueMinorUnit(dict->getInt("value", 0))
  | "max_value" => MaxValueMinorUnit(dict->getInt("value", 0))
  | _ => UnknownMinorUnitValidationRule
  }
}

let majorUnitValidationRuleMapper = (dict): majorUnitValidationRule => {
  switch dict->getString("validation_rule_type", "") {
  | "positive_only" => PositiveOnlyMajorUnit
  | "min_value" => MinValueMajorUnit(dict->getFloat("value", 0.0))
  | "max_value" => MaxValueMajorUnit(dict->getFloat("value", 0.0))
  | _ => UnknownMajorUnitValidationRule
  }
}

let replaceModeMapper = (dict): replaceMode => {
  switch dict->getString("mode_type", "") {
  | "all" => ReplaceAll
  | "single" =>
    ReplaceSingle({
      occurrence: dict->getInt("occurrence", 0),
      fromEnd: dict->getBool("from_end", false),
    })
  | _ => UnknownReplaceMode
  }
}

let amountDelimiterMapper = (str): amountDelimiter => {
  switch str {
  | "dot" => DelimiterDot
  | "comma" => DelimiterComma
  | _ => UnknownAmountDelimiter
  }
}

let stringTransformationRuleMapper = (dict): stringTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "default_value" => StrDefaultValue(dict->getString("value", ""))
  | "to_upper_case" => StrToUpperCase
  | "to_lower_case" => StrToLowerCase
  | "strip_prefix" => StrStripPrefix(dict->getString("prefix", ""))
  | "strip_suffix" => StrStripSuffix(dict->getString("suffix", ""))
  | "trim" => StrTrim
  | "json_extract" => StrJsonExtract(dict->getString("pointer", ""))
  | "regex" =>
    StrRegex({pattern: dict->getString("pattern", ""), group: dict->getOptionInt("group")})
  | _ => UnknownStringTransformationRule
  }
}

let currencyTransformationRuleMapper = (dict): currencyTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "default_value" => CurrencyDefaultValue(dict->getString("currency", ""))
  | "trim" => CurrencyTrim
  | "json_extract" => CurrencyJsonExtract(dict->getString("pointer", ""))
  | _ => UnknownCurrencyTransformationRule
  }
}

let balanceDirectionTransformationRuleMapper = (dict): balanceDirectionTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "default_value" => BalanceDirectionDefaultValue(dict->getString("direction", ""))
  | "trim" => BalanceDirectionTrim
  | "json_extract" => BalanceDirectionJsonExtract(dict->getString("pointer", ""))
  | "starts_with" =>
    BalanceDirectionStartsWith({
      prefix: dict->getString("prefix", ""),
      thenValue: dict->getString("then", ""),
      otherwise: dict->getString("otherwise", ""),
    })
  | _ => UnknownBalanceDirectionTransformationRule
  }
}

let numberTransformationRuleMapper = (dict): numberTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "trim" => NumberTrim
  | "json_extract" => NumberJsonExtract(dict->getString("pointer", ""))
  | _ => UnknownNumberTransformationRule
  }
}

let minorUnitTransformationRuleMapper = (dict): minorUnitTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "trim" => MinorUnitTrim
  | "json_extract" => MinorUnitJsonExtract(dict->getString("pointer", ""))
  | "absolute" => MinorUnitAbsolute
  | _ => UnknownMinorUnitTransformationRule
  }
}

let majorUnitTransformationRuleMapper = (dict): majorUnitTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "trim" => MajorUnitTrim
  | "json_extract" => MajorUnitJsonExtract(dict->getString("pointer", ""))
  | "negate" => MajorUnitNegate
  | "absolute" => MajorUnitAbsolute
  | "replace_char" =>
    MajorUnitReplaceChar({
      fromChar: dict->getString("from", ""),
      toChar: dict->getOptionString("to"),
      mode: dict->getDictfromDict("mode")->replaceModeMapper,
    })
  | _ => UnknownMajorUnitTransformationRule
  }
}

let dateTimeTransformationRuleMapper = (dict): dateTimeTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "trim" => DateTimeTrim
  | "json_extract" => DateTimeJsonExtract(dict->getString("pointer", ""))
  | _ => UnknownDateTimeTransformationRule
  }
}

let enumTransformationRuleMapper = (dict): enumTransformationRule => {
  switch dict->getString("transformation_rule_type", "") {
  | "trim" => EnumTrim
  | "json_extract" => EnumJsonExtract(dict->getString("pointer", ""))
  | _ => UnknownEnumTransformationRule
  }
}

let durationUnitMapper = (str): durationUnit => {
  switch str {
  | "minutes" => Minutes
  | "hours" => Hours
  | "days" => Days
  | _ => UnknownDurationUnit
  }
}

let dateTimeDurationMapper = (dict): dateTimeDuration => {
  {
    value: dict->getInt("value", 0),
    unit: dict->getString("unit", "")->durationUnitMapper,
  }
}

let truncationPrecisionMapper = (str): truncationPrecision => {
  switch str {
  | "start_of_hour" => StartOfHour
  | "start_of_day" => StartOfDay
  | "start_of_month" => StartOfMonth
  | "start_of_year" => StartOfYear
  | _ => UnknownTruncationPrecision
  }
}

let dateTimePostParseRuleMapper = (dict): dateTimePostParseRule => {
  switch dict->getString("post_parse_rule_type", "") {
  | "truncate" => PostParseTruncate(dict->getString("precision", "")->truncationPrecisionMapper)
  | "add_duration" =>
    PostParseAddDuration(dict->getDictfromDict("duration")->dateTimeDurationMapper)
  | "subtract_duration" =>
    PostParseSubtractDuration(dict->getDictfromDict("duration")->dateTimeDurationMapper)
  | _ => UnknownDateTimePostParseRule
  }
}

let getTransformationRulesArray = (dict, key, mapper) =>
  dict->getArrayFromDict(key, [])->Array.map(item => item->getDictFromJsonObject->mapper)

let stringMappingsFromDict = dict =>
  dict
  ->Dict.toArray
  ->Array.map(((key, value)) => (key, value->getStringFromJson("")))
  ->Dict.fromArray

let fieldRulesForMainField = (dict, fieldName): fieldRules => {
  switch fieldName {
  | "currency" =>
    CurrencyRules({
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        currencyTransformationRuleMapper,
      ),
    })
  | "amount" =>
    switch dict->getString("unit_type", "") {
    | "major_unit" =>
      MajorUnitRules({
        delimiter: dict->getString("delimiter", "")->amountDelimiterMapper,
        validation: dict->getTransformationRulesArray(
          "validation_rules",
          majorUnitValidationRuleMapper,
        ),
        transformation: dict->getTransformationRulesArray(
          "transformation_rules",
          majorUnitTransformationRuleMapper,
        ),
      })
    | _ =>
      MinorUnitRules({
        validation: dict->getTransformationRulesArray(
          "validation_rules",
          minorUnitValidationRuleMapper,
        ),
        transformation: dict->getTransformationRulesArray(
          "transformation_rules",
          minorUnitTransformationRuleMapper,
        ),
      })
    }
  | "effective_at" =>
    DateTimeRules({
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        dateTimeTransformationRuleMapper,
      ),
      postParse: dict->getTransformationRulesArray(
        "post_parse_transformations",
        dateTimePostParseRuleMapper,
      ),
    })
  | "balance_direction" =>
    BalanceDirectionRules({
      creditValues: dict->getStrArrayFromDict("credit_values", []),
      debitValues: dict->getStrArrayFromDict("debit_values", []),
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        balanceDirectionTransformationRuleMapper,
      ),
    })
  | "order_id" =>
    StringRules({
      validation: [],
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        stringTransformationRuleMapper,
      ),
    })
  | _ => UnknownFieldRules
  }
}

let fieldRulesForMetadataField = (dict): fieldRules => {
  switch dict->getString("field_type", "") {
  | "string" =>
    StringRules({
      validation: dict->getTransformationRulesArray("validation_rules", stringValidationRuleMapper),
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        stringTransformationRuleMapper,
      ),
    })
  | "number" =>
    NumberRules({
      validation: dict->getTransformationRulesArray("validation_rules", numberValidationRuleMapper),
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        numberTransformationRuleMapper,
      ),
    })
  | "currency" =>
    CurrencyRules({
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        currencyTransformationRuleMapper,
      ),
    })
  | "minor_unit" =>
    MinorUnitRules({
      validation: dict->getTransformationRulesArray(
        "validation_rules",
        minorUnitValidationRuleMapper,
      ),
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        minorUnitTransformationRuleMapper,
      ),
    })
  | "major_unit" =>
    MajorUnitRules({
      delimiter: dict->getString("delimiter", "")->amountDelimiterMapper,
      validation: dict->getTransformationRulesArray(
        "validation_rules",
        majorUnitValidationRuleMapper,
      ),
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        majorUnitTransformationRuleMapper,
      ),
    })
  | "date_time" =>
    DateTimeRules({
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        dateTimeTransformationRuleMapper,
      ),
      postParse: dict->getTransformationRulesArray(
        "post_parse_transformations",
        dateTimePostParseRuleMapper,
      ),
    })
  | "balance_direction" =>
    BalanceDirectionRules({
      creditValues: dict->getStrArrayFromDict("credit_values", []),
      debitValues: dict->getStrArrayFromDict("debit_values", []),
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        balanceDirectionTransformationRuleMapper,
      ),
    })
  | "enum" =>
    EnumRules({
      mappings: dict->getDictfromDict("mappings")->stringMappingsFromDict,
      transformation: dict->getTransformationRulesArray(
        "transformation_rules",
        enumTransformationRuleMapper,
      ),
    })
  | _ => UnknownFieldRules
  }
}

let fieldTypeMapper = (dict): fieldTypeVariant => {
  let fieldType = dict->getString("field_type", "")
  switch fieldType {
  | "string" => {
      let validationRules =
        dict
        ->getArrayFromDict("validation_rules", [])
        ->Array.map(item => item->getDictFromJsonObject->stringValidationRuleMapper)
      StringField(validationRules)
    }
  | "number" => {
      let validationRules =
        dict
        ->getArrayFromDict("validation_rules", [])
        ->Array.map(item => item->getDictFromJsonObject->numberValidationRuleMapper)
      NumberField(validationRules)
    }
  | "currency" => CurrencyField
  | "minor_unit" => {
      let validationRules =
        dict
        ->getArrayFromDict("validation_rules", [])
        ->Array.map(item => item->getDictFromJsonObject->minorUnitValidationRuleMapper)
      MinorUnitField(validationRules)
    }
  | "date_time" => DateTimeField
  | "balance_direction" =>
    BalanceDirectionField({
      credit_values: dict->getStrArrayFromDict("credit_values", []),
      debit_values: dict->getStrArrayFromDict("debit_values", []),
    })
  | _ => UnknownFieldType
  }
}

let entryFieldFromString = (str: string): entryField => {
  let metadataPrefix = "metadata."
  if str->String.startsWith(metadataPrefix) {
    let key = str->String.slice(~start=metadataPrefix->String.length, ~end=str->String.length)
    Metadata(key)
  } else {
    String
  }
}

let metadataFieldItemToObjMapper = (dict): metadataFieldType => {
  {
    identifier: dict->getString("identifier", ""),
    field_name: dict->getString("field_name", "")->entryFieldFromString,
    field_type: dict->fieldTypeMapper,
    required: dict->getBool("required", false),
    description: dict->getString("description", ""),
    rules: dict->fieldRulesForMetadataField,
  }
}

let mainFieldItemToObjMapper = (dict): mainFieldType => {
  {
    field_name: dict->getString("field_name", ""),
    identifier: dict->getString("identifier", ""),
    credit_values: dict->getArrayFromDict("credit_values", [])->Array.length > 0
      ? Some(dict->getStrArrayFromDict("credit_values", []))
      : None,
    debit_values: dict->getArrayFromDict("debit_values", [])->Array.length > 0
      ? Some(dict->getStrArrayFromDict("debit_values", []))
      : None,
    rules: dict->fieldRulesForMainField(dict->getString("field_name", "")),
  }
}

let uniqueConstraintTypeItemToObjMapper = (dict): uniqueConstraintTypeVariant => {
  let constraintType = dict->getString("unique_constraint_type", "")
  switch constraintType {
  | "single_field" => SingleField(dict->getString("field_name", ""))
  | _ => UnknownConstraint
  }
}

let uniqueConstraintItemToObjMapper = (dict): uniqueConstraintType => {
  {
    unique_constraint_type: dict
    ->getDictfromDict("constraint_type")
    ->uniqueConstraintTypeItemToObjMapper,
    description: dict->getString("description", ""),
  }
}

let schemaFieldsItemToObjMapper = (dict): schemaFieldsType => {
  {
    main_fields: dict
    ->getArrayFromDict("main_fields", [])
    ->Array.map(item => item->getDictFromJsonObject->mainFieldItemToObjMapper),
    metadata_fields: dict
    ->getArrayFromDict("metadata_fields", [])
    ->Array.map(item => item->getDictFromJsonObject->metadataFieldItemToObjMapper),
  }
}

let schemaDataItemToObjMapper = (dict): schemaDataType => {
  {
    schema_type: dict->getString("schema_type", ""),
    fields: dict->getDictfromDict("fields")->schemaFieldsItemToObjMapper,
    unique_constraint: dict
    ->getDictfromDict("unique_constraint")
    ->uniqueConstraintItemToObjMapper,
    processing_mode: dict->getString("processing_mode", ""),
  }
}

let metadataSchemaItemToObjMapper = (dict): metadataSchemaType => {
  {
    id: dict->getString("id", ""),
    schema_id: dict->getString("schema_id", ""),
    profile_id: dict->getString("profile_id", ""),
    account_id: dict->getString("account_id", ""),
    schema_data: dict->getDictfromDict("schema_data")->schemaDataItemToObjMapper,
    version: dict->getInt("version", 0),
    created_at: dict->getString("created_at", ""),
    last_modified_at: dict->getString("last_modified_at", ""),
  }
}

let overviewTransactionStatusTypeFromString = (status: string): domainTransactionStatus => {
  switch status->String.toLowerCase {
  | "expected" => Expected
  | "posted_manual" => Posted(Manual)
  | "under_amount_mismatch" => UnderAmount(Mismatch)
  | "under_amount_expected" => UnderAmount(Expected)
  | "over_amount_mismatch" => OverAmount(Mismatch)
  | "over_amount_expected" => OverAmount(Expected)
  | "data_mismatch" => DataMismatch
  | "currency_mismatch" => CurrencyMismatch
  | "split_mismatch" => SplitMismatch
  | "archived" => Archived
  | "void" => Void
  | "partially_reconciled" => PartiallyReconciled
  | "missing" => Missing
  | "matched_auto" => Matched(Auto)
  | "matched_manual" => Matched(Manual)
  | "matched_force" => Matched(Force)
  | "matched_with_tolerance" => Matched(WithTolerance)
  | _ => UnknownDomainTransactionStatus
  }
}

let overviewRuleStatusBreakdownMapper: Dict.t<JSON.t> => overviewRuleStatusBreakdown = dict => {
  {
    status: dict->getString("status", "")->overviewTransactionStatusTypeFromString,
    count: dict->getInt("count", 0),
    credit_amount: dict->getDictfromDict("credit_amount")->getAmountPayload,
    debit_amount: dict->getDictfromDict("debit_amount")->getAmountPayload,
  }
}

let overviewRulesStatusBreakdownArrayMapper = statusBreakdownArr =>
  statusBreakdownArr->Array.map(status =>
    status->getDictFromJsonObject->overviewRuleStatusBreakdownMapper
  )

let overviewRulesResponseMapper: Dict.t<JSON.t> => overviewRulesResponse = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    status_breakdown: dict
    ->getArrayFromDict("status_breakdown", [])
    ->overviewRulesStatusBreakdownArrayMapper,
  }
}

let overviewRulesTimeRangeMapper: Dict.t<JSON.t> => overviewRulesTimeRange = dict => {
  {
    start_time: dict->getString("start_time", ""),
    end_time: dict->getString("end_time", ""),
  }
}

let overviewRulesTimeSeriesMapper: Dict.t<JSON.t> => overviewRulesTimeSeries = dict => {
  {
    time_range: dict->getDictfromDict("time_range")->overviewRulesTimeRangeMapper,
    status_breakdown: dict
    ->getArrayFromDict("status_breakdown", [])
    ->overviewRulesStatusBreakdownArrayMapper,
  }
}

let overviewRulesTimeSeriesResponseMapper: Dict.t<
  JSON.t,
> => overviewRulesTimeSeriesResponse = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    time_series: dict
    ->getArrayFromDict("time_series", [])
    ->Array.map(timeSeries => timeSeries->getDictFromJsonObject->overviewRulesTimeSeriesMapper),
  }
}

let stagingEntryOverviewStatusAmountMapper: Dict.t<
  JSON.t,
> => stagingEntryOverviewStatusAmount = dict => {
  {
    status: dict->getString("status", "")->getProcessingEntryStatusVariantFromString,
    count: dict->getInt("count", 0),
  }
}

let accountStagingEntriesOverviewMapper: Dict.t<JSON.t> => accountStagingEntriesOverview = dict => {
  {
    status_breakdown: dict
    ->getArrayFromDict("status_breakdown", [])
    ->Array.map(status => status->getDictFromJsonObject->stagingEntryOverviewStatusAmountMapper),
  }
}

let accountStatusBreakdownMapper: Dict.t<JSON.t> => accountStatusBreakdown = dict => {
  {
    status: dict->getString("status", "")->overviewTransactionStatusTypeFromString,
    credit_txn_count: dict->getInt("credit_count", 0),
    debit_txn_count: dict->getInt("debit_count", 0),
    credit_amount: dict->getDictfromDict("credit_amount")->getAmountPayload,
    debit_amount: dict->getDictfromDict("debit_amount")->getAmountPayload,
  }
}

let accountStatusOverviewMapper: Dict.t<JSON.t> => accountStatusOverview = dict => {
  {
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
    account_type: dict->getString("account_type", "")->getAccountTypeVariantFromString,
    rule_account_type: dict
    ->getString("rule_account_type", "")
    ->getRuleAccountTypeVariantFromString,
    status_breakdown: dict
    ->getArrayFromDict("status_breakdown", [])
    ->Array.map(status => status->getDictFromJsonObject->accountStatusBreakdownMapper),
  }
}

let ruleAccountsOverviewMapper: Dict.t<JSON.t> => ruleAccountsOverview = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    accounts: dict
    ->getArrayFromDict("accounts", [])
    ->Array.map(account => account->getDictFromJsonObject->accountStatusOverviewMapper),
  }
}
