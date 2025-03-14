open LogicUtils
open RevenueRecoveryOrderTypes

module CurrencyCell = {
  @react.component
  let make = (~amount, ~currency) => {
    <p className="whitespace-nowrap"> {`${amount} ${currency}`->React.string} </p>
  }
}
let getRefundCell = (refunds: refunds, refundsColType: refundsColType): Table.cell => {
  switch refundsColType {
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(refunds.amount /. 100.0)->Float.toString} currency={refunds.currency}
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
        LabelWhite
      | _ => LabelLightBlue
      },
    })
  | PaymentId => Text(refunds.payment_id)
  | ErrorMessage => Text(refunds.error_message)
  | LastUpdated => Text(refunds.updated_at)
  | Created => Text(refunds.created_at)
  }
}

let getAttemptCell = (attempt: attempts, attemptColType: attemptColType): Table.cell => {
  switch attemptColType {
  | AttemptedBy => Text(attempt.attempt_by->snakeToTitle)
  | Amount =>
    CustomCell(
      <CurrencyCell amount={attempt.attempt_amount->Float.toString} currency={attempt.currency} />,
      "",
    )
  | Connector =>
    CustomCell(<HelperComponents.ConnectorCustomCell connectorName=attempt.connector />, "")
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
      | _ => LabelLightBlue
      },
    })
  | PaymentMethodType => Text(attempt.payment_method_type)
  | AttemptId => DisplayCopyCell(attempt.id)
  | ErrorMessage => Text(attempt.error_message)
  | ConnectorReferenceID => DisplayCopyCell(attempt.connector_reference_id)
  | CaptureMethod => Text(attempt.capture_method)
  | AuthenticationType => Text(attempt.authentication_type)
  | CancellationReason => Text(attempt.cancellation_reason)
  | MandateID => Text(attempt.mandate_id)
  | ErrorCode => Text(attempt.error_code)
  | PaymentToken => Text(attempt.payment_token)
  | ConnectorMetadata => Text(attempt.connector_metadata)
  | PaymentExperience => Text(attempt.payment_experience)
  | ClientSource => Text(attempt.client_source)
  | ClientVersion => Text(attempt.client_version)
  }
}

let getFrmCell = (orderDetais: order, frmColType: frmColType): Table.cell => {
  switch frmColType {
  | PaymentId => Text(orderDetais.payment_id)
  | PaymentMethodType => Text(orderDetais.payment_method_type)
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(orderDetais.amount /. 100.0)->Float.toString} currency={orderDetais.currency}
      />,
      "",
    )
  | Currency => Text(orderDetais.currency)
  | PaymentProcessor => Text(orderDetais.connector)
  | FRMConnector => Text(orderDetais.frm_message.frm_name)
  | FRMMessage => Text(orderDetais.frm_message.frm_reason)
  | MerchantDecision => Text(orderDetais.merchant_decision)
  }
}

