open ReconEngineTypes
open LogicUtils

let getTransactionStatusVariantFromString = (status: string): transactionStatus => {
  switch status {
  | "posted" => Posted
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | _ => UnknownTransactionStatus
  }
}

let getEntryStatusVariantFromString = (entryType: string): entryStatus => {
  switch entryType {
  | "posted" => Posted
  | "mismatched" => Mismatched
  | "expected" => Expected
  | "archived" => Archived
  | "pending" => Pending
  | _ => UnknownEntryStatus
  }
}

let getProcessingEntryStatusVariantFromString = (status: string): processingEntryStatus => {
  switch status->String.toLowerCase {
  | "pending" => Pending
  | "processed" => Processed
  | "archived" => Archived
  | "needs_manual_review" => NeedsManualReview
  | _ => UnknownProcessingEntryStatus
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
  }
}

let transformationConfigItemToObjMapper = (dict): transformationConfigType => {
  {
    id: dict->getString("id", ""),
    profile_id: dict->getString("profile_id", ""),
    ingestion_id: dict->getString("ingestion_id", ""),
    account_id: dict->getString("account_id", ""),
    name: dict->getString("name", ""),
    config: dict->getJsonObjectFromDict("config"),
    is_active: dict->getBool("is_active", false),
    created_at: dict->getString("created_at", ""),
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
    ->getString("transaction_status", "")
    ->getTransactionStatusVariantFromString,
    discarded_status: dict->getOptionString("discarded_status"),
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
    account_name: dict->getDictfromDict("account")->getString("account_name", ""),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", ""),
    status: dict->getString("status", "")->getEntryStatusVariantFromString,
    discarded_status: dict->getOptionString("discarded_status"),
    metadata: dict->getJsonObjectFromDict("metadata"),
    created_at: dict->getString("created_at", ""),
    effective_at: dict->getString("effective_at", ""),
  }
}

let processingItemToObjMapper = (dict): processingEntryType => {
  {
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
  }
}
