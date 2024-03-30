type refundsObject = {
  internal_reference_id: string,
  refund_id: string,
  payment_id: string,
  merchant_id: string,
  connector_transaction_id: string,
  connector: string,
  connector_refund_id: string,
  external_reference_id: string,
  refund_type: string,
  total_amount: float,
  currency: string,
  refund_amount: float,
  refund_status: string,
  sent_to_gateway: bool,
  refund_error_message: string,
  refund_arn: string,
  created_at: int,
  modified_at: int,
  description: string,
  attempt_id: string,
  refund_reason: string,
  refund_error_code: string,
  sign_flag: int,
  timestamp: string,
}

type cols =
  | InternalReferenceId
  | RefundId
  | PaymentId
  | MerchantId
  | ConnectorTransactionId
  | Connector
  | ConnectorRefundId
  | ExternalReferenceId
  | RefundType
  | TotalAmount
  | Currency
  | RefundAmount
  | Refundstatus
  | SentToGateway
  | RefundErrorMessage
  | RefundArn
  | CreatedAt
  | ModifiedAt
  | Description
  | AttemptId
  | RefundReason
  | RefundErrorCode
  | SignFlag
  | Timestamp

let visibleColumns = [RefundId, PaymentId, Connector, TotalAmount, Currency, Refundstatus]