let getAuthenticationCell = (orderDetais: order, colType: authenticationColType): Table.cell => {
  let authenticationDetails =
    orderDetais.external_authentication_details
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

let refundColumns: array<refundsColType> = [Created, LastUpdated, Amount, PaymentId, RefundStatus]

let attemptsColumns: array<attemptColType> = [
  Status,
  Amount,
  AuthenticationType,
  Connector,
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
  Connector,
  PaymentMethodType,
  ErrorMessage,
  ConnectorReferenceID,
  AuthenticationType,
  CancellationReason,
  MandateID,
  ErrorCode,
  PaymentToken,
  ConnectorMetadata,
  PaymentExperience,
  ClientSource,
  ClientVersion,
]

let getRefundHeading = (refundsColType: refundsColType) => {
  switch refundsColType {
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | LastUpdated => Table.makeHeaderInfo(~key="modified_at", ~title="Last Updated")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment Id")
  | RefundStatus => Table.makeHeaderInfo(~key="status", ~title="Refund Status")
  | RefundId => Table.makeHeaderInfo(~key="refund_id", ~title="Refund ID")
  | RefundReason => Table.makeHeaderInfo(~key="reason", ~title="Refund Reason")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  }
}

let getAttemptHeading = (attemptColType: attemptColType) => {
  switch attemptColType {
  | AttemptedBy =>
    Table.makeHeaderInfo(~key="attempt_triggered_by", ~title="Attempted By", ~description="")
  | AttemptId =>
    Table.makeHeaderInfo(
      ~key="id",
      ~title="Attempt ID",
      ~description="You can validate the information shown here by cross checking the payment attempt identifier (Attempt ID) in your payment processor portal.",
    )
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Amount => Table.makeHeaderInfo(~key="attempt_amount", ~title="Amount")
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Processor")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  | ConnectorReferenceID =>
    Table.makeHeaderInfo(~key="connector_reference_id", ~title="Connector Reference ID")
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
  | ClientSource => Table.makeHeaderInfo(~key="client_source", ~title="Client Source")
  | ClientVersion => Table.makeHeaderInfo(~key="client_version", ~title="Client Version")
  }
}

let getFrmHeading = (frmDetailsColType: frmColType) => {
  switch frmDetailsColType {
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="PaymentId")
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
  | DsTransactionId => Table.makeHeaderInfo(~key="ds_transaction_id", ~title="Ds Transaction Id")
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

let refundMetaitemToObjMapper = dict => {
  {
    udf1: LogicUtils.getString(dict, "udf1", ""),
    new_customer: LogicUtils.getString(dict, "new_customer", ""),
    login_date: LogicUtils.getString(dict, "login_date", ""),
  }
}

let getRefundMetaData: JSON.t => refundMetaData = json => {
  json->JSON.Decode.object->Option.getOr(Dict.make())->refundMetaitemToObjMapper
}

let refunditemToObjMapper = dict => {
  refund_id: dict->getString("refund_id", ""),
  payment_id: dict->getString("payment_id", ""),
  amount: dict->getFloat("amount", 0.0),
  currency: dict->getString("currency", ""),
  reason: dict->getString("reason", ""),
  status: dict->getString("status", ""),
  error_message: dict->getString("error_message", ""),
  metadata: dict->getJsonObjectFromDict("metadata")->getRefundMetaData,
  updated_at: dict->getString("updated_at", ""),
  created_at: dict->getString("created_at", ""),
}

let attemptsItemToObjMapper = dict => {
  id: dict->getString("id", ""),
  status: dict->getString("status", ""),
  amount: dict->getFloat("amount", 0.0),
  created: dict->getString("created_at", ""),
  attempt_by: dict
  ->getDictfromDict("feature_metadata")
  ->getDictfromDict("revenue_recovery")
  ->getString("attempt_triggered_by", ""),
  currency: dict
  ->getDictfromDict("amount")
  ->getString("currency", ""),
  connector: dict->getString("connector", ""),
  error_message: dict->getString("error_message", ""),
  payment_method: dict->getString("payment_method", ""),
  connector_reference_id: dict->getString("connector_reference_id", ""),
  capture_method: dict->getString("capture_method", ""),
  authentication_type: dict->getString("authentication_type", ""),
  cancellation_reason: dict->getString("cancellation_reason", ""),
  mandate_id: dict->getString("mandate_id", ""),
  error_code: dict->getString("error_code", ""),
  payment_token: dict->getString("payment_token", ""),
  connector_metadata: dict->getString("connector_metadata", ""),
  payment_experience: dict->getString("payment_experience", ""),
  payment_method_type: dict->getString("payment_method_type", ""),
  reference_id: dict->getString("reference_id", ""),
  client_source: dict->getString("client_source", ""),
  client_version: dict->getString("client_version", ""),
  attempt_amount: dict
  ->getDictfromDict("amount")
  ->getFloat("net_amount", 00.0),
}

let getRefunds: JSON.t => array<refunds> = json => {
  LogicUtils.getArrayDataFromJson(json, refunditemToObjMapper)
}

let getAttempts: JSON.t => array<attempts> = json => {
  LogicUtils.getArrayDataFromJson(json, attemptsItemToObjMapper)
}

let allColumns = [
  InvoiceId,
  Amount,
  AmountCapturable,
  AuthenticationType,
  ProfileId,
  CaptureMethod,
  Connector,
  ConnectorTransactionID,
  Created,
  Currency,
  CustomerId,
  Description,
  Email,
  MerchantId,
  PaymentId,
  PaymentMethod,
  PaymentMethodType,
  SetupFutureUsage,
  Status,
  Metadata,
  MerchantOrderReferenceId,
  AttemptCount,
]

let getHeading = (colType: colType) => {
  switch colType {
  | Metadata => Table.makeHeaderInfo(~key="metadata", ~title="Metadata")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Recovery Status", ~dataType=DropDown)
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Processor")
  | AmountCapturable => Table.makeHeaderInfo(~key="amount_capturable", ~title="AmountCapturable")
  | AmountReceived => Table.makeHeaderInfo(~key="amount_received", ~title="Amount Received")
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(~key="connector_transaction_id", ~title="Connector Transaction ID")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Scheduled At")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | CustomerId => Table.makeHeaderInfo(~key="customer_id", ~title="Customer ID")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")
  | SetupFutureUsage => Table.makeHeaderInfo(~key="setup_future_usage", ~title="Setup Future Usage")
  | CaptureMethod => Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | PaymentMethodData =>
    Table.makeHeaderInfo(~key="payment_method_data", ~title="Payment Method Data")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | PaymentToken => Table.makeHeaderInfo(~key="payment_token", ~title="Payment Token")
  | Shipping => Table.makeHeaderInfo(~key="shipping", ~title="Shipping")
  | Email => Table.makeHeaderInfo(~key="email", ~title="Customer Email")
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name")
  | Phone => Table.makeHeaderInfo(~key="phone", ~title="Phone")
  | ReturnUrl => Table.makeHeaderInfo(~key="return_url", ~title="ReturnUrl")
  | AuthenticationType =>
    Table.makeHeaderInfo(~key="authentication_type", ~title="Authentication Type")
  | StatementDescriptorName =>
    Table.makeHeaderInfo(~key="statement_descriptor_name ", ~title="Statement Descriptor Name ")
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(~key="statement_descriptor_suffix", ~title="Statement Descriptor Suffix")
  | NextAction => Table.makeHeaderInfo(~key="next_action", ~title="Next Action")
  | CancellationReason =>
    Table.makeHeaderInfo(~key="cancellation_reason", ~title="Cancellation Reason")
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id")
  | MerchantOrderReferenceId =>
    Table.makeHeaderInfo(~key="merchant_order_reference_id", ~title="Merchant Order Reference Id")
  | AttemptCount => Table.makeHeaderInfo(~key="attempt_count", ~title="Attempt count")
  | InvoiceId => Table.makeHeaderInfo(~key="invoice_id", ~title="Invoice Id")
  }
}

let getStatus = (order, primaryColor) => {
  let orderStatusLabel = order.status->capitalizeString
  let fixedStatusCss = "text-sm text-nd_green-400 font-medium px-2 py-1 rounded-md h-1/2"
  switch order.status->HSwitchOrderUtils.statusVariantMapper {
  | Succeeded
  | PartiallyCaptured =>
    <div className={`${fixedStatusCss} bg-green-50 dark:bg-opacity-50`}>
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
  | RequiresPaymentMethod =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeadingForSummary = summaryColType => {
  switch summaryColType {
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created On")
  | NetAmount => Table.makeHeaderInfo(~key="net_amount", ~title="Net Amount")
  | OrderAmount => Table.makeHeaderInfo(~key="order_amount", ~title="Order Amount")
  | LastUpdated => Table.makeHeaderInfo(~key="modified_at", ~title="Last Updated")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | AmountReceived =>
    Table.makeHeaderInfo(
      ~key="amount_received",
      ~title="Amount Received",
      ~description="Amount captured by the payment processor for this payment.",
    )
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(~key="connector_transaction_id", ~title="Connector Transaction ID")
  | OrderQuantity => Table.makeHeaderInfo(~key="order_quantity", ~title="Order Quantity")
  | ProductName => Table.makeHeaderInfo(~key="product_name", ~title="Product Name")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  }
}

let getHeadingForAboutPayment = aboutPaymentColType => {
  switch aboutPaymentColType {
  | Status => Table.makeHeaderInfo(~key="status", ~title="Recovery Status", ~dataType=DropDown)
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Preferred connector")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id")
  | ProfileName => Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name")
  | CardBrand => Table.makeHeaderInfo(~key="card_brand", ~title="Card Brand")
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | AuthenticationType => Table.makeHeaderInfo(~key="authentication_type", ~title="Auth Type")
  | CaptureMethod => Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method")
  | CardNetwork => Table.makeHeaderInfo(~key="CardNetwork", ~title="Card Brand")
  | MandateId => Table.makeHeaderInfo(~key="MandateId", ~title="Mandate Id")
  | AmountCapturable => Table.makeHeaderInfo(~key="amount_capturable", ~title="Amount Capturable")
  | AmountReceived => Table.makeHeaderInfo(~key="amount_receieved", ~title="Amount Received")
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
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(~key="statement_descriptor_suffix", ~title="Statement Descriptor Suffix")
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
  | AmountCapturable => Table.makeHeaderInfo(~key="amount_capturable", ~title="Amount Capturable")
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | FRMName => Table.makeHeaderInfo(~key="frm_name", ~title="Tag")
  | FRMTransactionType =>
    Table.makeHeaderInfo(~key="frm_transaction_type", ~title="Transaction Flow")
  | FRMStatus => Table.makeHeaderInfo(~key="frm_status", ~title="Message")
  | MerchantOrderReferenceId =>
    Table.makeHeaderInfo(~key="merchant_order_reference_id", ~title="Merchant Order Reference Id")
  }
}

let getCellForSummary = (order, summaryColType): Table.cell => {
  switch summaryColType {
  | Created => Date(order.created)
  | NetAmount =>
    CustomCell(
      <CurrencyCell
        amount={(order.net_amount /. 100.0)->Float.toString} currency={order.currency}
      />,
      "",
    )
  | OrderAmount =>
    CustomCell(
      <CurrencyCell
        amount={(order.order_amount /. 100.0)->Float.toString} currency={order.currency}
      />,
      "",
    )
  | LastUpdated => Date(order.last_updated)
  | PaymentId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="max-w-xs truncate whitespace-nowrap"
        displayValue=order.payment_id
        customParentClass="flex items-center gap-4"
      />,
      "",
    )
  | Currency => Text(order.currency)
  | AmountReceived =>
    CustomCell(
      <CurrencyCell
        amount={(order.amount_received /. 100.0)->Float.toString} currency={order.currency}
      />,
      "",
    )
  | OrderQuantity => Text(order.order_quantity)
  | ProductName => Text(order.product_name)
  | ErrorMessage => Text(order.error_message)
  | ConnectorTransactionID =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="max-w-xs truncate whitespace-nowrap"
        displayValue=order.connector_transaction_id
      />,
      "",
    )
  }
}

