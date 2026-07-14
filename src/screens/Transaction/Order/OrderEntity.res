open PaymentInterfaceTypes
open LogicUtils
open OrderTypes

type activityTag = {label: string}

module CurrencyCell = {
  @react.component
  let make = (~amount, ~currency) => {
    <p className="whitespace-nowrap"> {`${amount} ${currency}`->React.string} </p>
  }
}

let getRefundCell = (refunds: refunds, refundsColType: refundsColType): Table.cell => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(refunds.currency)
  switch refundsColType {
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(refunds.amount /. conversionFactor)->Float.toString} currency={refunds.currency}
      />,
      "",
    )
  | RefundId => Text(refunds.refund_id)
  | RefundReason => Text(refunds.reason)
  | Currency => Text(refunds.currency)
  | RefundStatus =>
    Label({
      title: refunds.status->String.toUpperCase,
      color: switch refunds.status->HSwitchOrderUtils.statusVariantMapper {
      | Succeeded
      | PartiallyCaptured =>
        LabelGreen
      | Failed => LabelRed
      | Processing => LabelOrange
      | Cancelled => LabelRed
      | RequiresCustomerAction
      | RequiresPaymentMethod =>
        LabelBlue
      | _ => LabelLightGray
      },
    })
  | PaymentId => Text(refunds.payment_id)
  | ErrorMessage => Text(refunds.error_message)
  | LastUpdated => Date(refunds.updated_at)
  | Created => Date(refunds.created_at)
  }
}

let getAttemptCell = (attempt: attempts, attemptColType: attemptColType): Table.cell => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(attempt.currency)
  switch attemptColType {
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(attempt.amount /. conversionFactor)->Float.toString} currency={attempt.currency}
      />,
      "",
    )
  | Currency => Text(attempt.currency)
  | Connector =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=attempt.connector
        connectorType={ConnectorUtils.connectorTypeFromConnectorName(attempt.connector)}
      />,
      "",
    )
  | Status =>
    Label({
      title: attempt.status->String.toUpperCase,
      color: switch attempt.status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
      | #CHARGED => LabelGreen
      | #AUTHENTICATION_FAILED
      | #ROUTER_DECLINED
      | #AUTHORIZATION_FAILED
      | #VOIDED
      | #CAPTURE_FAILED
      | #VOID_FAILED
      | #FAILURE =>
        LabelRed
      | _ => LabelLightGray
      },
    })
  | PaymentMethod => Text(attempt.payment_method)
  | PaymentMethodType => Text(attempt.payment_method_type)
  | AttemptId => DisplayCopyCell(attempt.attempt_id)
  | ErrorMessage => Text(attempt.error_message)
  | ConnectorTransactionID =>
    if attempt.connector_transaction_id->isNonEmptyString {
      DisplayCopyCell(attempt.connector_transaction_id)
    } else {
      Text("NA")
    }
  | CaptureMethod => Text(attempt.capture_method)
  | AuthenticationType => Text(attempt.authentication_type)
  | CancellationReason => Text(attempt.cancellation_reason)
  | MandateID => Text(attempt.mandate_id)
  | ErrorCode => Text(attempt.error_code)
  | PaymentToken => Text(attempt.payment_token)
  | ConnectorMetadata => Text(attempt.connector_metadata)
  | PaymentExperience => Text(attempt.payment_experience)
  | ReferenceID => Text(attempt.reference_id)
  | ClientSource => Text(attempt.client_source)
  | ClientVersion => Text(attempt.client_version)
  | HyperswitchErrorDescription => Text(attempt.hyperswitch_error_description->Option.getOr(""))
  }
}

let getFrmCell = (orderDetails: order, frmColType: frmColType): Table.cell => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(orderDetails.currency)
  switch frmColType {
  | PaymentId => Text(orderDetails.payment_id)
  | PaymentMethodType => Text(orderDetails.payment_method_type)
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(orderDetails.amount /. conversionFactor)->Float.toString}
        currency={orderDetails.currency}
      />,
      "",
    )
  | Currency => Text(orderDetails.currency)
  | PaymentProcessor => Text(orderDetails.connector)
  | FRMConnector => Text(orderDetails.frm_message.frm_name)
  | FRMMessage => Text(orderDetails.frm_message.frm_reason)
  | MerchantDecision => Text(orderDetails.frm_merchant_decision)
  }
}

let getAuthenticationCell = (orderDetails: order, colType: authenticationColType): Table.cell => {
  let authenticationDetails =
    orderDetails.external_authentication_details
    ->Option.getOr(JSON.Encode.null)
    ->getDictFromJsonObject
  switch colType {
  | AuthenticationFlow => Text(authenticationDetails->getString("authentication_flow", ""))
  | DsTransactionId => Text(authenticationDetails->getString("ds_transaction_id", ""))
  | ElectronicCommerceIndicator =>
    Text(authenticationDetails->getString("electronic_commerce_indicator", ""))
  | ErrorCode => Text(authenticationDetails->getString("error_code", ""))
  | ErrorMessage => Text(authenticationDetails->getString("error_message", ""))
  | Status => Text(authenticationDetails->getString("status", ""))
  | Version => Text(authenticationDetails->getString("version", ""))
  }
}

let refundColumns: array<refundsColType> = [
  RefundId,
  PaymentId,
  Amount,
  RefundStatus,
  Created,
  LastUpdated,
]

let attemptsColumns: array<attemptColType> = [
  Status,
  Amount,
  Currency,
  Connector,
  PaymentMethod,
  PaymentMethodType,
]

let frmColumns: array<frmColType> = [
  PaymentId,
  PaymentMethodType,
  Amount,
  Currency,
  PaymentProcessor,
  FRMConnector,
  FRMMessage,
  MerchantDecision,
]

