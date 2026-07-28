type scopeType =
  | @as("payment_method_types") PaymentMethodType
  | @as("event_types") EventType
  | @as("not_specific") NotSpecific

type registerConfig = {
  label: string,
  webhook_auto_configuration_supported: bool,
  scope_type: scopeType,
  payment_method_types: array<string>,
  event_types: array<string>,
}

type registerStatus =
  | Succeeded
  | Failed

type registerError = {
  code: string,
  message: string,
}

type registerResult = {
  identifier: string,
  status: registerStatus,
  connector_webhook_id: option<string>,
  error: option<registerError>,
}

type registerResponse = {
  scope_type: scopeType,
  requested: array<string>,
  results: array<registerResult>,
}

type webhookItemStatus =
  | Unselected
  | Selected
  | Registered
  | RegisterFailed(string)

type webhookItem = {
  identifier: string,
  status: webhookItemStatus,
}