let getCellForAboutPayment = (order, aboutPaymentColType: aboutPaymentColType): Table.cell => {
  open HelperComponents
  let orderStatus = order.status->HSwitchOrderUtils.statusVariantMapper
  switch aboutPaymentColType {
  | Status =>
    Label({
      title: order.status->String.toUpperCase,
      color: switch orderStatus {
      | Succeeded
      | PartiallyCaptured =>
        LabelGreen
      | Failed
      | Cancelled =>
        LabelRed
      | Processing
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelLightBlue
      | _ => LabelLightBlue
      },
    })
  | Connector => CustomCell(<ConnectorCustomCell connectorName=order.connector />, "")
  | PaymentMethod => Text(order.payment_method)
  | PaymentMethodType => Text(order.payment_method_type)
  | AuthenticationType => Text(order.authentication_type)
  | ConnectorLabel => Text(order.connector_label)
  | CardBrand => Text(order.card_brand)
  | ProfileId => Text(order.profile_id)
  | ProfileName =>
    Table.CustomCell(
      <HelperComponents.BusinessProfileComponent profile_id={order.profile_id} />,
      "",
    )
  | CaptureMethod => Text(order.capture_method)
  | CardNetwork => {
      let dict = switch order.payment_method_data {
      | Some(val) => val->getDictFromJsonObject
      | _ => Dict.make()
      }

      Text(dict->getString("card_network", ""))
    }
  | MandateId => Text(order.payment_id)
  | AmountCapturable => Currency(order.amount_capturable /. 100.0, order.currency)
  | AmountReceived =>
    CustomCell(
      <CurrencyCell
        amount={(order.amount_received /. 100.0)->Float.toString} currency={order.currency}
      />,
      "",
    )
  }
}

