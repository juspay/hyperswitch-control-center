type scopeType =
  | @as("payment_method_types") PaymentMethodType
  | @as("event_types") EventType
  | @as("not_specific") NotSpecific

type resultStatus =
  | Succeeded
  | Failed

type webhookItemStatus =
  | Unselected
  | Selected
  | Success
  | Failed(array<string>)

type webhookItem = {
  identifier: string,
  status: webhookItemStatus,
}
