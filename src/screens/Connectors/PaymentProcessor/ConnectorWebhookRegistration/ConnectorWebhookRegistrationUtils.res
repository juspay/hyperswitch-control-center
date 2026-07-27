open LogicUtils
open ConnectorWebhookRegisterationTypes

let scopeTypeFromString = str =>
  switch str {
  | "payment_method_type" => PaymentMethodType
  | "event_type" => EventType
  | _ => NotSpecific
  }

let registerStatusFromString = str =>
  switch str->String.toLowerCase {
  | "success" => Succeeded
  | _ => Failed
  }

let scopeTypeToRequestType = scopeType =>
  switch scopeType {
  | PaymentMethodType => "payment_method_types"
  | EventType => "event_types"
  | NotSpecific => "not_specific"
  }

let makeRegisterConfig = (dict): registerConfig => {
  label: dict->getString("label", ""),
  webhook_auto_configuration_supported: dict->getBool(
    "webhook_auto_configuration_supported",
    false,
  ),
  scope_type: dict->getString("scope_type", "")->scopeTypeFromString,
  payment_method_types: dict->getStrArrayFromDict("payment_method_types", []),
  event_types: dict->getStrArrayFromDict("event_types", []),
}

let makeRegisterError = (dict): registerError => {
  code: dict->getString("code", ""),
  message: dict->getString("message", ""),
}

let makeRegisterResult = (dict): registerResult => {
  identifier: dict->getString("identifier", ""),
  status: dict->getString("status", "")->registerStatusFromString,
  connector_webhook_id: dict->getOptionString("connector_webhook_id"),
  error: {
    let errorDict = dict->getDictfromDict("error")
    errorDict->isEmptyDict ? None : Some(errorDict->makeRegisterError)
  },
}

let makeRegisterResponse = (dict): registerResponse => {
  scope_type: dict->getString("scope_type", "")->scopeTypeFromString,
  requested: dict->getStrArrayFromDict("requested", []),
  results: dict
  ->getArrayFromDict("results", [])
  ->Array.map(result => result->getDictFromJsonObject->makeRegisterResult),
}