let getCellForOtherDetails = (order, aboutPaymentColType): Table.cell => {
  let splittedName = order.name->String.split(" ")
  switch aboutPaymentColType {
  | MerchantId => Text(order.merchant_id)
  | ReturnUrl => Text(order.return_url)
  | CaptureMethod => Text(order.capture_method)
  | NextAction => Text(order.next_action)
  | SetupFutureUsage => Text(order.setup_future_usage)
  | CancellationReason => Text(order.cancellation_reason)
  | StatementDescriptorName => Text(order.statement_descriptor_name)
  | StatementDescriptorSuffix => Text(order.statement_descriptor_suffix)
  | PaymentExperience => Text(order.payment_experience)
  | FirstName => Text(splittedName->Array.get(0)->Option.getOr(""))
  | LastName => Text(splittedName->Array.get(splittedName->Array.length - 1)->Option.getOr(""))
  | Phone => Text(order.phone)
  | Email => Text(order.email)
  | CustomerId => Text(order.customer_id)
  | Description => Text(order.description)
  | ShippingAddress => Text(order.shipping)
  | ShippingPhone => Text(order.shippingPhone)
  | ShippingEmail => Text(order.shippingEmail)
  | AmountCapturable => Currency(order.amount_capturable /. 100.0, order.currency)
  | ErrorCode => Text(order.error_code)
  | FRMName => Text(order.frm_message.frm_name)
  | FRMTransactionType => Text(order.frm_message.frm_transaction_type)
  | FRMStatus => Text(order.frm_message.frm_status)
  | MerchantOrderReferenceId => Text(order.merchant_order_reference_id)
  }
}

