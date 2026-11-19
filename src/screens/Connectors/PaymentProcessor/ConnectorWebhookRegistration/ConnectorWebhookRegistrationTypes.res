type scopeType =
  | @as("payment_method_types") PaymentMethodType
  | @as("event_types") EventType
  | @as("not_specific") NotSpecific

type resultStatus =
  | Succeeded
  | Failed

type webhookItemStatus =
  | NotAttempted
  | Registered
  | Failed(array<string>)

type webhookItem = {
  identifier: string,
  isSelected: bool,
  status: webhookItemStatus,
}
