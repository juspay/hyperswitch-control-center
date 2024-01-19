open OrderTypes
open LogicUtils

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
        amount={(refunds.amount /. 100.0)->Belt.Float.toString} currency={refunds.currency}
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
  open HSwitchUtils
  open HelperComponents
  switch attemptColType {
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(attempt.amount /. 100.0)->Belt.Float.toString} currency={attempt.currency}
      />,
      "",
    )
  | Currency => Text(attempt.currency)
  | Connector => CustomCell(<ConnectorCustomCell connectorName=attempt.connector />, "")
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
  | PaymentMethod => Text(attempt.payment_method)
  | PaymentMethodType => Text(attempt.payment_method_type)
  | AttemptId => CustomCell(<CopyTextCustomComp displayValue=attempt.attempt_id />, "")
  | ErrorMessage => Text(attempt.error_message)
  | ConnectorTransactionID =>
    CustomCell(<CopyTextCustomComp displayValue=attempt.connector_transaction_id />, "")
  | CaptureMethod => Text(attempt.capture_method)
  | AuthenticationType => Text(attempt.authentication_type)
  | CancellationReason => Text(attempt.cancellation_reason)
  | MandateID => Text(attempt.mandate_id)
  | ErrorCode => Text(attempt.error_code)
  | PaymentToken => Text(attempt.payment_token)
  | ConnectorMetadata => Text(attempt.connector_metadata)
  | PaymentExperience => Text(attempt.payment_experience)
  | ReferenceID => Text(attempt.reference_id)
  }
}

let getFrmCell = (orderDetais: order, frmColType: frmColType): Table.cell => {
  switch frmColType {
  | PaymentId => Text(orderDetais.payment_id)
  | PaymentMethodType => Text(orderDetais.payment_method_type)
  | Amount =>
    CustomCell(
      <CurrencyCell
        amount={(orderDetais.amount /. 100.0)->Belt.Float.toString} currency={orderDetais.currency}
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

let refundColumns: array<refundsColType> = [Created, LastUpdated, Amount, PaymentId, RefundStatus]

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
]

let getRefundHeading = (refundsColType: refundsColType) => {
  switch refundsColType {
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=true, ())
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created", ~showSort=true, ())
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency", ~showSort=true, ())
  | LastUpdated =>
    Table.makeHeaderInfo(~key="last_updated", ~title="Last Updated", ~showSort=true, ())
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment Id", ~showSort=true, ())
  | RefundStatus => Table.makeHeaderInfo(~key="status", ~title="Refund Status", ~showSort=true, ())
  | RefundId => Table.makeHeaderInfo(~key="refund_id", ~title="Refund ID", ~showSort=true, ())
  | RefundReason => Table.makeHeaderInfo(~key="reason", ~title="Refund Reason", ~showSort=true, ())
  | ErrorMessage =>
    Table.makeHeaderInfo(~key="error_message", ~title="Error Message", ~showSort=true, ())
  }
}

let getAttemptHeading = (attemptColType: attemptColType) => {
  switch attemptColType {
  | AttemptId => Table.makeHeaderInfo(~key="attempt_id", ~title="Attempt ID", ~showSort=true, ())
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~showSort=true, ())
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=true, ())
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency", ~showSort=true, ())
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector", ~showSort=true, ())
  | PaymentMethod =>
    Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method", ~showSort=true, ())
  | PaymentMethodType =>
    Table.makeHeaderInfo(
      ~key="payment_method_type",
      ~title="Payment Method Type",
      ~showSort=true,
      (),
    )
  | ErrorMessage =>
    Table.makeHeaderInfo(~key="error_message", ~title="Error Message", ~showSort=true, ())
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(
      ~key="connector_transaction_id",
      ~title="Connector Transaction ID",
      ~showSort=true,
      (),
    )
  | CaptureMethod =>
    Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method", ~showSort=true, ())
  | AuthenticationType =>
    Table.makeHeaderInfo(
      ~key="authentication_type",
      ~title="Authentication Type",
      ~showSort=true,
      (),
    )
  | CancellationReason =>
    Table.makeHeaderInfo(
      ~key="cancellation_reason",
      ~title="Cancellation Reason",
      ~showSort=true,
      (),
    )
  | MandateID => Table.makeHeaderInfo(~key="mandate_id", ~title="Mandate ID", ~showSort=true, ())
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code", ~showSort=true, ())
  | PaymentToken =>
    Table.makeHeaderInfo(~key="payment_token", ~title="Payment Token", ~showSort=true, ())
  | ConnectorMetadata =>
    Table.makeHeaderInfo(~key="connector_metadata", ~title="Connector Metadata", ~showSort=true, ())
  | PaymentExperience =>
    Table.makeHeaderInfo(~key="payment_experience", ~title="Payment Experience", ~showSort=true, ())
  | ReferenceID =>
    Table.makeHeaderInfo(~key="reference_id", ~title="Reference ID", ~showSort=true, ())
  }
}

