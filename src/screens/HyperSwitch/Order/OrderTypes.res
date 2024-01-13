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
  attempt_id: string,
  status: string,
  amount: float,
  currency: string,
  connector: string,
  error_message: string,
  payment_method: string,
  connector_transaction_id: string,
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
  payment_id: string,
  merchant_id: string,
  net_amount: float,
  status: string,
  amount: float,
  amount_capturable: float,
  amount_received: float,
  client_secret: string,
  created: string,
  last_updated: string,
  currency: string,
  customer_id: string,
  description: string,
  refunds: array<refunds>,
  mandate_id: string,
  mandate_data: string,
  setup_future_usage: string,
  off_session: string,
  capture_on: string,
  capture_method: string,
  payment_method: string,
  payment_method_type: string,
  payment_method_data: string,
  payment_token: string,
  shipping: string,
  billing: string,
  metadata: Js.Dict.t<Js.Json.t>,
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

type attemptColType =
  | AttemptId
  | Status
  | Amount
  | Currency
  | Connector
  | PaymentMethod
  | PaymentMethodType
  | ErrorMessage
  | ConnectorTransactionID
  | CaptureMethod
  | AuthenticationType
  | CancellationReason
  | MandateID
  | ErrorCode
  | PaymentToken
  | ConnectorMetadata
  | PaymentExperience
  | ReferenceID

type colType =
  | PaymentId
  | MerchantId
  | Status
  | Amount
  | AmountCapturable
  | AmountReceived
  | ProfileId
  | Connector
  | ConnectorTransactionID
  | ClientSecret
  | Created
  | Currency
  | CustomerId
  | CustomerEmail
  | Description
  | Refunds
  | MandateId
  | MandateData
  | SetupFutureUsage
  | OffSession
  | CaptureOn
  | CaptureMethod
  | PaymentMethod
  | PaymentMethodType
  | PaymentMethodData
  | PaymentToken
  | Shipping
  | Billing
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

type summaryColType =
  | Created
  | NetAmount
  | LastUpdated
  | PaymentId
  | Currency
  | AmountReceived
  | ClientSecret
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
  | Refunds
  | AuthenticationType
  | CaptureMethod

type otherDetailsColType =
  | MandateData
  | AmountCapturable
  | ErrorCode
  | Shipping
  | Billing
  | Email
  | FirstName
  | LastName
  | Phone
  | CustomerId
  | Description
  | MerchantId
  | ReturnUrl
  | OffSession
  | CaptureOn
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

type optionObj = {
  urlKey: string,
  label: string,
}

type frmStatus = [#APPROVE | #REJECT]