let getCell = (order, colType: colType, merchantId, orgId): Table.cell => {
  open HelperComponents
  let orderStatus = order.status->HSwitchOrderUtils.statusVariantMapper
  switch colType {
  | Metadata =>
    CustomCell(
      <HelperComponents.EllipsisText
        displayValue={order.metadata->JSON.Encode.object->JSON.stringify}
      />,
      "",
    )
  | PaymentId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payments/${order.invoice_id}/${order.profile_id}/${merchantId}/${orgId}`}
        displayValue={order.payment_id}
        copyValue={Some(order.payment_id)}
      />,
      "",
    )
  | MerchantId => Text(order.merchant_id)
  | Connector => CustomCell(<ConnectorCustomCell connectorName={order.connector} />, "")
  | Status =>
    Label({
      title: order.status->String.toUpperCase,
      color: switch orderStatus {
      | Succeeded
      | PartiallyCaptured =>
        LabelGreen
      | Failed
      | Cancelled =>
        LabelRed
      | Processing
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelLightBlue
      | _ => LabelLightBlue
      },
    })
  | Amount =>
    CustomCell(
      <CurrencyCell amount={(order.amount /. 100.0)->Float.toString} currency={order.currency} />,
      "",
    )
  | AmountCapturable => Currency(order.amount_capturable /. 100.0, order.currency)
  | AmountReceived => Currency(order.amount_received /. 100.0, order.currency)
  | Created => Date(order.created)
  | Currency => Text(order.currency)
  | CustomerId => Text(order.customer_id)
  | Description =>
    CustomCell(<HelperComponents.EllipsisText displayValue={order.description} endValue={5} />, "")
  | SetupFutureUsage => Text(order.setup_future_usage)
  | CaptureMethod => Text(order.capture_method)
  | PaymentMethod => Text(order.payment_method)
  | PaymentMethodData => Text(order.payment_method_data->JSON.stringifyAny->Option.getOr(""))
  | PaymentMethodType => Text(order.payment_method_type)
  | PaymentToken => Text(order.payment_token)
  | Shipping => Text(order.shipping)
  | Email => Text(order.email)
  | Name => Text(order.name)
  | Phone => Text(order.phone)
  | ReturnUrl => Text(order.return_url)
  | AuthenticationType => Text(order.authentication_type)
  | StatementDescriptorName => Text(order.statement_descriptor_name)
  | StatementDescriptorSuffix => Text(order.statement_descriptor_suffix)
  | NextAction => Text(order.next_action)
  | CancellationReason => Text(order.cancellation_reason)
  | ErrorCode => Text(order.error_code)
  | ErrorMessage => Text(order.error_message)
  | ConnectorTransactionID =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="max-w-xs truncate whitespace-nowrap"
        displayValue=order.connector_transaction_id
      />,
      "",
    )
  | ProfileId => Text(order.profile_id)
  | MerchantOrderReferenceId => Text(order.merchant_order_reference_id)
  | AttemptCount => Text(order.attempt_count->Int.toString)
  | InvoiceId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payments/${order.payment_id}/${order.profile_id}/${merchantId}/${orgId}`}
        displayValue={order.invoice_id}
        copyValue={Some(order.invoice_id)}
      />,
      "",
    )
  }
}