let getFrmHeading = (frmDetailsColType: frmColType) => {
  switch frmDetailsColType {
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="PaymentId", ~showSort=true, ())
  | PaymentMethodType =>
    Table.makeHeaderInfo(
      ~key="payment_method_type",
      ~title="Payment Method Type",
      ~showSort=true,
      (),
    )
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=true, ())
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency", ~showSort=true, ())
  | PaymentProcessor =>
    Table.makeHeaderInfo(~key="connector", ~title="Payment Processor", ~showSort=true, ())
  | FRMConnector =>
    Table.makeHeaderInfo(~key="frm_connector", ~title="FRM Connector", ~showSort=true, ())
  | FRMMessage => Table.makeHeaderInfo(~key="frm_message", ~title="FRM Message", ~showSort=true, ())
  | MerchantDecision =>
    Table.makeHeaderInfo(~key="merchant_decision", ~title="Merchant Decision", ~showSort=true, ())
  }
}

let refundMetaitemToObjMapper = dict => {
  {
    udf1: LogicUtils.getString(dict, "udf1", ""),
    new_customer: LogicUtils.getString(dict, "new_customer", ""),
    login_date: LogicUtils.getString(dict, "login_date", ""),
  }
}

let getRefundMetaData: Js.Json.t => refundMetaData = json => {
  json->Js.Json.decodeObject->Belt.Option.getWithDefault(Dict.make())->refundMetaitemToObjMapper
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
  attempt_id: dict->getString("attempt_id", ""),
  status: dict->getString("status", ""),
  amount: dict->getFloat("amount", 0.0),
  currency: dict->getString("currency", ""),
  connector: dict->getString("connector", ""),
  error_message: dict->getString("error_message", ""),
  payment_method: dict->getString("payment_method", ""),
  connector_transaction_id: dict->getString("connector_transaction_id", ""),
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
}

let getRefunds: Js.Json.t => array<refunds> = json => {
  LogicUtils.getArrayDataFromJson(json, refunditemToObjMapper)
}

let getAttempts: Js.Json.t => array<attempts> = json => {
  LogicUtils.getArrayDataFromJson(json, attemptsItemToObjMapper)
}

let defaultColumns: array<colType> = [
  PaymentId,
  Connector,
  ConnectorTransactionID,
  Amount,
  Status,
  PaymentMethod,
  PaymentMethodType,
  Created,
]

let allColumns = [
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
  Email,
  MerchantId,
  PaymentId,
  PaymentMethod,
  PaymentMethodType,
  SetupFutureUsage,
  Status,
]

let ordersMapDefaultCols = Recoil.atom(. "ordersMapDefaultCols", defaultColumns)

