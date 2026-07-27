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

let notSpecificId = "not_specific"

let getConnectedPmts = initialValues =>
  initialValues
  ->getDictFromJsonObject
  ->getArrayFromDict("payment_methods_enabled", [])
  ->Array.flatMap(pmEnabled =>
    pmEnabled
    ->getDictFromJsonObject
    ->getArrayFromDict("payment_method_types", [])
    ->Array.map(pmt => pmt->getDictFromJsonObject->getString("payment_method_type", ""))
  )

let getDisplayItems = (~registerConfig: registerConfig, ~connectedPmts) =>
  switch registerConfig.scope_type {
  | PaymentMethodType =>
    registerConfig.payment_method_types->Array.filter(pmt => connectedPmts->Array.includes(pmt))
  | EventType => registerConfig.event_types
  | NotSpecific => []
  }

let getItemLabel = (~scopeType, item) =>
  switch scopeType {
  | EventType => item->snakeToTitle
  | PaymentMethodType | NotSpecific => item->ConnectorUtils.getPaymentMethodDisplayName
  }

let isItemRegistered = status =>
  switch status {
  | Registered => true
  | _ => false
  }

let isItemSelected = status =>
  switch status {
  | Registered | Selected => true
  | _ => false
  }

let getSelectedItems = items =>
  items->Array.filter(item =>
    switch item.status {
    | Selected => true
    | _ => false
    }
  )

let getRegisteredValues = webhooks =>
  webhooks->Array.filterMap(webhook => {
    let scope = webhook->getDictFromJsonObject->getDictfromDict("scope")
    let scopeType = scope->getString("type", "")
    let value = scope->getString("value", "")

    switch (scopeType, value->isNonEmptyString) {
    | ("not_specific", _) => Some(notSpecificId)
    | (_, true) => Some(value)
    | (_, false) => None
    }
  })

let makeRegisterBody = (~scopeType, ~selectedIdentifiers) => {
  let scope = switch scopeType {
  | NotSpecific => [("type", NotSpecific->scopeTypeToRequestType->JSON.Encode.string)]
  | PaymentMethodType | EventType => [
      ("type", scopeType->scopeTypeToRequestType->JSON.Encode.string),
      ("values", selectedIdentifiers->Array.map(JSON.Encode.string)->JSON.Encode.array),
    ]
  }
  [("scope", scope->getJsonFromArrayOfJson)]->getJsonFromArrayOfJson
}

let makeStatusByIdentifier = (~results: array<registerResult>, ~scopeType) => {
  let statusById = Dict.make()
  results->Array.forEach(result => {
    let status = switch result.status {
    | Succeeded => Registered
    | Failed =>
      RegisterFailed(
        result.error->mapOptionOrDefault("Registration failed", error => error.message),
      )
    }
    let identifier = switch scopeType {
    | NotSpecific => notSpecificId
    | PaymentMethodType | EventType => result.identifier
    }
    statusById->Dict.set(identifier, status)
  })
  statusById
}

let getFailedIdentifiers = (results: array<registerResult>) =>
  results->Array.filterMap(result =>
    switch result.status {
    | Failed => Some(result.identifier)
    | Succeeded => None
    }
  )
