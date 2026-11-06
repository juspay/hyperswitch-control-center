type colType =
  | Id
  | Status
  | OrderAmount
  | Connector
  | Created
  | PaymentMethodType
  | ModifiedAt
  | RecoveryProgress
  | MerchantReferenceId

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
  profile_id: string,
  merchant_reference_id: string,
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
  billing_connector_id: string,
  total_retry_count: int,
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
  | Succeeded
  | Cancelled
  | Scheduled
  | Terminated
  | Processing
  | Queued
  | Monitoring
  | PartiallyRecovered
  | PartiallyCapturedAndProcessing
  | Other(string)

type recoveryFilterKey = [
  | #merchant_connector_id
  | #payment_method_type
  | #payment_method_subtype
]

type paymentMethodFilterKey = [#payment_method_type | #payment_method_subtype]

type recoverySchedulerStatusType =
  | Finish
  | Scheduled

type attemptTriggeredByType =
  | INTERNAL
  | EXTERNAL
