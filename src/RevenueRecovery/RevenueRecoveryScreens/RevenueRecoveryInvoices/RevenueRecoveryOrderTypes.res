type colType =
  | Id
  | Status
  | OrderAmount
  | Connector
  | Created
  | PaymentMethodType
  | ModifiedAt
  | RecoveryProgress

type attemptColType =
  | Id
  | Status
  | Error
  | AttemptTriggeredBy
  | Created
  | CardNetwork
  | DeclineCode
  | ErrorMessage

type attempts = {
  id: string,
  status: string,
  error: string,
  attempt_triggered_by: string,
  created: string,
  card_network: string,
  last4: string,
  network_decline_code: string,
  network_error_message: string,
}

type order = {
  id: string,
  status: string,
  order_amount: float,
  amount_captured: float,
  connector: string,
  created: string,
  payment_method_type: string,
  payment_method_subtype: string,
  attempts: array<attempts>,
  modified_at: string,
}

type optionObj = {
  urlKey: string,
  label: string,
}

type topic =
  | String(string)
  | ReactElement(React.element)

type status =
  | Succeeded
  | Scheduled
  | Failed
  | Cancelled
  | Processing
  | RequiresCustomerAction
  | RequiresPaymentMethod
  | RequiresConfirmation
  | PartiallyCaptured
  | None

type recoveryStatusType =
  | Finish
  | Scheduled
