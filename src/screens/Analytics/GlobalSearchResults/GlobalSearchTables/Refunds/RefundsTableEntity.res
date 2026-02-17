let domain = "refunds"

open LogicUtils
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
  created_at: float,
  modified_at: float,
  description: string,
  attempt_id: string,
  refund_reason: string,
  refund_error_code: string,
  sign_flag: int,
  timestamp: string,
  profile_id: string,
  organization_id: string,
  metadata: JSON.t,
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
  | RefundStatus
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
  | ProfileId
  | OrganizationId
  | Metadata

let visibleColumns = [
  RefundId,
  PaymentId,
  RefundStatus,
  TotalAmount,
  Currency,
  Connector,
  CreatedAt,
]

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
  | RefundStatus => "refund_status"
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
  | ProfileId => "profile_id"
  | OrganizationId => "organization_id"
  | Metadata => "metadata"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => refundsObject = dict => {


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
    refund_status: dict->getString(RefundStatus->colMapper, "NA"),
    sent_to_gateway: dict->getBool(SentToGateway->colMapper, false),
    refund_error_message: dict->getString(RefundErrorMessage->colMapper, "NA"),
    refund_arn: dict->getString(RefundArn->colMapper, "NA"),
    created_at: dict->getFloat(CreatedAt->colMapper, 0.0),
    modified_at: dict->getFloat(ModifiedAt->colMapper, 0.0),
    description: dict->getString(Description->colMapper, "NA"),
    attempt_id: dict->getString(AttemptId->colMapper, "NA"),
    refund_reason: dict->getString(RefundReason->colMapper, "NA"),
    refund_error_code: dict->getString(RefundErrorCode->colMapper, "NA"),
    sign_flag: dict->getInt(SignFlag->colMapper, 0),
    timestamp: dict->getString(Timestamp->colMapper, "NA"),
    profile_id: dict->getString(ProfileId->colMapper, "NA"),
    organization_id: dict->getString(OrganizationId->colMapper, "NA"),
    metadata: dict->getJsonObjectFromDict("metadata"),
  }
}

let getObjects: JSON.t => array<refundsObject> = json => {

  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | InternalReferenceId =>
    Table.makeHeaderInfo(~key, ~title="Internal Reference Id ", ~dataType=TextType)
  | RefundId => Table.makeHeaderInfo(~key, ~title="Refund Id", ~dataType=TextType)
  | PaymentId => Table.makeHeaderInfo(~key, ~title="Payment Id", ~dataType=TextType)
  | MerchantId => Table.makeHeaderInfo(~key, ~title="Merchant Id", ~dataType=TextType)
  | ConnectorTransactionId =>
    Table.makeHeaderInfo(~key, ~title="Connector Transaction Id", ~dataType=TextType)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType)
  | ConnectorRefundId =>
    Table.makeHeaderInfo(~key, ~title="Connector Refund Id", ~dataType=TextType)
  | ExternalReferenceId =>
    Table.makeHeaderInfo(~key, ~title="External Reference Id", ~dataType=TextType)
  | RefundType => Table.makeHeaderInfo(~key, ~title="Refund Type", ~dataType=TextType)
  | TotalAmount => Table.makeHeaderInfo(~key, ~title="Total Amount", ~dataType=TextType)
  | Currency => Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType)
  | RefundAmount => Table.makeHeaderInfo(~key, ~title="Refund Amount", ~dataType=TextType)
  | RefundStatus => Table.makeHeaderInfo(~key, ~title="Refund Status", ~dataType=TextType)
  | SentToGateway => Table.makeHeaderInfo(~key, ~title="Sent To Gateway", ~dataType=TextType)
  | RefundErrorMessage =>
    Table.makeHeaderInfo(~key, ~title="Refund Error Message", ~dataType=TextType)
  | RefundArn => Table.makeHeaderInfo(~key, ~title="Refund Arn", ~dataType=TextType)
  | CreatedAt => Table.makeHeaderInfo(~key, ~title="Created At", ~dataType=TextType)
  | ModifiedAt => Table.makeHeaderInfo(~key, ~title="Modified At", ~dataType=TextType)
  | Description => Table.makeHeaderInfo(~key, ~title="Description", ~dataType=TextType)
  | AttemptId => Table.makeHeaderInfo(~key, ~title="Attempt Id", ~dataType=TextType)
  | RefundReason => Table.makeHeaderInfo(~key, ~title="Refund Reason", ~dataType=TextType)
  | RefundErrorCode => Table.makeHeaderInfo(~key, ~title="Refund Error Code", ~dataType=TextType)
  | SignFlag => Table.makeHeaderInfo(~key, ~title="Sign Flag", ~dataType=TextType)
  | Timestamp => Table.makeHeaderInfo(~key, ~title="Timestamp", ~dataType=TextType)
  | ProfileId => Table.makeHeaderInfo(~key, ~title="Profile Id", ~dataType=TextType)
  | OrganizationId => Table.makeHeaderInfo(~key, ~title="Organization Id", ~dataType=TextType)
  | Metadata => Table.makeHeaderInfo(~key, ~title="Metadata", ~dataType=TextType)
  }
}

