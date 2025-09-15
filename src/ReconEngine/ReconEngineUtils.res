open ReconEngineTypes
open LogicUtils

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
    id: dict->getString("id", ""),
    account_id: dict->getString("account_id", ""),
  }
}

let reconRuleItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
    sources: dict
    ->getArrayFromDict("sources", [])
    ->Array.map(item => item->getDictFromJsonObject->accountRefItemToObjMapper),
    targets: dict
    ->getArrayFromDict("targets", [])
    ->Array.map(item => item->getDictFromJsonObject->accountRefItemToObjMapper),
  }
}

let ingestionHistoryItemToObjMapper = (dict): ingestionHistoryType => {
  {
    id: dict->getString("id", ""),
    ingestion_id: dict->getString("ingestion_id", ""),
    ingestion_history_id: dict->getString("ingestion_history_id", ""),
    file_name: dict->getString("file_name", "N/A"),
    account_id: dict->getString("account_id", ""),
    status: dict->getString("status", ""),
    upload_type: dict->getString("upload_type", ""),
    created_at: dict->getString("created_at", ""),
    ingestion_name: dict->getString("ingestion_name", ""),
    version: dict->getInt("version", 0),
    discarded_at: dict->getString("discarded_at", ""),
    discarded_at_status: dict->getString("discarded_at_status", ""),
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
    status: dict->getString("status", ""),
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