let authenticationColumns: array<authenticationColType> = [
  AuthenticationFlow,
  DsTransactionId,
  ElectronicCommerceIndicator,
  ErrorCode,
  ErrorMessage,
  Status,
  Version,
]

let refundDetailsFields = [
  RefundId,
  PaymentId,
  RefundStatus,
  Amount,
  Currency,
  RefundReason,
  ErrorMessage,
]

let attemptDetailsField = [
  AttemptId,
  Status,
  Amount,
  Currency,
  Connector,
  PaymentMethod,
  PaymentMethodType,
  ErrorMessage,
  ConnectorTransactionID,
  CaptureMethod,
  AuthenticationType,
  CancellationReason,
  MandateID,
  ErrorCode,
  PaymentToken,
  ConnectorMetadata,
  PaymentExperience,
  ReferenceID,
  ClientSource,
  ClientVersion,
  HyperswitchErrorDescription,
]

let getRefundHeading = (refundsColType: refundsColType) => {
  switch refundsColType {
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | LastUpdated => Table.makeHeaderInfo(~key="last_updated", ~title="Last Updated")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | RefundStatus => Table.makeHeaderInfo(~key="status", ~title="Refund Status")
  | RefundId => Table.makeHeaderInfo(~key="refund_id", ~title="Refund ID")
  | RefundReason => Table.makeHeaderInfo(~key="reason", ~title="Refund Reason")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  }
}

let getAttemptHeading = (attemptColType: attemptColType) => {
  switch attemptColType {
  | AttemptId =>
    Table.makeHeaderInfo(
      ~key="attempt_id",
      ~title="Attempt ID",
      ~description="You can validate the information shown here by cross checking the payment attempt identifier (Attempt ID) in your payment processor portal.",
    )
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(~key="connector_transaction_id", ~title="Connector Transaction ID")
  | CaptureMethod => Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method")
  | AuthenticationType =>
    Table.makeHeaderInfo(~key="authentication_type", ~title="Authentication Type")
  | CancellationReason =>
    Table.makeHeaderInfo(~key="cancellation_reason", ~title="Cancellation Reason")
  | MandateID => Table.makeHeaderInfo(~key="mandate_id", ~title="Mandate ID")
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | PaymentToken => Table.makeHeaderInfo(~key="payment_token", ~title="Payment Token")
  | ConnectorMetadata =>
    Table.makeHeaderInfo(~key="connector_metadata", ~title="Connector Metadata")
  | PaymentExperience =>
    Table.makeHeaderInfo(~key="payment_experience", ~title="Payment Experience")
  | ReferenceID => Table.makeHeaderInfo(~key="reference_id", ~title="Reference ID")
  | ClientSource => Table.makeHeaderInfo(~key="client_source", ~title="Client Source")
  | ClientVersion => Table.makeHeaderInfo(~key="client_version", ~title="Client Version")
  | HyperswitchErrorDescription =>
    Table.makeHeaderInfo(
      ~key="hyperswitch_error_description",
      ~title="Hyperswitch Error Description",
      ~description="This is a derived property by Hyperswitch based on the PSP and Issuer Errors(If available)",
    )
  }
}

let getFrmHeading = (frmDetailsColType: frmColType) => {
  switch frmDetailsColType {
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | PaymentProcessor => Table.makeHeaderInfo(~key="connector", ~title="Payment Processor")
  | FRMConnector => Table.makeHeaderInfo(~key="frm_connector", ~title="FRM Connector")
  | FRMMessage => Table.makeHeaderInfo(~key="frm_message", ~title="FRM Message")
  | MerchantDecision => Table.makeHeaderInfo(~key="merchant_decision", ~title="Merchant Decision")
  }
}

let getAuthenticationHeading = (authenticationDetailsColType: authenticationColType) => {
  switch authenticationDetailsColType {
  | AuthenticationFlow =>
    Table.makeHeaderInfo(~key="authentication_flow", ~title="Authentication Flow")
  | DsTransactionId => Table.makeHeaderInfo(~key="ds_transaction_id", ~title="DS Transaction ID")
  | ElectronicCommerceIndicator =>
    Table.makeHeaderInfo(
      ~key="electronic_commerce_indicator",
      ~title="Electronic Commerce Indicator",
    )
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Version => Table.makeHeaderInfo(~key="version", ~title="Version")
  }
}

let defaultColumns: array<colType> = [
  PaymentId,
  Connector,
  ProfileId,
  Amount,
  Status,
  PaymentMethod,
  PaymentMethodType,
  CardNetwork,
  ConnectorTransactionID,
  MerchantOrderReferenceId,
  Description,
  Metadata,
  Created,
  Modified,
]

let openSearchDefaultColumns: array<colType> = [
  PaymentId,
  Connector,
  ProfileId,
  Amount,
  Status,
  PaymentMethod,
  PaymentMethodType,
  CardNetwork,
  Created,
  Modified,
]

let openSearchNewColumns = [
  MerchantConnectorId,
  ActiveAttemptId,
  CardLast4,
  CardIssuer,
  RefundsStatus,
  RefundsCount,
  Activities,
  RoutingApproach,
  UnifiedCode,
  UnifiedMessage,
]

let isOpenSearchNewColumn = colType => openSearchNewColumns->Array.includes(colType)