let getCell = (refundsObj: refundsObject, colType): Table.cell => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(refundsObj.currency)
  switch colType {
  | InternalReferenceId => Text(refundsObj.internal_reference_id)
  | RefundId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/refunds/${refundsObj.refund_id}/${refundsObj.profile_id}/${refundsObj.merchant_id}/${refundsObj.organization_id}`}
        displayValue={refundsObj.refund_id}
        copyValue={Some(refundsObj.refund_id)}
      />,
      refundsObj.refund_id,
    )
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
        amount={(refundsObj.total_amount /. conversionFactor)->Float.toString}
        currency={refundsObj.currency}
      />,
      (refundsObj.total_amount /. conversionFactor)->Float.toString,
    )
  | Currency => Text(refundsObj.currency)
  | RefundAmount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(refundsObj.refund_amount /. conversionFactor)->Float.toString}
        currency={refundsObj.currency}
      />,
      (refundsObj.refund_amount /. conversionFactor)->Float.toString,
    )
  | RefundStatus =>
    let refundStatus = refundsObj.refund_status->HSwitchOrderUtils.refundStatusVariantMapper
    Label({
      title: refundsObj.refund_status->String.toUpperCase,
      color: switch refundStatus {
      | Success => LabelGreen
      | Failure => LabelRed
      | Pending => LabelYellow
      | _ => LabelLightGray
      },
    })
  | SentToGateway => Text(refundsObj.sent_to_gateway->getStringFromBool)
  | RefundErrorMessage => Text(refundsObj.refund_error_message)
  | RefundArn => Text(refundsObj.refund_arn)
  | CreatedAt => Date(refundsObj.created_at->DateTimeUtils.unixToISOString)
  | ModifiedAt => Date(refundsObj.modified_at->DateTimeUtils.unixToISOString)
  | Description => Text(refundsObj.description)
  | AttemptId => Text(refundsObj.attempt_id)
  | RefundReason => Text(refundsObj.refund_reason)
  | RefundErrorCode => Text(refundsObj.refund_error_code)
  | SignFlag => Text(refundsObj.sign_flag->Int.toString)
  | Timestamp => Date(refundsObj.timestamp)
  | ProfileId => Text(refundsObj.profile_id)
  | OrganizationId => Text(refundsObj.organization_id)
  | Metadata => Text(refundsObj.metadata->JSON.stringify)
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
  ~getShowLink={
    refund =>
      GlobalVars.appendDashboardPath(
        ~url=`/refunds/${refund.refund_id}/${refund.profile_id}/${refund.merchant_id}/${refund.organization_id}`,
      )
  },
)

let getColFromKey = (key: string): option<cols> => {
  switch key {
  | "internal_reference_id" => Some(InternalReferenceId)
  | "refund_id" => Some(RefundId)
  | "payment_id" => Some(PaymentId)
  | "merchant_id" => Some(MerchantId)
  | "connector_transaction_id" => Some(ConnectorTransactionId)
  | "connector" => Some(Connector)
  | "total_amount" => Some(TotalAmount)
  | "currency" => Some(Currency)
  | "refund_amount" => Some(RefundAmount)
  | "refund_status" => Some(RefundStatus)
  | "connector_refund_id" => Some(ConnectorRefundId)
  | "external_reference_id" => Some(ExternalReferenceId)
  | "refund_reason" => Some(RefundReason)
  | "refund_type" => Some(RefundType)
  | "sent_to_gateway" => Some(SentToGateway)
  | "refund_error_message" => Some(RefundErrorMessage)
  | "metadata" => Some(Metadata)
  | "created_at" => Some(CreatedAt)
  | "modified_at" => Some(ModifiedAt)
  | "description" => Some(Description)
  | "attempt_id" => Some(AttemptId)
  | "refund_error_code" => Some(RefundErrorCode)
  | "profile_id" => Some(ProfileId)
  | _ => None
  }
}

let allColumns = [
  InternalReferenceId,
  RefundId,
  PaymentId,
  MerchantId,
  ConnectorTransactionId,
  Connector,
  TotalAmount,
  Currency,
  RefundAmount,
  RefundStatus,
  ConnectorRefundId,
  ExternalReferenceId,
  RefundReason,
  RefundType,
  SentToGateway,
  RefundErrorMessage,
  Metadata,
  CreatedAt,
  ModifiedAt,
  Description,
  AttemptId,
  RefundErrorCode,
  ProfileId,
]

let csvHeaders = allColumns->Array.map(col => {
  let {key, title} = col->getHeading
  (key, title)
})

let itemToCSVMapping = (obj: refundsObject): JSON.t => {
  allColumns
  ->Array.reduce(Dict.make(), (dict, col) => {
    let {key} = col->getHeading
    let value = obj->getCell(col)->TableUtils.getTableCellValue
    dict->Dict.set(key, value->JSON.Encode.string)
    dict
  })
  ->JSON.Encode.object
}
