open ReconEngineTypes
open LogicUtils

let getTransactionStatusVariantFromString = (status: string): transactionStatus => {
  switch status {
  | "posted" => Posted
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | "void" => Void
  | "partially_reconciled" => PartiallyReconciled
  | _ => Expected
  }
}

let getTransactionPostedTypeVariantFromString = (postedType: string): transactionPostedType => {
  switch postedType->String.toLowerCase {
  | "reconciled" => Reconciled
  | "force_reconciled" => ForceReconciled
  | "manually_reconciled" => ManuallyReconciled
  | _ => UnknownTransactionPostedType
  }
}

let getEntryStatusVariantFromString = (entryType: string): entryStatus => {
  switch entryType->String.toLowerCase {
  | "posted" => Posted
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | "pending" => Pending
  | "void" => Void
  | _ => UnknownEntryStatus
  }
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
  | "auto" => Auto
  | "manual" => Manual
  | "force" => Force
  | _ => UnknownDomainTransactionPostedStatus
  }
}

let getDomainTransactionAmountMismatchStatusFromString = (
  status: string,
): domainTransactionAmountMismatchStatus => {
  switch status->String.toLowerCase {
  | "expected" => Expected
  | "mismatch" => Mismatch
  | _ => Mismatch
  }
}

let getDomainTransactionStatus = (
  status: string,
  dict: Js.Dict.t<Js.Json.t>,
): domainTransactionStatus => {
  let subStatus = dict->getString("sub_status", "")
  switch status->String.toLowerCase {
  | "expected" => Expected
  | "posted" => Posted(subStatus->getDomainTransactionPostedStatusFromString)
  | "over_amount" => OverAmount(subStatus->getDomainTransactionAmountMismatchStatusFromString)
  | "under_amount" => UnderAmount(subStatus->getDomainTransactionAmountMismatchStatusFromString)
  | "data_mismatch" => DataMismatch
  | "archived" => Archived
  | "void" => Void
  | "partially_reconciled" => PartiallyReconciled
  | _ => UnknownDomainTransactionStatus
  }
}

let accountItemToObjMapper = dict => {
  {
    account_name: dict->getString("account_name", ""),
    account_id: dict->getString("account_id", ""),
    account_type: dict->getString("account_type", ""),
    profile_id: dict->getString("profile_id", ""),
    currency: dict->getDictfromDict("initial_balance")->getString("currency", ""),
    initial_balance: dict
    ->getDictfromDict("initial_balance")
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

let transactionItemToObjMapper = (dict): transactionType => {
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
      posted_type: switch dict
      ->getDictfromDict("data")
      ->getOptionString("posted_type") {
      | Some(postedType) => Some(postedType->getTransactionPostedTypeVariantFromString)
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
  | _ => MinLength(0)
  }
}

let numberValidationRuleMapper = (dict): numberValidationRule => {
  let ruleType = dict->getString("validation_rule_type", "")
  switch ruleType {
  | "min_value" => MinValue(dict->getFloat("value", 0.0))
  | "max_value" => MaxValue(dict->getFloat("value", 0.0))
  | _ => MinValue(0.0)
  }
}

let minorUnitValidationRuleMapper = (dict): minorUnitValidationRule => {
  let ruleType = dict->getString("validation_rule_type", "")
  switch ruleType {
  | "positive_only" => PositiveOnly
  | "min_value" => MinValueMinorUnit(dict->getInt("value", 0))
  | "max_value" => MaxValueMinorUnit(dict->getInt("value", 0))
  | _ => PositiveOnly
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
  | _ => StringField([])
  }
}

let metadataFieldItemToObjMapper = (dict): metadataFieldType => {
  {
    identifier: dict->getString("identifier", ""),
    field_name: dict->getString("field_name", ""),
    field_type: dict->fieldTypeMapper,
    required: dict->getBool("required", false),
    description: dict->getString("description", ""),
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
