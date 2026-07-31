open LogicUtils
open ConnectorWebhookRegistrationTypes

let scopeTypeFromString = str =>
  switch str {
  | "payment_method_type" => PaymentMethodType
  | "event_type" => EventType
  | _ => NotSpecific
  }

let resultStatusFromString = str =>
  switch str->String.toLowerCase {
  | "success" => Succeeded
  | _ => Failed
  }

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

let getItemLabel = (~scopeType, item) =>
  switch scopeType {
  | EventType => item->snakeToTitle
  | PaymentMethodType | NotSpecific => item->ConnectorUtils.getPaymentMethodDisplayName
  }

let getSelectedItems = items =>
  items->Array.filter(item =>
    switch item.status {
    | Selected => true
    | _ => false
    }
  )

let makeRequestBody = (~scopeType, ~selectedIdentifiers) => {
  let scope = switch scopeType {
  | NotSpecific => [("type", (NotSpecific :> string)->JSON.Encode.string)]
  | PaymentMethodType | EventType => [
      ("type", (scopeType :> string)->JSON.Encode.string),
      ("values", selectedIdentifiers->Array.map(JSON.Encode.string)->JSON.Encode.array),
    ]
  }
  [("scope", scope->getJsonFromArrayOfJson)]->getJsonFromArrayOfJson
}
