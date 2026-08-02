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

let getConnectedPmts = (paymentMethodsEnabled: ConnectorTypes.payment_methods_enabled) =>
  paymentMethodsEnabled->Array.flatMap(pmEnabled =>
    pmEnabled.payment_method_types->Array.map(pmt => pmt.payment_method_type)
  )

let getItemLabel = (~scopeType, item) =>
  switch scopeType {
  | EventType => item->snakeToTitle
  | PaymentMethodType | NotSpecific => item->ConnectorUtils.getPaymentMethodDisplayName
  }

let getSelectedItems = items =>
  items->Array.filter(item => item.isSelected && item.status != Registered)

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
