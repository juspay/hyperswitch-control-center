type colType =
  | Id
  | Status
  | OrderAmount
  | Connector
  | Created
  | PaymentMethodType
  | ModifiedAt
  | RecoveryProgress
  | CardAttached

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
  net_amount: float,
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
  card_attached: int,
}

type optionObj = {
  urlKey: string,
  label: string,
}

type topic =
  | String(string)
  | ReactElement(React.element)

type attemptGroup = {
  amount: float,
  attempts: array<attempts>,
  isSuccessful: bool,
  isPartial: bool,
}

type recoveryInvoiceStatus =
  | Recovered
  | Scheduled
  | Terminated
  | Processing
  | Queued
  | NoPicked
  | Monitoring
  | PartiallyRecovered
  | PartiallyCapturedAndProcessing
  | Other(string)

type recoverySchedulerStatusType =
  | Finish
  | Scheduled

type attemptTriggeredByType =
  | INTERNAL
  | EXTERNAL

type recoveryFilterTypes = {
  connector: array<string>,
  currency: array<string>,
  payment_method: array<string>,
  payment_method_type: array<string>,
  connector_label: array<string>,
  card_network: array<string>,
  customer_id: array<string>,
  amount: array<string>,
  merchant_order_reference_id: array<string>,
}

type recoveryFilter = [
  | #connector
  | #payment_method
  | #currency
  | #payment_method_type
  | #connector_label
  | #card_network
  | #customer_id
  | #amount
  | #merchant_order_reference_id
  | #unknown
]
