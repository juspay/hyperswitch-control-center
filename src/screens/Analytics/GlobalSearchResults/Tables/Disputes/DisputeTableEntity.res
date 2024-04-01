type disputesObject = {
  dispute_id: string,
  dispute_amount: float,
  currency: string,
  dispute_stage: string,
  dispute_status: string,
  payment_id: string,
  attempt_id: string,
  merchant_id: string,
  connector_status: string,
  connector_dispute_id: string,
  connector_reason: string,
  connector_reason_code: int,
  challenge_required_by: int,
  connector_created_at: int,
  connector_updated_at: int,
  created_at: int,
  modified_at: int,
  connector: string,
  evidence: string,
  profile_id: string,
  merchant_connector_id: string,
  sign_flag: int,
  timestamp: string,
}

type cols =
  | DisputeId
  | DisputeAmount
  | Currency
  | DisputeStage
  | DisputeStatus
  | PaymentId
  | AttemptId
  | MerchantId
  | ConnectorStatus
  | ConnectorDisputeId
  | ConnectorReason
  | ConnectorReasonCode
  | ChallengeRequiredBy
  | ConnectorCreatedAt
  | ConnectorUpdatedAt
  | CreatedAt
  | ModifiedAt
  | Connector
  | Evidence
  | ProfileId
  | MerchantConnectorId
  | SignFlag
  | Timestamp

let visibleColumns = [DisputeId, PaymentId, Connector, DisputeAmount, Currency, DisputeStatus]

