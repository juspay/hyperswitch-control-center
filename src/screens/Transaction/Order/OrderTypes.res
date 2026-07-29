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
  | ChallengeCancelCode
  | ElectronicCommerceIndicator
  | ErrorCode
  | ErrorMessage
  | Status
  | TransStatusReason
  | Version

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
  | ClientSource
  | ClientVersion
  | HyperswitchErrorDescription

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
  | Modified
  | Currency
  | CustomerId
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
  | Metadata
  | CardNetwork
  | MerchantOrderReferenceId
  | AttemptCount
  | PaymentType
  | MerchantConnectorId
  | ActiveAttemptId
  | CardLast4
  | CardIssuer
  | RefundsStatus
  | RefundsCount
  | Activities
  | RoutingApproach
  | UnifiedCode
  | UnifiedMessage

type summaryColType =
  | Created
  | NetAmount
  | SurchargeAmount
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
  | CardNetwork

type otherDetailsColType =
  | MandateData
  | AmountCapturable
  | ErrorCode
  | ShippingAddress
  | ShippingEmail
  | ShippingPhone
  | BillingAddress
  | BillingEmail
  | BillingPhone
  | PMBillingAddress
  | PMBillingPhone
  | PMBillingEmail
  | PMBillingFirstName
  | PMBillingLastName
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
  | MerchantOrderReferenceId
  | ExtendedAuthLastAppliedAt
  | ExtendedAuthApplied
  | RequestExtendedAuth
  | HyperswitchErrorDescription

type optionObj = {
  urlKey: string,
  label: string,
}

type filterTypes = {
  connector: array<string>,
  currency: array<string>,
  authentication_type: array<string>,
  payment_method: array<string>,
  payment_method_type: array<string>,
  status: array<string>,
  connector_label: array<string>,
  card_network: array<string>,
  card_discovery: array<string>,
  customer_id: array<string>,
  amount: array<string>,
  merchant_order_reference_id: array<string>,
  customer_email: array<string>,
  card_last_4: array<string>,
  active_attempt_id: array<string>,
  merchant_connector_id: array<string>,
  refunds_status: array<string>,
  dispute_status: array<string>,
  routing_approach: array<string>,
  card_issuer: array<string>,
}

type filter = [
  | #connector
  | #payment_method
  | #currency
  | #authentication_type
  | #status
  | #payment_method_type
  | #connector_label
  | #card_network
  | #card_discovery
  | #customer_id
  | #amount
  | #merchant_order_reference_id
  | #customer_email
  | #card_last_4
  | #active_attempt_id
  | #merchant_connector_id
  | #refunds_status
  | #dispute_status
  | #routing_approach
  | #card_issuer
  | #unknown
]

@unboxed
type paymentListSource =
  | @as("Normal") Normal
  | @as("Advanced") Advanced

type openSearchCsvColumn =
  | CsvPaymentId
  | CsvStatus
  | CsvAmount
  | CsvCurrency
  | CsvConnector
  | CsvPaymentMethod
  | CsvPaymentMethodType
  | CsvProfileId
  | CsvMerchantId
  | CsvCustomerId
  | CsvActiveAttemptId
  | CsvMerchantConnectorId
  | CsvCardLast4
  | CsvCardNetwork
  | CsvCardIssuer
  | CsvRefundsStatus
  | CsvRefundsCount
  | CsvDisputeStatus
  | CsvDisputeCount
  | CsvRoutingApproach
  | CsvUnifiedCode
  | CsvUnifiedMessage
  | CsvCreated
  | CsvModified

type openSearchRefundStatus = [#partial_refunded | #full_refunded]

type openSearchDisputeStatus = [
  | #dispute_present
  | #dispute_opened
  | #dispute_challenged
  | #dispute_lost
  | #dispute_won
  | #dispute_accepted
  | #dispute_cancelled
  | #dispute_expired
]

type unsupportedAdvancedPaymentFilter = [#unified_code | #unified_message]

type hiddenAdvancedPaymentFilter = [#first_attempt]

type advancedPaymentTextListFilter = [
  | #card_last_4
  | #active_attempt_id
  | #merchant_connector_id
  | #card_issuer
]

type advancedRoutingApproach = [
  | #default_fallback
  | #straight_through_routing
  | #rule_based_routing
  | #volume_based_routing
]

type basePaymentListFilter = [
  | #payment_id
  | #payment_method
  | #currency
  | #status
  | #connector
  | #connector_label
  | #payment_method_type
  | #card_network
  | #customer_id
  | #authentication_type
  | #card_discovery
  | #merchant_order_reference_id
]

type frmStatus = [#APPROVE | #REJECT]

let getSortString = (value: LoadedTable.sortOb) =>
  switch value.sortType {
  | ASC => "asc"
  | DSC => "desc"
  }