let itemToObjMapperForFRMDetails = dict => {
  {
    frm_name: dict->getString("frm_name", ""),
    frm_transaction_id: dict->getString("frm_transaction_id", ""),
    frm_transaction_type: dict->getString("frm_transaction_type", ""),
    frm_status: dict->getString("frm_status", ""),
    frm_score: dict->getInt("frm_score", 0),
    frm_reason: dict->getString("frm_reason", ""),
    frm_error: dict->getString("frm_error", ""),
  }
}

let getFRMDetails = dict => {
  dict->getJsonObjectFromDict("frm_message")->getDictFromJsonObject->itemToObjMapperForFRMDetails
}

let concatValueOfGivenKeysOfDict = (dict, keys) => {
  Array.reduceWithIndex(keys, "", (acc, key, i) => {
    let val = dict->getString(key, "")
    let delimiter = if val->isNonEmptyString {
      if key !== "first_name" {
        i + 1 == keys->Array.length ? "." : ", "
      } else {
        " "
      }
    } else {
      ""
    }
    String.concat(acc, `${val}${delimiter}`)
  })
}

let defaultColumns: array<colType> = [InvoiceId, PaymentId, Connector, Status, Created]
let itemToObjMapper = dict => {
  let addressKeys = ["line1", "line2", "line3", "city", "state", "country", "zip"]

  let getPhoneNumberString = (phone, ~phoneKey="number", ~codeKey="country_code") => {
    `${phone->getString(codeKey, "")} ${phone->getString(phoneKey, "NA")}`
  }

  let getEmail = dict => {
    let defaultEmail = dict->getString("email", "")

    dict
    ->getDictfromDict("customer")
    ->getString("email", defaultEmail)
  }

  {
    payment_id: dict->getString("id", ""),
    invoice_id: dict->getString("id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    net_amount: dict->getFloat("net_amount", 0.0),
    order_amount: dict
    ->getDictfromDict("amount")
    ->getFloat("order_amount", 0.0),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    amount: dict->getFloat("amount", 0.0),
    amount_capturable: dict->getFloat("amount_capturable", 0.0),
    amount_received: dict->getFloat("amount_received", 0.0),
    created: dict->getString("created", ""),
    last_updated: dict->getString("modified_at", ""),
    currency: dict->getString("currency", ""),
    customer_id: dict->getString("customer_id", ""),
    description: dict->getString("description", ""),
    setup_future_usage: dict->getString("setup_future_usage", ""),
    capture_method: dict->getString("capture_method", ""),
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_data: {
      let paymentMethodData = dict->getJsonObjectFromDict("payment_method_data")
      switch paymentMethodData->JSON.Classify.classify {
      | Object(value) => Some(value->getJsonObjectFromDict("card"))
      | _ => None
      }
    },
    external_authentication_details: {
      let externalAuthenticationDetails =
        dict->getJsonObjectFromDict("external_authentication_details")
      switch externalAuthenticationDetails->JSON.Classify.classify {
      | Object(_) => Some(externalAuthenticationDetails)
      | _ => None
      }
    },
    payment_token: dict->getString("payment_token", ""),
    shipping: dict
    ->getDictfromDict("shipping")
    ->getDictfromDict("address")
    ->concatValueOfGivenKeysOfDict(addressKeys),
    shippingEmail: dict->getDictfromDict("shipping")->getString("email", ""),
    shippingPhone: dict
    ->getDictfromDict("shipping")
    ->getDictfromDict("phone")
    ->getPhoneNumberString,
    metadata: dict->getJsonObjectFromDict("metadata")->getDictFromJsonObject,
    email: dict->getEmail,
    name: dict->getString("name", ""),
    phone: dict
    ->getDictfromDict("customer")
    ->getPhoneNumberString(~phoneKey="phone", ~codeKey="phone_country_code"),
    return_url: dict->getString("return_url", ""),
    authentication_type: dict->getString("authentication_type", ""),
    statement_descriptor_name: dict->getString("statement_descriptor_name", ""),
    statement_descriptor_suffix: dict->getString("statement_descriptor_suffix", ""),
    next_action: dict->getString("next_action", ""),
    cancellation_reason: dict->getString("cancellation_reason", ""),
    error_code: dict->getString("error_code", ""),
    error_message: dict->getString("error_message", ""),
    order_quantity: dict->getString("order_quantity", ""),
    product_name: dict->getString("product_name", ""),
    card_brand: dict->getString("card_brand", ""),
    payment_experience: dict->getString("payment_experience", ""),
    connector_transaction_id: dict->getString("connector_transaction_id", ""),
    profile_id: dict->getString("profile_id", ""),
    frm_message: dict->getFRMDetails,
    merchant_decision: dict->getString("merchant_decision", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
    disputes: dict->getArrayFromDict("disputes", [])->JSON.Encode.array->DisputesEntity.getDisputes,
    attempts: dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts,
    merchant_order_reference_id: dict->getString("merchant_order_reference_id", ""),
    attempt_count: dict->getInt("attempt_count", 0),
    connector_label: dict->getString("connector_label", "NA"),
    attempt_amount: dict
    ->getDictfromDict("amount")
    ->getFloat("net_amount", 0.0),
  }
}
let getOrders: JSON.t => array<order> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let revenueRecoveryEntity = (merchantId, orgId) =>
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getOrders,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell=(order, colType) => getCell(order, colType, merchantId, orgId),
    ~dataKey="",
    ~getShowLink={
      order =>
        GlobalVars.appendDashboardPath(
          ~url=`v2/recovery/overview/${order.invoice_id}/${order.profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