let getHeading = (colType: colType) => {
  switch colType {
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID", ~showSort=false, ())
  | MerchantId =>
    Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID", ~showSort=false, ())
  | Status =>
    Table.makeHeaderInfo(
      ~key="status",
      ~title="Payment Status",
      ~dataType=DropDown,
      ~showSort=false,
      (),
    )
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=false, ())
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector", ~showSort=false, ())
  | AmountCapturable =>
    Table.makeHeaderInfo(~key="amount_capturable", ~title="AmountCapturable", ~showSort=false, ())
  | AmountReceived =>
    Table.makeHeaderInfo(~key="amount_received", ~title="Amount Received", ~showSort=false, ())
  | ClientSecret =>
    Table.makeHeaderInfo(~key="client_secret", ~title="Client Secret", ~showSort=false, ())
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(
      ~key="connector_transaction_id",
      ~title="Connector Transaction ID",
      ~showSort=false,
      (),
    )
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created", ~showSort=false, ())
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency", ~showSort=false, ())
  | CustomerId =>
    Table.makeHeaderInfo(~key="customer_id", ~title="Customer ID", ~showSort=false, ())
  | CustomerEmail =>
    Table.makeHeaderInfo(~key="email", ~title="Customer Email", ~showSort=false, ())

  | Description =>
    Table.makeHeaderInfo(~key="description", ~title="Description", ~showSort=false, ())

  | MandateId => Table.makeHeaderInfo(~key="mandate_id", ~title="Mandate ID", ~showSort=false, ())
  | MandateData =>
    Table.makeHeaderInfo(~key="mandate_data", ~title="Mandate Data", ~showSort=false, ())
  | SetupFutureUsage =>
    Table.makeHeaderInfo(
      ~key="setup_future_usage",
      ~title="Setup Future Usage",
      ~showSort=false,
      (),
    )
  | OffSession =>
    Table.makeHeaderInfo(~key="off_session", ~title="Off Session", ~showSort=false, ())
  | CaptureOn => Table.makeHeaderInfo(~key="capture_on", ~title="Capture On", ~showSort=false, ())
  | CaptureMethod =>
    Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method", ~showSort=false, ())
  | PaymentMethod =>
    Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method", ~showSort=false, ())
  | PaymentMethodData =>
    Table.makeHeaderInfo(
      ~key="payment_method_data",
      ~title="Payment Method Data",
      ~showSort=false,
      (),
    )
  | PaymentMethodType =>
    Table.makeHeaderInfo(
      ~key="payment_method_type",
      ~title="Payment Method Type",
      ~showSort=false,
      (),
    )
  | PaymentToken =>
    Table.makeHeaderInfo(~key="payment_token", ~title="Payment Token", ~showSort=false, ())
  | Shipping => Table.makeHeaderInfo(~key="shipping", ~title="Shipping", ~showSort=false, ())
  | Billing => Table.makeHeaderInfo(~key="billing", ~title="Billing", ~showSort=false, ())
  | Email => Table.makeHeaderInfo(~key="email", ~title="Email", ~showSort=false, ())
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name", ~showSort=false, ())
  | Phone => Table.makeHeaderInfo(~key="phone", ~title="Phone", ~showSort=false, ())
  | ReturnUrl => Table.makeHeaderInfo(~key="return_url", ~title="ReturnUrl", ~showSort=false, ())
  | AuthenticationType =>
    Table.makeHeaderInfo(
      ~key="authentication_type",
      ~title="Authentication Type",
      ~showSort=false,
      (),
    )
  | StatementDescriptorName =>
    Table.makeHeaderInfo(
      ~key="statement_descriptor_name ",
      ~title="Statement Descriptor Name ",
      ~showSort=false,
      (),
    )
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(
      ~key="statement_descriptor_suffix",
      ~title="Statement Descriptor Suffix",
      ~showSort=false,
      (),
    )
  | NextAction =>
    Table.makeHeaderInfo(~key="next_action", ~title="Next Action", ~showSort=false, ())
  | CancellationReason =>
    Table.makeHeaderInfo(
      ~key="cancellation_reason",
      ~title="Cancellation Reason",
      ~showSort=false,
      (),
    )
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code", ~showSort=false, ())
  | ErrorMessage =>
    Table.makeHeaderInfo(~key="error_message", ~title="Error Message", ~showSort=false, ())
  | Refunds => Table.makeHeaderInfo(~key="refunds", ~title="Refunds", ~showSort=false, ())
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id", ~showSort=false, ())
  }
}