let colMapper = (col: cols) => {
  switch col {
  | InternalReferenceId => "internal_reference_id"
  | RefundId => "refund_id"
  | PaymentId => "payment_id"
  | MerchantId => "merchant_id"
  | ConnectorTransactionId => "connector_transaction_id"
  | Connector => "connector"
  | ConnectorRefundId => "connector_refund_id"
  | ExternalReferenceId => "external_reference_id"
  | RefundType => "refund_type"
  | TotalAmount => "total_amount"
  | Currency => "currency"
  | RefundAmount => "refund_amount"
  | Refundstatus => "refund_status"
  | SentToGateway => "sent_to_gateway"
  | RefundErrorMessage => "refund_error_message"
  | RefundArn => "refund_arn"
  | CreatedAt => "created_at"
  | ModifiedAt => "modified_at"
  | Description => "description"
  | AttemptId => "attempt_id"
  | RefundReason => "refund_reason"
  | RefundErrorCode => "refund_error_code"
  | SignFlag => "sign_flag"
  | Timestamp => "timestamp"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => refundsObject = dict => {
  open LogicUtils

  {
    internal_reference_id: dict->getString(InternalReferenceId->colMapper, "NA"),
    refund_id: dict->getString(RefundId->colMapper, "NA"),
    payment_id: dict->getString(PaymentId->colMapper, "NA"),
    merchant_id: dict->getString(MerchantId->colMapper, "NA"),
    connector_transaction_id: dict->getString(ConnectorTransactionId->colMapper, "NA"),
    connector: dict->getString(Connector->colMapper, "NA"),
    connector_refund_id: dict->getString(ConnectorRefundId->colMapper, "NA"),
    external_reference_id: dict->getString(ExternalReferenceId->colMapper, "NA"),
    refund_type: dict->getString(RefundType->colMapper, "NA"),
    total_amount: dict->getFloat(TotalAmount->colMapper, 0.0),
    currency: dict->getString(Currency->colMapper, "NA"),
    refund_amount: dict->getFloat(RefundAmount->colMapper, 0.0),
    refund_status: dict->getString(Refundstatus->colMapper, "NA"),
    sent_to_gateway: dict->getBool(SentToGateway->colMapper, false),
    refund_error_message: dict->getString(RefundErrorMessage->colMapper, "NA"),
    refund_arn: dict->getString(RefundArn->colMapper, "NA"),
    created_at: dict->getInt(CreatedAt->colMapper, 0),
    modified_at: dict->getInt(ModifiedAt->colMapper, 0),
    description: dict->getString(Description->colMapper, "NA"),
    attempt_id: dict->getString(AttemptId->colMapper, "NA"),
    refund_reason: dict->getString(RefundReason->colMapper, "NA"),
    refund_error_code: dict->getString(RefundErrorCode->colMapper, "NA"),
    sign_flag: dict->getInt(SignFlag->colMapper, 0),
    timestamp: dict->getString(Timestamp->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<refundsObject> = json => {
  open LogicUtils
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | InternalReferenceId =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Internal Reference Id ",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | RefundId =>
    Table.makeHeaderInfo(~key, ~title="Refund Id", ~dataType=TextType, ~showSort=false, ())
  | PaymentId =>
    Table.makeHeaderInfo(~key, ~title="Payment Id", ~dataType=TextType, ~showSort=false, ())
  | MerchantId =>
    Table.makeHeaderInfo(~key, ~title="Merchant Id", ~dataType=TextType, ~showSort=false, ())
  | ConnectorTransactionId =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Connector Transaction Id",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | Connector =>
    Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType, ~showSort=false, ())
  | ConnectorRefundId =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Connector Refund Id",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | ExternalReferenceId =>
    Table.makeHeaderInfo(
      ~key,
      ~title="External Reference Id",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | RefundType =>
    Table.makeHeaderInfo(~key, ~title="Refund Type", ~dataType=TextType, ~showSort=false, ())
  | TotalAmount =>
    Table.makeHeaderInfo(~key, ~title="Total Amount", ~dataType=TextType, ~showSort=false, ())
  | Currency =>
    Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType, ~showSort=false, ())
  | RefundAmount =>
    Table.makeHeaderInfo(~key, ~title="Refund Amount", ~dataType=TextType, ~showSort=false, ())
  | Refundstatus =>
    Table.makeHeaderInfo(~key, ~title="Refund Status", ~dataType=TextType, ~showSort=false, ())
  | SentToGateway =>
    Table.makeHeaderInfo(~key, ~title="Sent To Gateway", ~dataType=TextType, ~showSort=false, ())
  | RefundErrorMessage =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Refund Error Message",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | RefundArn =>
    Table.makeHeaderInfo(~key, ~title="Refund Arn", ~dataType=TextType, ~showSort=false, ())
  | CreatedAt =>
    Table.makeHeaderInfo(~key, ~title="Created At", ~dataType=TextType, ~showSort=false, ())
  | ModifiedAt =>
    Table.makeHeaderInfo(~key, ~title="Modified At", ~dataType=TextType, ~showSort=false, ())
  | Description =>
    Table.makeHeaderInfo(~key, ~title="Description", ~dataType=TextType, ~showSort=false, ())
  | AttemptId =>
    Table.makeHeaderInfo(~key, ~title="Attempt Id", ~dataType=TextType, ~showSort=false, ())
  | RefundReason =>
    Table.makeHeaderInfo(~key, ~title="Refund Reason", ~dataType=TextType, ~showSort=false, ())
  | RefundErrorCode =>
    Table.makeHeaderInfo(~key, ~title="Refund Error Code", ~dataType=TextType, ~showSort=false, ())
  | SignFlag =>
    Table.makeHeaderInfo(~key, ~title="Sign Flag", ~dataType=TextType, ~showSort=false, ())
  | Timestamp =>
    Table.makeHeaderInfo(~key, ~title="Timestamp", ~dataType=TextType, ~showSort=false, ())
  }
}

let getCell = (refundsObj, colType): Table.cell => {
  let refundStatus = refundsObj.refund_status->HSwitchOrderUtils.statusVariantMapper

  switch colType {
  | InternalReferenceId => Text(refundsObj.internal_reference_id)
  | RefundId => Text(refundsObj.refund_id)
  | PaymentId => Text(refundsObj.payment_id)
  | MerchantId => Text(refundsObj.merchant_id)
  | ConnectorTransactionId => Text(refundsObj.connector_transaction_id)
  | Connector => Text(refundsObj.connector)
  | ConnectorRefundId => Text(refundsObj.connector_refund_id)
  | ExternalReferenceId => Text(refundsObj.external_reference_id)
  | RefundType => Text(refundsObj.refund_type)
  | TotalAmount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(refundsObj.total_amount /. 100.0)->Float.toString} currency={refundsObj.currency}
      />,
      "",
    )
  | Currency => Text(refundsObj.currency)
  | RefundAmount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(refundsObj.refund_amount /. 100.0)->Float.toString} currency={refundsObj.currency}
      />,
      "",
    )
  | Refundstatus =>
    Label({
      title: refundsObj.refund_status->String.toUpperCase,
      color: switch refundStatus {
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
  | SentToGateway => Text(refundsObj.sent_to_gateway->LogicUtils.getStringFromBool)
  | RefundErrorMessage => Text(refundsObj.refund_error_message)
  | RefundArn => Text(refundsObj.refund_arn)
  | CreatedAt => Text(refundsObj.created_at->Int.toString)
  | ModifiedAt => Text(refundsObj.modified_at->Int.toString)
  | Description => Text(refundsObj.description)
  | AttemptId => Text(refundsObj.attempt_id)
  | RefundReason => Text(refundsObj.refund_reason)
  | RefundErrorCode => Text(refundsObj.refund_error_code)
  | SignFlag => Text(refundsObj.sign_flag->Int.toString)
  | Timestamp => Text(refundsObj.timestamp)
  }
}

let tableEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects,
  ~dataKey="queryData",
  ~defaultColumns=visibleColumns,
  ~requiredSearchFieldsList=[],
  ~allColumns=visibleColumns,
  ~getCell,
  ~getHeading,
  ~getShowLink={refund => `/refunds/${refund.refund_id}`},
  (),
)