let colMapper = (col: cols) => {
  switch col {
  | DisputeId => "dispute_id"
  | DisputeAmount => "dispute_amount"
  | Currency => "currency"
  | DisputeStage => "dispute_stage"
  | DisputeStatus => "dispute_status"
  | PaymentId => "payment_id"
  | AttemptId => "attempt_id"
  | MerchantId => "merchant_id"
  | ConnectorStatus => "connector_status"
  | ConnectorDisputeId => "connector_dispute_id"
  | ConnectorReason => "connector_reason"
  | ConnectorReasonCode => "connector_reason_code"
  | ChallengeRequiredBy => "challenge_required_by"
  | ConnectorCreatedAt => "connector_created_at"
  | ConnectorUpdatedAt => "connector_updated_at"
  | CreatedAt => "created_at"
  | ModifiedAt => "modified_at"
  | Connector => "connector"
  | Evidence => "evidence"
  | ProfileId => "profile_id"
  | MerchantConnectorId => "merchant_connector_id"
  | SignFlag => "sign_flag"
  | Timestamp => "timestamp"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => disputesObject = dict => {
  open LogicUtils
  {
    dispute_id: dict->getString(DisputeId->colMapper, "NA"),
    dispute_amount: dict->getFloat(DisputeAmount->colMapper, 0.0),
    currency: dict->getString(Currency->colMapper, "NA"),
    dispute_stage: dict->getString(DisputeStage->colMapper, "NA"),
    dispute_status: dict->getString(DisputeStatus->colMapper, "NA"),
    payment_id: dict->getString(PaymentId->colMapper, "NA"),
    attempt_id: dict->getString(AttemptId->colMapper, "NA"),
    merchant_id: dict->getString(MerchantId->colMapper, "NA"),
    connector_status: dict->getString(ConnectorStatus->colMapper, "NA"),
    connector_dispute_id: dict->getString(ConnectorDisputeId->colMapper, "NA"),
    connector_reason: dict->getString(ConnectorReason->colMapper, "NA"),
    connector_reason_code: dict->getInt(ConnectorReasonCode->colMapper, 0),
    challenge_required_by: dict->getInt(ChallengeRequiredBy->colMapper, 0),
    connector_created_at: dict->getInt(ConnectorCreatedAt->colMapper, 0),
    connector_updated_at: dict->getInt(ConnectorUpdatedAt->colMapper, 0),
    created_at: dict->getInt(CreatedAt->colMapper, 0),
    modified_at: dict->getInt(ModifiedAt->colMapper, 0),
    connector: dict->getString(Connector->colMapper, "NA"),
    evidence: dict->getString(Evidence->colMapper, "NA"),
    profile_id: dict->getString(ProfileId->colMapper, "NA"),
    merchant_connector_id: dict->getString(MerchantConnectorId->colMapper, "NA"),
    sign_flag: dict->getInt(SignFlag->colMapper, 0),
    timestamp: dict->getString(Timestamp->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<disputesObject> = json => {
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
  | DisputeId =>
    Table.makeHeaderInfo(~key, ~title="Dispute Id", ~dataType=TextType, ~showSort=false, ())
  | DisputeAmount =>
    Table.makeHeaderInfo(~key, ~title="Dispute Amount", ~dataType=TextType, ~showSort=false, ())
  | Currency =>
    Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType, ~showSort=false, ())
  | DisputeStage =>
    Table.makeHeaderInfo(~key, ~title="Dispute Stage", ~dataType=TextType, ~showSort=false, ())
  | DisputeStatus =>
    Table.makeHeaderInfo(~key, ~title="Dispute Status", ~dataType=TextType, ~showSort=false, ())
  | PaymentId =>
    Table.makeHeaderInfo(~key, ~title="Payment Id", ~dataType=TextType, ~showSort=false, ())
  | AttemptId =>
    Table.makeHeaderInfo(~key, ~title="Attempt Id", ~dataType=TextType, ~showSort=false, ())
  | MerchantId =>
    Table.makeHeaderInfo(~key, ~title="Merchant Id", ~dataType=TextType, ~showSort=false, ())
  | ConnectorStatus =>
    Table.makeHeaderInfo(~key, ~title="Connector Status", ~dataType=TextType, ~showSort=false, ())
  | ConnectorDisputeId =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Connector Dispute Id",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | ConnectorReason =>
    Table.makeHeaderInfo(~key, ~title="Connector Reason", ~dataType=TextType, ~showSort=false, ())
  | ConnectorReasonCode =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Connector Reason Code",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | ChallengeRequiredBy =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Challenge Required By",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | ConnectorCreatedAt =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Connector Created At",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | ConnectorUpdatedAt =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Connector Updated At",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | CreatedAt =>
    Table.makeHeaderInfo(~key, ~title="Created At", ~dataType=TextType, ~showSort=false, ())
  | ModifiedAt =>
    Table.makeHeaderInfo(~key, ~title="Modified At", ~dataType=TextType, ~showSort=false, ())
  | Connector =>
    Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType, ~showSort=false, ())
  | Evidence =>
    Table.makeHeaderInfo(~key, ~title="Evidence", ~dataType=TextType, ~showSort=false, ())
  | ProfileId =>
    Table.makeHeaderInfo(~key, ~title="Profile Id", ~dataType=TextType, ~showSort=false, ())
  | MerchantConnectorId =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Merchant Connector Id",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | SignFlag =>
    Table.makeHeaderInfo(~key, ~title="Sign Flag", ~dataType=TextType, ~showSort=false, ())
  | Timestamp =>
    Table.makeHeaderInfo(~key, ~title="Timestamp", ~dataType=TextType, ~showSort=false, ())
  }
}

let getCell = (disputeObj, colType): Table.cell => {
  let disputeStatus = disputeObj.dispute_status->HSwitchOrderUtils.statusVariantMapper

  switch colType {
  | DisputeId => Text(disputeObj.dispute_id)
  | DisputeAmount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(disputeObj.dispute_amount /. 100.0)->Float.toString} currency={disputeObj.currency}
      />,
      "",
    )
  | Currency => Text(disputeObj.currency)
  | DisputeStage => Text(disputeObj.dispute_stage)
  | DisputeStatus =>
    Label({
      title: disputeObj.dispute_status->String.toUpperCase,
      color: switch disputeStatus {
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
  | PaymentId => Text(disputeObj.payment_id)
  | AttemptId => Text(disputeObj.attempt_id)
  | MerchantId => Text(disputeObj.merchant_id)
  | ConnectorStatus => Text(disputeObj.connector_status)
  | ConnectorDisputeId => Text(disputeObj.connector_dispute_id)
  | ConnectorReason => Text(disputeObj.connector_reason)
  | ConnectorReasonCode => Text(disputeObj.connector_reason_code->Int.toString)
  | ChallengeRequiredBy => Text(disputeObj.challenge_required_by->Int.toString)
  | ConnectorCreatedAt => Text(disputeObj.connector_created_at->Int.toString)
  | ConnectorUpdatedAt => Text(disputeObj.connector_updated_at->Int.toString)
  | CreatedAt => Text(disputeObj.created_at->Int.toString)
  | ModifiedAt => Text(disputeObj.modified_at->Int.toString)
  | Connector => Text(disputeObj.connector)
  | Evidence => Text(disputeObj.evidence)
  | ProfileId => Text(disputeObj.profile_id)
  | MerchantConnectorId => Text(disputeObj.merchant_connector_id)
  | SignFlag => Text(disputeObj.sign_flag->Int.toString)
  | Timestamp => Text(disputeObj.timestamp)
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
  ~getShowLink={dispute => `/disputes/${dispute.dispute_id}`},
  (),
)