let getOpenSearchNewColumnDescription = colType =>
  switch colType {
  | MerchantConnectorId => "Connector account used for this payment attempt."
  | ActiveAttemptId => "Current active payment attempt linked to the payment."
  | CardLast4 => "Last 4 digits of the card used for the payment."
  | CardIssuer => "Bank or institution that issued the card."
  | RefundsStatus => "Refund state derived from the payment refund lifecycle."
  | RefundsCount => "Number of refunds linked to this payment."
  | Activities => "Related refund and dispute activity for this payment."
  | RoutingApproach => "Routing strategy used to select the connector."
  | UnifiedCode => "Normalized error or status code from Hyperswitch."
  | UnifiedMessage => "Normalized message explaining the payment outcome."
  | _ => ""
  }

//Columns array for V1 Orders page
let allColumnsV1 = [
  Amount,
  AmountCapturable,
  AuthenticationType,
  ProfileId,
  CaptureMethod,
  ClientSecret,
  Connector,
  ConnectorTransactionID,
  Created,
  Modified,
  Currency,
  CustomerId,
  Description,
  MerchantId,
  PaymentId,
  PaymentMethod,
  PaymentMethodType,
  SetupFutureUsage,
  Status,
  Metadata,
  MerchantOrderReferenceId,
  AttemptCount,
  CardNetwork,
  ErrorMessage,
]

//Columns array for V2 Orders page
let allColumnsV2 = [
  Amount,
  AmountCapturable,
  AuthenticationType,
  ProfileId,
  CaptureMethod,
  ClientSecret,
  Connector,
  ConnectorTransactionID,
  Created,
  Currency,
  CustomerId,
  Description,
  MerchantId,
  PaymentId,
  PaymentMethod,
  PaymentMethodType,
  SetupFutureUsage,
  Status,
  Metadata,
  MerchantOrderReferenceId,
  AttemptCount,
  CardNetwork,
  PaymentType,
  ErrorMessage,
]

let openSearchBaseColumns: array<colType> = [
  Amount,
  AmountCapturable,
  AmountReceived,
  AuthenticationType,
  ProfileId,
  CaptureMethod,
  Connector,
  ConnectorTransactionID,
  Created,
  Modified,
  Currency,
  CustomerId,
  MerchantOrderReferenceId,
  PaymentId,
  PaymentMethod,
  PaymentMethodType,
  SetupFutureUsage,
  Status,
  AttemptCount,
  CardNetwork,
  ErrorMessage,
]

let openSearchAllColumns = openSearchBaseColumns->Array.concat(openSearchNewColumns)

let openSearchCsvColumns: array<openSearchCsvColumn> = [
  CsvPaymentId,
  CsvStatus,
  CsvAmount,
  CsvCurrency,
  CsvConnector,
  CsvPaymentMethod,
  CsvPaymentMethodType,
  CsvProfileId,
  CsvMerchantId,
  CsvCustomerId,
  CsvActiveAttemptId,
  CsvMerchantConnectorId,
  CsvCardLast4,
  CsvCardNetwork,
  CsvCardIssuer,
  CsvRefundsStatus,
  CsvRefundsCount,
  CsvDisputeStatus,
  CsvDisputeCount,
  CsvRoutingApproach,
  CsvUnifiedCode,
  CsvUnifiedMessage,
  CsvCreated,
  CsvModified,
]

let getOpenSearchCsvKey = column =>
  switch column {
  | CsvPaymentId => "payment_id"
  | CsvStatus => "status"
  | CsvAmount => "amount"
  | CsvCurrency => "currency"
  | CsvConnector => "connector"
  | CsvPaymentMethod => "payment_method"
  | CsvPaymentMethodType => "payment_method_type"
  | CsvProfileId => "profile_id"
  | CsvMerchantId => "merchant_id"
  | CsvCustomerId => "customer_id"
  | CsvActiveAttemptId => "active_attempt_id"
  | CsvMerchantConnectorId => "merchant_connector_id"
  | CsvCardLast4 => "card_last_4"
  | CsvCardNetwork => "card_network"
  | CsvCardIssuer => "card_issuer"
  | CsvRefundsStatus => "refunds_status"
  | CsvRefundsCount => "refunds_count"
  | CsvDisputeStatus => "dispute_status"
  | CsvDisputeCount => "dispute_count"
  | CsvRoutingApproach => "routing_approach"
  | CsvUnifiedCode => "unified_code"
  | CsvUnifiedMessage => "unified_message"
  | CsvCreated => "created"
  | CsvModified => "modified"
  }

let getOpenSearchCsvHeader = column =>
  switch column {
  | CsvPaymentId => "Payment ID"
  | CsvStatus => "Payment Status"
  | CsvAmount => "Amount"
  | CsvCurrency => "Currency"
  | CsvConnector => "Connector"
  | CsvPaymentMethod => "Payment Method"
  | CsvPaymentMethodType => "Payment Method Type"
  | CsvProfileId => "Profile ID"
  | CsvMerchantId => "Merchant ID"
  | CsvCustomerId => "Customer ID"
  | CsvActiveAttemptId => "Active Attempt ID"
  | CsvMerchantConnectorId => "Merchant Connector ID"
  | CsvCardLast4 => "Card Last 4"
  | CsvCardNetwork => "Card Network"
  | CsvCardIssuer => "Card Issuer"
  | CsvRefundsStatus => "Refund Status"
  | CsvRefundsCount => "Refund Count"
  | CsvDisputeStatus => "Dispute Status"
  | CsvDisputeCount => "Dispute Count"
  | CsvRoutingApproach => "Routing Approach"
  | CsvUnifiedCode => "Unified Code"
  | CsvUnifiedMessage => "Unified Message"
  | CsvCreated => "Created"
  | CsvModified => "Modified"
  }

