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
