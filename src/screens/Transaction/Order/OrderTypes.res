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

@unboxed
type paymentListSource =
  | @as("Postgres") Postgres
  | @as("OpenSearch") OpenSearch

let getPaymentListSourceLabel = (source: paymentListSource) => (source :> string)

let getPaymentListTableTitle = source =>
  switch source {
  | Postgres => "Orders"
  | OpenSearch => "OrdersOpenSearch"
  }

let getPaymentListSourceDisplayName = source =>
  switch source {
  | Postgres => "Normal"
  | OpenSearch => "Advanced"
  }

let getPaymentListSourceDescription = source =>
  switch source {
  | Postgres => "Standard payments list."
  | OpenSearch => "Advanced payment list with expanded search, filters, columns, and CSV export."
  }

type openSearchRefundStatus = [#partial_refunded | #full_refunded]

let openSearchRefundStatuses: array<openSearchRefundStatus> = [#partial_refunded, #full_refunded]

let openSearchRefundStatusValues = openSearchRefundStatuses->Array.map(status => (status :> string))

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

let openSearchDisputeStatuses: array<openSearchDisputeStatus> = [
  #dispute_present,
  #dispute_opened,
  #dispute_challenged,
  #dispute_lost,
  #dispute_won,
  #dispute_accepted,
  #dispute_cancelled,
  #dispute_expired,
]

let openSearchDisputeStatusValues =
  openSearchDisputeStatuses->Array.map(status => (status :> string))

type frmStatus = [#APPROVE | #REJECT]

let getSortString = (value: LoadedTable.sortOb) =>
  switch value.sortType {
  | ASC => "asc"
  | DSC => "desc"
  }