let getOpenSearchCsvValue = (dict: Dict.t<JSON.t>, column) =>
  switch column {
  | CsvAmount => dict->getFloat("amount", 0.0)->Float.toString->JSON.Encode.string
  | CsvRefundsCount => dict->getInt("refunds_count", 0)->Int.toString->JSON.Encode.string
  | CsvDisputeCount => dict->getInt("dispute_count", 0)->Int.toString->JSON.Encode.string
  | CsvMerchantConnectorId =>
    dict
    ->getString("merchant_connector_id", dict->getString("connector_id", ""))
    ->JSON.Encode.string
  | CsvCreated => dict->getString("created_at", "")->JSON.Encode.string
  | CsvModified => dict->getString("modified_at", "")->JSON.Encode.string
  | column => dict->getString(column->getOpenSearchCsvKey, "")->JSON.Encode.string
  }

let csvHeaders =
  openSearchCsvColumns->Array.map(column => (
    column->getOpenSearchCsvKey,
    column->getOpenSearchCsvHeader,
  ))

let mapOrderDictToCsvRow = (dict: Dict.t<JSON.t>) =>
  openSearchCsvColumns
  ->Array.map(column => (column->getOpenSearchCsvKey, getOpenSearchCsvValue(dict, column)))
  ->getJsonFromArrayOfJson

let getHeading = (~devSortEnabled, colType: colType) => {
  switch colType {
  | Metadata => Table.makeHeaderInfo(~key="metadata", ~title="Metadata")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Payment Status", ~dataType=DropDown)
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=true)
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector")
  | AmountCapturable => Table.makeHeaderInfo(~key="amount_capturable", ~title="Amount Capturable")
  | AmountReceived => Table.makeHeaderInfo(~key="amount_received", ~title="Amount Received")
  | ClientSecret => Table.makeHeaderInfo(~key="client_secret", ~title="Client Secret")
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(~key="connector_transaction_id", ~title="Connector Transaction ID")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created", ~showSort=true)
  | Modified => Table.makeHeaderInfo(~key="modified", ~title="Modified", ~showSort=devSortEnabled)
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | CustomerId => Table.makeHeaderInfo(~key="customer_id", ~title="Customer ID")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")

  | MandateId => Table.makeHeaderInfo(~key="mandate_id", ~title="Mandate ID")
  | MandateData => Table.makeHeaderInfo(~key="mandate_data", ~title="Mandate Data")
  | SetupFutureUsage => Table.makeHeaderInfo(~key="setup_future_usage", ~title="Setup Future Usage")
  | OffSession => Table.makeHeaderInfo(~key="off_session", ~title="Off Session")
  | CaptureOn => Table.makeHeaderInfo(~key="capture_on", ~title="Capture On")
  | CaptureMethod => Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | PaymentMethodData =>
    Table.makeHeaderInfo(~key="payment_method_data", ~title="Payment Method Data")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | PaymentToken => Table.makeHeaderInfo(~key="payment_token", ~title="Payment Token")
  | Shipping => Table.makeHeaderInfo(~key="shipping", ~title="Shipping")
  | Billing => Table.makeHeaderInfo(~key="billing", ~title="Billing")
  | Email => Table.makeHeaderInfo(~key="email", ~title="Customer Email")
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name")
  | Phone => Table.makeHeaderInfo(~key="phone", ~title="Phone")
  | ReturnUrl => Table.makeHeaderInfo(~key="return_url", ~title="Return URL")
  | AuthenticationType =>
    Table.makeHeaderInfo(~key="authentication_type", ~title="Authentication Type")
  | StatementDescriptorName =>
    Table.makeHeaderInfo(~key="statement_descriptor_name", ~title="Statement Descriptor Name")
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(~key="statement_descriptor_suffix", ~title="Statement Descriptor Suffix")
  | NextAction => Table.makeHeaderInfo(~key="next_action", ~title="Next Action")
  | CancellationReason =>
    Table.makeHeaderInfo(~key="cancellation_reason", ~title="Cancellation Reason")
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  | Refunds => Table.makeHeaderInfo(~key="refunds", ~title="Refunds")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile ID")
  | CardNetwork => Table.makeHeaderInfo(~key="CardNetwork", ~title="Card Network")
  | MerchantOrderReferenceId =>
    Table.makeHeaderInfo(~key="merchant_order_reference_id", ~title="Merchant Order Reference ID")
  | AttemptCount =>
    Table.makeHeaderInfo(~key="attempt_count", ~title="Attempt Count", ~showSort=true)
  | PaymentType => Table.makeHeaderInfo(~key="payment_type", ~title="Payment Type")
  | MerchantConnectorId =>
    Table.makeHeaderInfo(~key="merchant_connector_id", ~title="Merchant Connector ID")
  | ActiveAttemptId => Table.makeHeaderInfo(~key="active_attempt_id", ~title="Active Attempt ID")
  | CardLast4 => Table.makeHeaderInfo(~key="card_last_4", ~title="Card Last 4")
  | CardIssuer => Table.makeHeaderInfo(~key="card_issuer", ~title="Card Issuer")
  | RefundsStatus => Table.makeHeaderInfo(~key="refunds_status", ~title="Refund Status")
  | RefundsCount => Table.makeHeaderInfo(~key="refunds_count", ~title="Refund Count")
  | Activities => Table.makeHeaderInfo(~key="activities", ~title="Related Activity")
  | RoutingApproach => Table.makeHeaderInfo(~key="routing_approach", ~title="Routing Approach")
  | UnifiedCode => Table.makeHeaderInfo(~key="unified_code", ~title="Unified Code")
  | UnifiedMessage => Table.makeHeaderInfo(~key="unified_message", ~title="Unified Message")
  }
}

