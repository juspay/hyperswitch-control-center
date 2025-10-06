type colType =
  | InvoiceId
  | PaymentId
  | MerchantId
  | Status
  | Amount
  | AmountCapturable
  | AmountReceived
  | ProfileId
  | Connector
  | ConnectorTransactionID
  | Created
  | Currency
  | CustomerId
  | Description
  | SetupFutureUsage
  | CaptureMethod
  | PaymentMethod
  | PaymentMethodType
  | PaymentMethodData
  | PaymentToken
  | Shipping
  | Email
  | Name
  | Phone
  | ReturnUrl
  | AuthenticationType
  | StatementDescriptorName
  | StatementDescriptorSuffix
  | NextAction
  | CancellationReason
  | ErrorCode
  | ErrorMessage
  | Metadata
  | MerchantOrderReferenceId
  | AttemptCount

type refundMetaData = {
  udf1: string,
  new_customer: string,
  login_date: string,
}

type refunds = {
  refund_id: string,
  payment_id: string,
  amount: float,
  currency: string,
  reason: string,
  status: string,
  metadata: refundMetaData,
  updated_at: string,
  created_at: string,
  error_message: string,
}

type attempts = {
  id: string,
  status: string,
  amount: float,
  currency: string,
  connector: string,
  error_message: string,
  payment_method: string,
  connector_reference_id: string,
  capture_method: string,
  authentication_type: string,
  cancellation_reason: string,
  mandate_id: string,
  error_code: string,
  payment_token: string,
  connector_metadata: string,
  payment_experience: string,
  payment_method_type: string,
  reference_id: string,
  client_source: string,
  client_version: string,
  attempt_amount: float,
}

type frmMessage = {
  frm_name: string,
  frm_transaction_id: string,
  frm_transaction_type: string,
  frm_status: string,
  frm_score: int,
  frm_reason: string,
  frm_error: string,
}

type order = {
  invoice_id: string,
  payment_id: string,
  merchant_id: string,
  net_amount: float,
  order_amount: float,
  status: string,
  amount: float,
  amount_capturable: float,
  amount_received: float,
  created: string,
  last_updated: string,
  currency: string,
  customer_id: string,
  description: string,
  setup_future_usage: string,
  capture_method: string,
  payment_method: string,
  payment_method_type: string,
  payment_method_data: option<JSON.t>,
  external_authentication_details: option<JSON.t>,
  payment_token: string,
  shipping: string,
  shippingEmail: string,
  shippingPhone: string,
  metadata: Dict.t<JSON.t>,
  email: string,
  name: string,
  phone: string,
  return_url: string,
  authentication_type: string,
  statement_descriptor_name: string,
  statement_descriptor_suffix: string,
  next_action: string,
  cancellation_reason: string,
  error_code: string,
  error_message: string,
  connector: string,
  order_quantity: string,
  product_name: string,
  card_brand: string,
  payment_experience: string,
  frm_message: frmMessage,
  connector_transaction_id: string,
  merchant_connector_id: string,
  merchant_decision: string,
  profile_id: string,
  disputes: array<DisputeTypes.disputes>,
  attempts: array<attempts>,
  merchant_order_reference_id: string,
  attempt_count: int,
  connector_label: string,
  attempt_amount: float,
}

type refundsColType =
  | Amount
  | Created
  | Currency
  | LastUpdated
  | PaymentId
  | RefundId
  | RefundReason
  | RefundStatus
  | ErrorMessage

type frmColType =
  | PaymentId
  | PaymentMethodType
  | Amount
  | Currency
  | PaymentProcessor
  | FRMConnector
  | FRMMessage
  | MerchantDecision

type authenticationColType =
  | AuthenticationFlow
  | DsTransactionId
  | ElectronicCommerceIndicator
  | ErrorCode
  | ErrorMessage
  | Status
  | Version

type attemptColType =
  | AttemptId
  | Status
  | Amount
  | Connector
  | PaymentMethodType
  | ErrorMessage
  | ConnectorReferenceID
  | CaptureMethod
  | AuthenticationType
  | CancellationReason
  | MandateID
  | ErrorCode
  | PaymentToken
  | ConnectorMetadata
  | PaymentExperience
  | ClientSource
  | ClientVersion

type summaryColType =
  | Created
  | NetAmount
  | OrderAmount
  | LastUpdated
  | PaymentId
  | Currency
  | AmountReceived
  | OrderQuantity
  | ProductName
  | ErrorMessage
  | ConnectorTransactionID

type aboutPaymentColType =
  | Connector
  | ProfileId
  | ProfileName
  | PaymentMethod
  | PaymentMethodType
  | CardBrand
  | ConnectorLabel
  | AuthenticationType
  | CaptureMethod
  | CardNetwork
  | MandateId
  | AmountCapturable
  | AmountReceived

type otherDetailsColType =
  | AmountCapturable
  | ErrorCode
  | ShippingAddress
  | ShippingEmail
  | ShippingPhone
  | Email
  | FirstName
  | LastName
  | Phone
  | CustomerId
  | Description
  | MerchantId
  | ReturnUrl
  | CaptureMethod
  | NextAction
  | SetupFutureUsage
  | CancellationReason
  | StatementDescriptorName
  | StatementDescriptorSuffix
  | PaymentExperience
  | FRMName
  | FRMTransactionType
  | FRMStatus
  | MerchantOrderReferenceId

type optionObj = {
  urlKey: string,
  label: string,
}

type frmStatus = [#APPROVE | #REJECT]
type topic =
  | String(string)
  | ReactElement(React.element)

type schedulerStatusType =
  | Finish
  | Scheduled