let getStatus = order => {
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
  | RequiresPaymentMethod =>
    <div className={`${fixedStatusCss} bg-blue-800 bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedStatusCss} bg-blue-800 bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeadingForSummary = summaryColType => {
  switch summaryColType {
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created", ~showSort=true, ())
  | NetAmount => Table.makeHeaderInfo(~key="net_amount", ~title="Net Amount", ~showSort=true, ())
  | LastUpdated =>
    Table.makeHeaderInfo(~key="last_updated", ~title="Last Updated", ~showSort=true, ())
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID", ~showSort=true, ())
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency", ~showSort=true, ())
  | AmountReceived =>
    Table.makeHeaderInfo(
      ~key="amount_received",
      ~title="Amount Received",
      ~description="Amount captured by the payment processor for this payment.",
      ~showSort=true,
      (),
    )
  | ClientSecret =>
    Table.makeHeaderInfo(~key="client_secret", ~title="Client Secret", ~showSort=true, ())
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(
      ~key="connector_transaction_id",
      ~title="Connector Transaction ID",
      ~showSort=true,
      (),
    )
  | OrderQuantity =>
    Table.makeHeaderInfo(~key="order_quantity", ~title="Order Quantity", ~showSort=true, ())
  | ProductName =>
    Table.makeHeaderInfo(~key="product_name", ~title="Product Name", ~showSort=true, ())
  | ErrorMessage =>
    Table.makeHeaderInfo(~key="error_message", ~title="Error Message", ~showSort=true, ())
  }
}

let getHeadingForAboutPayment = aboutPaymentColType => {
  switch aboutPaymentColType {
  | Connector =>
    Table.makeHeaderInfo(~key="connector", ~title="Preferred connector", ~showSort=true, ())
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id", ~showSort=true, ())
  | ProfileName =>
    Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name", ~showSort=true, ())
  | CardBrand => Table.makeHeaderInfo(~key="card_brand", ~title="Card Brand", ~showSort=true, ())
  | ConnectorLabel =>
    Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label", ~showSort=true, ())
  | PaymentMethod =>
    Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method", ~showSort=true, ())
  | PaymentMethodType =>
    Table.makeHeaderInfo(
      ~key="payment_method_type",
      ~title="Payment Method Type",
      ~showSort=true,
      (),
    )
  | Refunds => Table.makeHeaderInfo(~key="refunds", ~title="Refunds", ~showSort=true, ())
  | AuthenticationType =>
    Table.makeHeaderInfo(~key="authentication_type", ~title="Auth Type", ~showSort=true, ())

  | CaptureMethod =>
    Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method", ~showSort=true, ())
  }
}

let getHeadingForOtherDetails = otherDetailsColType => {
  switch otherDetailsColType {
  | ReturnUrl => Table.makeHeaderInfo(~key="return_url", ~title="Return URL", ~showSort=true, ())
  | SetupFutureUsage =>
    Table.makeHeaderInfo(~key="setup_future_usage", ~title="Setup Future Usage", ~showSort=true, ())
  | CancellationReason =>
    Table.makeHeaderInfo(
      ~key="cancellation_reason",
      ~title="Cancellation Reason",
      ~showSort=true,
      (),
    )
  | StatementDescriptorName =>
    Table.makeHeaderInfo(
      ~key="statement_descriptor_name",
      ~title="Statement Descriptor Name",
      ~showSort=true,
      (),
    )
  | CaptureMethod =>
    Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method", ~showSort=true, ())
  | CaptureOn => Table.makeHeaderInfo(~key="capture_on", ~title="Capture On", ~showSort=true, ())
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(
      ~key="statement_descriptor_suffix",
      ~title="Statement Descriptor Suffix",
      ~showSort=true,
      (),
    )
  | OffSession => Table.makeHeaderInfo(~key="off_session", ~title="Off Session", ~showSort=true, ())
  | NextAction => Table.makeHeaderInfo(~key="next_action", ~title="Next Action", ~showSort=true, ())
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID", ~showSort=true, ())
  | PaymentExperience =>
    Table.makeHeaderInfo(~key="payment_experience", ~title="Payment Experience", ~showSort=true, ())
  | Email => Table.makeHeaderInfo(~key="email", ~title="Customer Email", ~showSort=true, ())
  | FirstName => Table.makeHeaderInfo(~key="firstName", ~title="First Name", ~showSort=true, ())
  | LastName => Table.makeHeaderInfo(~key="lastName", ~title="Last Name", ~showSort=true, ())
  | Phone => Table.makeHeaderInfo(~key="phone", ~title="Customer Phone", ~showSort=true, ())
  | CustomerId => Table.makeHeaderInfo(~key="customer_id", ~title="Customer ID", ~showSort=true, ())
  | Description =>
    Table.makeHeaderInfo(~key="description", ~title="Description", ~showSort=true, ())
  | Shipping => Table.makeHeaderInfo(~key="shipping", ~title="Shipping Address", ~showSort=true, ())
  | Billing => Table.makeHeaderInfo(~key="billing", ~title="Billing Address", ~showSort=true, ())
  | AmountCapturable =>
    Table.makeHeaderInfo(~key="amount_capturable", ~title="AmountCapturable", ~showSort=true, ())
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code", ~showSort=true, ())
  | MandateData =>
    Table.makeHeaderInfo(~key="mandate_data", ~title="Mandate Data", ~showSort=true, ())
  | FRMName => Table.makeHeaderInfo(~key="frm_name", ~title="FRM Tag", ~showSort=true, ())
  | FRMTransactionType =>
    Table.makeHeaderInfo(
      ~key="frm_transaction_type",
      ~title="FRM Transaction Flow",
      ~showSort=true,
      (),
    )
  | FRMStatus => Table.makeHeaderInfo(~key="frm_status", ~title="FRM Message", ~showSort=true, ())
  }
}

let getCellForSummary = (order, summaryColType, _): Table.cell => {
  open HelperComponents
  switch summaryColType {
  | Created => Date(order.created)
  | NetAmount =>
    CustomCell(
      <CurrencyCell
        amount={(order.net_amount /. 100.0)->Belt.Float.toString} currency={order.currency}
      />,
      "",
    )
  | LastUpdated => Date(order.last_updated)
  | PaymentId => CustomCell(<CopyTextCustomComp displayValue=order.payment_id />, "")
  | Currency => Text(order.currency)
  | AmountReceived =>
    CustomCell(
      <CurrencyCell
        amount={(order.amount_received /. 100.0)->Belt.Float.toString} currency={order.currency}
      />,
      "",
    )
  | ClientSecret => Text(order.client_secret)
  | OrderQuantity => Text(order.order_quantity)
  | ProductName => Text(order.product_name)
  | ErrorMessage => Text(order.error_message)
  | ConnectorTransactionID =>
    CustomCell(<CopyTextCustomComp displayValue=order.connector_transaction_id />, "")
  }
}

let getCellForAboutPayment = (
  order,
  aboutPaymentColType: aboutPaymentColType,
  connectorList,
): Table.cell => {
  open HSwitchUtils
  switch aboutPaymentColType {
  | Connector => CustomCell(<ConnectorCustomCell connectorName=order.connector />, "")
  | PaymentMethod => Text(order.payment_method)
  | PaymentMethodType => Text(order.payment_method_type)
  | Refunds => Text(order.refunds->Array.length > 0 ? "Yes" : "No")
  | AuthenticationType => Text(order.authentication_type)
  | ConnectorLabel => {
      let connectorLabel =
        connectorList
        ->Array.find(ele =>
          order.merchant_connector_id === ele->getString("merchant_connector_id", "")
        )
        ->Option.getWithDefault(Dict.make())
        ->getString("connector_label", "")

      Text(connectorLabel)
    }
  | CardBrand => Text(order.card_brand)
  | ProfileId => Text(order.profile_id)
  | ProfileName =>
    Table.CustomCell(<MerchantAccountUtils.BusinessProfile profile_id={order.profile_id} />, "")
  | CaptureMethod => Text(order.capture_method)
  }
}

let getCellForOtherDetails = (order, aboutPaymentColType, _): Table.cell => {
  let splittedName = order.name->String.split(" ")
  switch aboutPaymentColType {
  | MerchantId => Text(order.merchant_id)
  | ReturnUrl => Text(order.return_url)
  | OffSession => Text(order.off_session)
  | CaptureOn => Date(order.off_session)
  | CaptureMethod => Text(order.capture_method)
  | NextAction => Text(order.next_action)
  | SetupFutureUsage => Text(order.setup_future_usage)
  | CancellationReason => Text(order.cancellation_reason)
  | StatementDescriptorName => Text(order.statement_descriptor_name)
  | StatementDescriptorSuffix => Text(order.statement_descriptor_suffix)
  | PaymentExperience => Text(order.payment_experience)
  | FirstName => Text(splittedName->Belt.Array.get(0)->Belt.Option.getWithDefault(""))
  | LastName =>
    Text(
      splittedName->Belt.Array.get(splittedName->Array.length - 1)->Belt.Option.getWithDefault(""),
    )
  | Phone => Text(order.phone)
  | Email => Text(order.email)
  | CustomerId => Text(order.customer_id)
  | Description => Text(order.description)
  | Shipping => Text(order.shipping)
  | Billing => Text(order.billing)
  | AmountCapturable => Currency(order.amount_capturable /. 100.0, order.currency)
  | ErrorCode => Text(order.error_code)
  | MandateData => Text(order.mandate_data)
  | FRMName => Text(order.frm_message.frm_name)
  | FRMTransactionType => Text(order.frm_message.frm_transaction_type)
  | FRMStatus => Text(order.frm_message.frm_status)
  }
}

let getCell = (order, colType: colType): Table.cell => {
  open HSwitchUtils
  let orderStatus = order.status->HSwitchOrderUtils.statusVariantMapper
  switch colType {
  | PaymentId => Text(order.payment_id)
  | MerchantId => Text(order.merchant_id)
  | Connector => CustomCell(<ConnectorCustomCell connectorName=order.connector />, "")
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
      <CurrencyCell
        amount={(order.amount /. 100.0)->Belt.Float.toString} currency={order.currency}
      />,
      "",
    )
  | AmountCapturable => Currency(order.amount_capturable /. 100.0, order.currency)
  | AmountReceived => Currency(order.amount_received /. 100.0, order.currency)
  | ClientSecret => Text(order.client_secret)
  | Created => Date(order.created)
  | Currency => Text(order.currency)
  | CustomerId => Text(order.customer_id)
  | CustomerEmail => Text(order.email)
  | Description => Text(order.description)
  | MandateId => Text(order.mandate_id)
  | MandateData => Text(order.mandate_data)
  | SetupFutureUsage => Text(order.setup_future_usage)
  | OffSession => Text(order.off_session)
  | CaptureOn => Date(order.off_session)
  | CaptureMethod => Text(order.capture_method)
  | PaymentMethod => Text(order.payment_method)
  | PaymentMethodType => Text(order.payment_method_type)
  | PaymentMethodData => Text(order.payment_method_data)
  | PaymentToken => Text(order.payment_token)
  | Shipping => Text(order.shipping)
  | Billing => Text(order.billing)
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
  | ConnectorTransactionID => Text(order.connector_transaction_id)
  | ProfileId => Text(order.profile_id)
  | Refunds =>
    Text(
      switch order.refunds->Js.Json.stringifyAny {
      | None => "-"
      | Some(v) => v
      },
    )
  }
}

let _ = Recoil.atom(. "hyperSwitchOrderDefaultCols", defaultColumns)

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
    let delimiter = if val->String.length > 0 {
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

let itemToObjMapper = dict => {
  let addressKeys = [
    "first_name",
    "last_name",
    "line1",
    "line2",
    "line3",
    "city",
    "state",
    "country",
    "zip",
  ]
  {
    payment_id: dict->getString("payment_id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    net_amount: dict->getFloat("net_amount", 0.0),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    amount: dict->getFloat("amount", 0.0),
    amount_capturable: dict->getFloat("amount_capturable", 0.0),
    amount_received: dict->getFloat("amount_received", 0.0),
    client_secret: dict->getString("client_secret", ""),
    created: dict->getString("created", ""),
    last_updated: dict->getString("last_updated", ""),
    currency: dict->getString("currency", ""),
    customer_id: dict->getString("customer_id", ""),
    description: dict->getString("description", ""),
    mandate_id: dict->getString("mandate_id", ""),
    mandate_data: dict->getString("mandate_data", ""),
    setup_future_usage: dict->getString("setup_future_usage", ""),
    off_session: dict->getString("off_session", ""),
    capture_on: dict->getString("capture_on", ""),
    capture_method: dict->getString("capture_method", ""),
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_data: dict->getString("payment_method_data", ""),
    payment_token: dict->getString("payment_token", ""),
    shipping: dict
    ->getDictfromDict("shipping")
    ->getDictfromDict("address")
    ->concatValueOfGivenKeysOfDict(addressKeys),
    billing: dict
    ->getDictfromDict("billing")
    ->getDictfromDict("address")
    ->concatValueOfGivenKeysOfDict(addressKeys),
    metadata: dict->getJsonObjectFromDict("metadata")->getDictFromJsonObject,
    email: dict->getString("email", ""),
    name: dict->getString("name", ""),
    phone: dict->getString("phone", ""),
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
    refunds: dict
    ->getArrayFromDict("refunds", [])
    ->Js.Json.array
    ->getArrayDataFromJson(refunditemToObjMapper),
    profile_id: dict->getString("profile_id", ""),
    frm_message: dict->getFRMDetails,
    merchant_decision: dict->getString("merchant_decision", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
  }
}

let getOrders: Js.Json.t => array<order> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let orderEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects=getOrders,
  ~defaultColumns,
  ~allColumns,
  //~defaultFilters=getDefaultFilters(getDateCreatedObject()),
  ~getHeading,
  ~getCell,
  ~dataKey="",
  ~getShowLink={order => `/payments/${order.payment_id}`},
  //~initialFilters=initialFilterFields,
  (),
)