let useGetStatus = (order: order) => {
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
  let orderStatusLabel = order.status->String.toUpperCase
  let fixedStatusCss = "text-sm text-white font-bold px-3 py-2 rounded-md"
  switch order.status->HSwitchOrderUtils.statusVariantMapper {
  | Succeeded
  | PartiallyCaptured =>
    <div className={`${fixedStatusCss} bg-hyperswitch_green dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Failed
  | Cancelled =>
    <div className={`${fixedStatusCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Processing
  | RequiresCustomerAction
  | RequiresConfirmation
  | RequiresPaymentMethod
  | RequiresCapture =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | CancelledPostCapture =>
    <div className={`${fixedStatusCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let formatActivityCount = (count, label) => {
  `${count->Int.toString} ${pluralize(~count, ~singular=label)}`
}

let getActivityTags = (order: order) => {
  let refundsCount = order.refunds_count->Option.getOr(order.refunds->Array.length)
  let disputeStatus = order.dispute_status->Option.getOr("")
  let fallbackDisputesCount = if order.disputes->isNonEmptyArray {
    order.disputes->Array.length
  } else if disputeStatus->isNonEmptyString {
    1
  } else {
    0
  }
  let disputesCount = order.dispute_count->Option.getOr(fallbackDisputesCount)

  let refundTags = refundsCount > 0 ? [{label: formatActivityCount(refundsCount, "REFUND")}] : []
  let disputeTags =
    disputesCount > 0 ? [{label: formatActivityCount(disputesCount, "DISPUTE")}] : []

  refundTags->Array.concat(disputeTags)
}

let getActivitiesCell = (order: order): Table.cell => {
  let activityTags = order->getActivityTags
  let activityText = activityTags->Array.map(tag => tag.label)->Array.joinWith(", ")

  CustomCell(
    <>
      <RenderIf condition={activityTags->isEmptyArray}>
        <div className="w-32 whitespace-nowrap text-nd_gray-400"> {"-"->React.string} </div>
      </RenderIf>
      <RenderIf condition={activityTags->isNonEmptyArray}>
        <ToolTip
          description=activityText
          toolTipFor={<div className="w-40 overflow-hidden">
            <div className="flex items-center gap-1 whitespace-nowrap">
              {activityTags
              ->Array.map(tag =>
                <TagBinding text=tag.label color=Primary variant=Subtle shape=Squarical size=Xs />
              )
              ->React.array}
            </div>
          </div>}
          toolTipPosition=Top
        />
      </RenderIf>
    </>,
    activityTags->isEmptyArray ? "-" : activityText,
  )
}

let formatAdvancedDisplayValue = value => value->isNonEmptyString ? value->snakeToTitle : ""

let getHeadingForSummary = summaryColType => {
  switch summaryColType {
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  | NetAmount => Table.makeHeaderInfo(~key="net_amount", ~title="Net Amount")
  | SurchargeAmount => Table.makeHeaderInfo(~key="surcharge_amount", ~title="Surcharge Amount")
  | LastUpdated => Table.makeHeaderInfo(~key="last_updated", ~title="Last Updated")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | AmountReceived =>
    Table.makeHeaderInfo(
      ~key="amount_received",
      ~title="Amount Received",
      ~description="Amount captured by the payment processor for this payment.",
    )
  | ClientSecret => Table.makeHeaderInfo(~key="client_secret", ~title="Client Secret")
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(~key="connector_transaction_id", ~title="Connector Transaction ID")
  | OrderQuantity => Table.makeHeaderInfo(~key="order_quantity", ~title="Order Quantity")
  | ProductName => Table.makeHeaderInfo(~key="product_name", ~title="Product Name")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  }
}

let getHeadingForAboutPayment = aboutPaymentColType => {
  switch aboutPaymentColType {
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Payment connector")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile ID")
  | ProfileName => Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name")
  | CardBrand => Table.makeHeaderInfo(~key="card_brand", ~title="Card Brand")
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | Refunds => Table.makeHeaderInfo(~key="refunds", ~title="Refunds")
  | AuthenticationType => Table.makeHeaderInfo(~key="authentication_type", ~title="Auth Type")

  | CaptureMethod => Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method")
  | CardNetwork => Table.makeHeaderInfo(~key="CardNetwork", ~title="Card Network")
  }
}

let getHeadingForOtherDetails = otherDetailsColType => {
  switch otherDetailsColType {
  | ReturnUrl => Table.makeHeaderInfo(~key="return_url", ~title="Return URL")
  | SetupFutureUsage => Table.makeHeaderInfo(~key="setup_future_usage", ~title="Setup Future Usage")
  | CancellationReason =>
    Table.makeHeaderInfo(~key="cancellation_reason", ~title="Cancellation Reason")
  | StatementDescriptorName =>
    Table.makeHeaderInfo(~key="statement_descriptor_name", ~title="Statement Descriptor Name")
  | CaptureMethod => Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method")
  | CaptureOn => Table.makeHeaderInfo(~key="capture_on", ~title="Capture On")
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(~key="statement_descriptor_suffix", ~title="Statement Descriptor Suffix")
  | OffSession => Table.makeHeaderInfo(~key="off_session", ~title="Off Session")
  | NextAction => Table.makeHeaderInfo(~key="next_action", ~title="Next Action")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID")
  | PaymentExperience =>
    Table.makeHeaderInfo(~key="payment_experience", ~title="Payment Experience")
  | Email => Table.makeHeaderInfo(~key="email", ~title="Customer Email")
  | FirstName => Table.makeHeaderInfo(~key="firstName", ~title="First Name")
  | LastName => Table.makeHeaderInfo(~key="lastName", ~title="Last Name")
  | Phone => Table.makeHeaderInfo(~key="phone", ~title="Customer Phone")
  | CustomerId => Table.makeHeaderInfo(~key="customer_id", ~title="Customer ID")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")
  | ShippingAddress => Table.makeHeaderInfo(~key="shipping", ~title="Address")
  | ShippingEmail => Table.makeHeaderInfo(~key="shipping", ~title="Email")
  | ShippingPhone => Table.makeHeaderInfo(~key="shipping", ~title="Phone")
  | BillingAddress => Table.makeHeaderInfo(~key="billing", ~title="Address")
  | BillingPhone => Table.makeHeaderInfo(~key="BillingPhone", ~title="Phone")
  | AmountCapturable => Table.makeHeaderInfo(~key="amount_capturable", ~title="Amount Capturable")
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | MandateData => Table.makeHeaderInfo(~key="mandate_data", ~title="Mandate Data")
  | FRMName => Table.makeHeaderInfo(~key="frm_name", ~title="Tag")
  | FRMTransactionType =>
    Table.makeHeaderInfo(~key="frm_transaction_type", ~title="Transaction Flow")
  | FRMStatus => Table.makeHeaderInfo(~key="frm_status", ~title="Message")
  | BillingEmail => Table.makeHeaderInfo(~key="billing_email", ~title="Email")
  | PMBillingAddress =>
    Table.makeHeaderInfo(~key="payment_method_billing_address", ~title="Billing Address")
  | PMBillingPhone =>
    Table.makeHeaderInfo(~key="payment_method_billing_phone", ~title="Billing Phone")
  | PMBillingEmail =>
    Table.makeHeaderInfo(~key="payment_method_billing_email", ~title="Billing Email")
  | PMBillingFirstName =>
    Table.makeHeaderInfo(~key="payment_method_firat_name", ~title="First Name")
  | PMBillingLastName => Table.makeHeaderInfo(~key="payment_method_last_name", ~title="Last Name")
  | MerchantOrderReferenceId =>
    Table.makeHeaderInfo(~key="merchant_order_reference_id", ~title="Merchant Order Reference ID")

  | ExtendedAuthLastAppliedAt =>
    Table.makeHeaderInfo(
      ~key="extended_auth_last_applied_at",
      ~title="Extended Auth Last Applied At",
    )
  | ExtendedAuthApplied =>
    Table.makeHeaderInfo(~key="extended_auth_applied", ~title="Extended Auth Applied")
  | RequestExtendedAuth =>
    Table.makeHeaderInfo(~key="request_extended_auth", ~title="Request Extended Auth")
  | HyperswitchErrorDescription =>
    Table.makeHeaderInfo(
      ~key="hyperswitch_error_description",
      ~title="Hyperswitch Error Description",
      ~description="This is a derived property by Hyperswitch based on the PSP and Issuer Errors(If available)",
    )
  }
}

let getCellForSummary = (order: order, summaryColType): Table.cell => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(order.currency)
  switch summaryColType {
  | Created => Date(order.created_at)
  | NetAmount =>
    CustomCell(
      <CurrencyCell
        amount={(order.net_amount /. conversionFactor)->Float.toString} currency={order.currency}
      />,
      "",
    )
  | SurchargeAmount =>
    switch order.surcharge_amount {
    | Some(amount) =>
      CustomCell(
        <CurrencyCell
          amount={(amount /. conversionFactor)->Float.toString} currency={order.currency}
        />,
        "",
      )
    | None => Text("N/A")
    }
  | LastUpdated => Date(order.last_updated->Option.getOr(""))
  | PaymentId => DisplayCopyCell(order.payment_id)
  | Currency => Text(order.currency)
  | AmountReceived =>
    CustomCell(
      <CurrencyCell
        amount={(order.amount_captured /. conversionFactor)->Float.toString}
        currency={order.currency}
      />,
      "",
    )
  | ClientSecret => Text(order.client_secret)
  | OrderQuantity => Text(order.order_quantity->Option.getOr(""))
  | ProductName => Text(order.product_name->Option.getOr(""))
  | ErrorMessage => Text(order.error.error_message)
  | ConnectorTransactionID =>
    if order.connector_payment_id->isNonEmptyString {
      CustomCell(
        <HelperComponents.CopyTextCustomComp
          customTextCss="w-36 truncate whitespace-nowrap"
          displayValue=Some(order.connector_payment_id)
          showTooltip=true
        />,
        order.connector_payment_id,
      )
    } else {
      Text("NA")
    }
  }
}

let getCellForAboutPayment = (
  order: order,
  aboutPaymentColType: aboutPaymentColType,
): Table.cell => {
  open HelperComponents
  switch aboutPaymentColType {
  | Connector =>
    CustomCell(
      <ConnectorCustomCell
        connectorName=order.connector
        connectorType={ConnectorUtils.connectorTypeFromConnectorName(order.connector)}
      />,
      "",
    )
  | PaymentMethod => Text(order.payment_method)
  | PaymentMethodType => Text(order.payment_method_type)
  | Refunds => Text(order.refunds->Array.length > 0 ? "Yes" : "No")
  | AuthenticationType => Text(order.authentication_type)
  | ConnectorLabel => {
      let connectorLabel = order.connector_label->Option.getOr("")
      Text(connectorLabel->isNonEmptyString ? connectorLabel : "Not Available")
    }
  | CardBrand => Text(order.card_brand->Option.getOr(""))
  | ProfileId => Text(order.profile_id)
  | ProfileName =>
    Table.CustomCell(<HelperComponents.ProfileNameComponent profile_id=order.profile_id />, "")
  | CaptureMethod => Text(order.capture_method)
  | CardNetwork => {
      let dict = switch order.payment_method_data {
      | Some(val) => val->getDictFromJsonObject
      | _ => Dict.make()
      }
      Text(dict->getString("card_network", ""))
    }
  }
}

let getCellForOtherDetails = (
  order: order,
  aboutPaymentColType: otherDetailsColType,
): Table.cell => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(order.currency)
  let splitName = order.name->Option.getOr("")->String.split(" ")
  switch aboutPaymentColType {
  | MerchantId => Text(order.merchant_id)
  | ReturnUrl => Text(order.return_url)
  | OffSession => Text(order.customer_present)
  | CaptureOn => Date(order.capture_on->Option.getOr(""))
  | CaptureMethod => Text(order.capture_method)
  | NextAction => Text(order.next_action)
  | SetupFutureUsage => Text(order.setup_future_usage)
  | CancellationReason => Text(order.cancellation_reason)
  | StatementDescriptorName => Text(order.statement_descriptor)
  | StatementDescriptorSuffix => Text(order.statement_descriptor_suffix->Option.getOr(""))
  | PaymentExperience => Text(order.payment_experience)
  | FirstName => Text(splitName->Array.get(0)->Option.getOr(""))
  | LastName => Text(splitName->Array.get(splitName->Array.length - 1)->Option.getOr(""))
  | Phone => Text(order.phone->Option.getOr(""))
  | Email => Text(order.email->Option.getOr(""))
  | CustomerId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/customers/${order.customer_id}`}
        displayValue=order.customer_id
        copyValue=Some(order.customer_id)
      />,
      "",
    )
  | Description => Text(order.description)
  | ShippingAddress => Text(order.shipping)
  | ShippingPhone => Text(order.shippingPhone)
  | ShippingEmail => Text(order.shippingEmail)
  | BillingAddress => Text(order.billing)
  | AmountCapturable => Currency(order.amount_capturable /. conversionFactor, order.currency)
  | ErrorCode => Text(order.error.error_code)
  | MandateData => Text(order.mandate_data->Option.getOr(""))
  | FRMName => Text(order.frm_message.frm_name)
  | FRMTransactionType => Text(order.frm_message.frm_transaction_type)
  | FRMStatus => Text(order.frm_message.frm_status)
  | BillingEmail => Text(order.billingEmail)
  | PMBillingAddress => Text(order.payment_method_billing_address)
  | PMBillingPhone => Text(order.payment_method_billing_email)
  | PMBillingEmail => Text(order.payment_method_billing_phone)
  | PMBillingFirstName => Text(order.payment_method_billing_first_name)
  | PMBillingLastName => Text(order.payment_method_billing_last_name)
  | BillingPhone => Text(`${order.billingPhone}`)
  | MerchantOrderReferenceId => Text(order.merchant_order_reference_id->Option.getOr(""))
  | ExtendedAuthLastAppliedAt => Date(order.extended_auth_last_applied_at->Option.getOr("N/A"))
  | ExtendedAuthApplied =>
    switch order.extended_auth_applied {
    | Some(val) => Text(val->getStringFromBool)
    | None => Text("N/A")
    }
  | RequestExtendedAuth =>
    switch order.request_extended_auth {
    | Some(val) => Text(val->getStringFromBool)
    | None => Text("N/A")
    }
  | HyperswitchErrorDescription => Text(order.hyperswitch_error_description->Option.getOr(""))
  }
}

let getAllColumns = (version: UserInfoTypes.version) =>
  switch version {
  | V1 => allColumnsV1
  | V2 => allColumnsV2
  }

let getCell = (order: order, colType: colType, merchantId, orgId): Table.cell => {
  open HelperComponents
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(order.currency)
  let orderStatus = order.status->HSwitchOrderUtils.statusVariantMapper
  switch colType {
  | Metadata =>
    CustomCell(
      <EllipsisText displayValue={order.metadata->JSON.Encode.object->JSON.stringify} />,
      "",
    )
  | PaymentId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payments/${order.payment_id}/${order.profile_id}/${merchantId}/${orgId}`}
        displayValue={order.payment_id}
        copyValue={Some(order.payment_id)}
        endValue={HSwitchOrderUtils.idCellEndValue}
      />,
      "",
    )
  | MerchantId => Text(order.merchant_id)
  | Connector =>
    CustomCell(
      <ConnectorCustomCell
        connectorName=order.connector
        connectorType={ConnectorUtils.connectorTypeFromConnectorName(order.connector)}
      />,
      "",
    )
  | Status =>
    Label({
      title: order.status->String.toUpperCase,
      color: switch orderStatus {
      | Succeeded
      | PartiallyCaptured =>
        LabelGreen
      | Failed
      | Cancelled
      | CancelledPostCapture =>
        LabelRed
      | Processing
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod
      | RequiresCapture =>
        LabelBlue
      | Review => LabelOrange
      | _ => LabelLightGray
      },
    })
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(order.amount /. conversionFactor)->Float.toString} currency={order.currency}
      />,
      "",
    )
  | AmountCapturable => Currency(order.amount_capturable /. conversionFactor, order.currency)
  | AmountReceived => Currency(order.amount_captured /. conversionFactor, order.currency)
  | ClientSecret => Text(order.client_secret)
  | Created => Date(order.created_at)
  | Modified => Date(order.modified_at)
  | Currency => Text(order.currency)
  | CustomerId => Text(order.customer_id)
  | Description =>
    CustomCell(
      <CopyTextCustomComp
        customTextCss="w-28 truncate whitespace-nowrap"
        displayValue=Some(order.description)
        showTooltip=true
      />,
      "",
    )
  | MandateId => Text(order.mandate_id->Option.getOr(""))
  | MandateData => Text(order.mandate_data->Option.getOr(""))
  | SetupFutureUsage => Text(order.setup_future_usage)
  | OffSession => Text(order.customer_present)
  | CaptureOn => Date(order.capture_on->Option.getOr(""))
  | CaptureMethod => Text(order.capture_method)
  | PaymentMethod => Text(order.payment_method)
  | PaymentMethodData => Text(order.payment_method_data->JSON.stringifyAny->Option.getOr(""))
  | PaymentMethodType => Text(order.payment_method_type)
  | PaymentToken => Text(order.payment_token)
  | Shipping => Text(order.shipping)
  | Billing => Text(order.billing)
  | Email => Text(order.email->Option.getOr(""))
  | Name => Text(order.name->Option.getOr(""))
  | Phone => Text(order.phone->Option.getOr(""))
  | ReturnUrl => Text(order.return_url)
  | AuthenticationType => Text(order.authentication_type)
  | StatementDescriptorName => Text(order.statement_descriptor)
  | StatementDescriptorSuffix => Text(order.statement_descriptor_suffix->Option.getOr(""))
  | NextAction => Text(order.next_action)
  | CancellationReason => Text(order.cancellation_reason)
  | ErrorCode => Text(order.error.error_code)
  | ErrorMessage => EllipsisText(order.error.error_message, "w-40")
  | ConnectorTransactionID =>
    if order.connector_payment_id->isNonEmptyString {
      CustomCell(
        <CopyTextCustomComp
          customTextCss="w-36 truncate whitespace-nowrap"
          displayValue=Some(order.connector_payment_id)
          showTooltip=true
        />,
        order.connector_payment_id,
      )
    } else {
      Text("NA")
    }
  | ProfileId => Text(order.profile_id)
  | Refunds =>
    Text(
      switch order.refunds->JSON.stringifyAny {
      | None => "-"
      | Some(v) => v
      },
    )
  | CardNetwork => {
      let cardNetwork = switch order.card_network {
      | Some(value) if value->LogicUtils.isNonEmptyString => Some(value)
      | _ =>
        switch order.payment_method_data {
        | Some(val) =>
          switch val->JSON.Classify.classify {
          | Object(value) => Some(value->getString("card_network", ""))
          | String(value) =>
            Some(
              value
              ->safeParse
              ->getDictFromJsonObject
              ->getStringFromNestedDict("card", "card_network", ""),
            )
          | _ => None
          }
        | _ => None
        }
      }->Option.mapOr("", val => val)

      Text(cardNetwork)
    }
  | MerchantOrderReferenceId => Text(order.merchant_order_reference_id->Option.getOr(""))
  | AttemptCount => Text(order.attempt_count->Int.toString)
  | PaymentType =>
    switch order.is_split_payment {
    | Some(true) => Text("Split")
    | Some(false) => Text("Standard")
    | None => Text("N/A")
    }
  | MerchantConnectorId =>
    CustomCell(
      <CopyTextCustomComp
        customTextCss="w-44 truncate whitespace-nowrap"
        displayValue=Some(order.connector_id)
        showTooltip=true
      />,
      "",
    )
  | ActiveAttemptId =>
    CustomCell(
      <CopyTextCustomComp
        customTextCss="w-40 truncate whitespace-nowrap"
        displayValue=Some(order.active_attempt_id->Option.getOr(""))
        showTooltip=true
      />,
      order.active_attempt_id->Option.getOr(""),
    )
  | CardLast4 => EllipsisText(order.card_last_4->Option.getOr(""), "w-20")
  | CardIssuer =>
    CustomCell(
      <CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue=Some(order.card_issuer->Option.getOr(""))
        showTooltip=true
      />,
      "",
    )
  | RefundsStatus =>
    EllipsisText(order.refunds_status->Option.getOr("")->formatAdvancedDisplayValue, "w-28")
  | RefundsCount => EllipsisText(order.refunds_count->Option.getOr(0)->Int.toString, "w-20")
  | Activities => order->getActivitiesCell
  | RoutingApproach =>
    EllipsisText(order.routing_approach->Option.getOr("")->formatAdvancedDisplayValue, "w-36")
  | UnifiedCode =>
    EllipsisText(order.unified_code->Option.getOr("")->formatAdvancedDisplayValue, "w-32")
  | UnifiedMessage => EllipsisText(order.unified_message->Option.getOr(""), "w-40")
  }
}

let getOrders: JSON.t => array<order> = json => {
  getArrayDataFromJson(json, PaymentInterfaceUtils.mapDictToPaymentPayload)
}

let orderEntity = (merchantId, orgId, ~version: UserInfoTypes.version=V1, ~devSortEnabled) =>
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getOrders,
    ~defaultColumns,
    ~allColumns=getAllColumns(version),
    ~getHeading=colType => getHeading(~devSortEnabled, colType),
    ~getCell=(order, colType) => getCell(order, colType, merchantId, orgId),
    ~dataKey="",
    ~getShowLink={
      order => {
        switch version {
        | V1 =>
          GlobalVars.appendDashboardPath(
            ~url=`/payments/${order.payment_id}/${order.profile_id}/${merchantId}/${orgId}`,
          )
        | V2 =>
          GlobalVars.appendDashboardPath(
            ~url=`v2/orchestration/payments/${order.payment_id}/${order.profile_id}/${merchantId}/${orgId}`,
          )
        }
      }
    },
  )

let openSearchOrderEntity = (merchantId, orgId, ~devSortEnabled) =>
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getOrders,
    ~defaultColumns=openSearchDefaultColumns,
    ~allColumns=openSearchAllColumns,
    ~getHeading=colType => getHeading(~devSortEnabled, colType),
    ~getCell=(order, colType) => getCell(order, colType, merchantId, orgId),
    ~dataKey="",
    ~getShowLink={
      order =>
        GlobalVars.appendDashboardPath(
          ~url=`/payments/${order.payment_id}/${order.profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
