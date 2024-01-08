open LogicUtils

type disputes = {
  dispute_id: string,
  payment_id: string,
  attempt_id: string,
  amount: string,
  currency: string,
  dispute_stage: string,
  dispute_status: string,
  connector: string,
  connector_status: string,
  connector_dispute_id: string,
  connector_reason: string,
  connector_reason_code: string,
  challenge_required_by: string,
  connector_created_at: string,
  connector_updated_at: string,
  created_at: string,
}

type disputesColsType =
  | DisputeId
  | PaymentId
  | AttemptId
  | Amount
  | Currency
  | DisputeStage
  | DisputeStatus
  | Connector
  | ConnectorStatus
  | ConnectorDisputeId
  | ConnectorReason
  | ConnectorReasonCode
  | ChallengeRequiredBy
  | ConnectorCreatedAt
  | ConnectorUpdatedAt
  | CreatedAt

let defaultColumns = [DisputeId, Amount, DisputeStage, DisputeStatus, PaymentId, CreatedAt]
let columnsInPaymentPage = [DisputeId, DisputeStage, ConnectorReason, DisputeStatus, CreatedAt]

let disputesMapDefaultCols = Recoil.atom(. "disputesMapDefaultCols", defaultColumns)

let allColumns = [
  Amount,
  AttemptId,
  ChallengeRequiredBy,
  Connector,
  ConnectorCreatedAt,
  ConnectorDisputeId,
  ConnectorReason,
  ConnectorReasonCode,
  ConnectorStatus,
  ConnectorUpdatedAt,
  CreatedAt,
  Currency,
  DisputeId,
  DisputeStage,
  DisputeStatus,
  PaymentId,
]

let getStatus = dispute => {
  open DisputesUtils
  let orderStatusLabel = dispute.dispute_status->String.toUpperCase
  let fixedCss = "text-sm text-white font-bold p-1.5 rounded-lg"
  switch dispute.dispute_status->disputeStatusVariantMapper {
  | DisputeAccepted
  | DisputeWon =>
    <div className={`${fixedCss} bg-hyperswitch_green dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | DisputeExpired
  | DisputeLost =>
    <div className={`${fixedCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | DisputeOpened
  | DisputeCancelled
  | DisputeChallenged =>
    <div className={`${fixedCss} bg-blue-800 bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedCss} bg-blue-800 bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeading = colType => {
  switch colType {
  | DisputeId => Table.makeHeaderInfo(~key="dispute_id", ~title="Dispute Id", ~showSort=true, ())
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment Id", ~showSort=true, ())
  | AttemptId => Table.makeHeaderInfo(~key="attempt_id", ~title="Attempt Id", ~showSort=true, ())
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=true, ())
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency", ~showSort=true, ())
  | DisputeStage =>
    Table.makeHeaderInfo(
      ~key="dispute_stage",
      ~title="Dispute Stage",
      ~dataType=DropDown,
      ~showSort=true,
      (),
    )
  | DisputeStatus =>
    Table.makeHeaderInfo(
      ~key="dispute_status",
      ~title="Dispute Status",
      ~dataType=DropDown,
      ~showSort=true,
      (),
    )
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector", ~showSort=true, ())
  | ConnectorStatus =>
    Table.makeHeaderInfo(~key="connector_status", ~title="Connector Status", ~showSort=true, ())
  | ConnectorDisputeId =>
    Table.makeHeaderInfo(
      ~key="connector_dispute_id",
      ~title="Connector Dispute Id",
      ~showSort=true,
      (),
    )
  | ConnectorReason =>
    Table.makeHeaderInfo(~key="connector_reason", ~title="Connector Reason", ~showSort=true, ())
  | ConnectorReasonCode =>
    Table.makeHeaderInfo(
      ~key="connector_reason_code",
      ~title="Connector Reason Code",
      ~showSort=true,
      (),
    )
  | ChallengeRequiredBy =>
    Table.makeHeaderInfo(
      ~key="connector_required_by",
      ~title="Connector Required By",
      ~showSort=true,
      (),
    )
  | ConnectorCreatedAt =>
    Table.makeHeaderInfo(
      ~key="connector_created_at",
      ~title="Connector Created ",
      ~showSort=true,
      (),
    )
  | ConnectorUpdatedAt =>
    Table.makeHeaderInfo(
      ~key="connector_updated_at",
      ~title="Connector Updated ",
      ~showSort=true,
      (),
    )
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created", ~showSort=true, ())
  }
}
let amountValue = (amount, currency) => {
  let amountInFloat = amount->Js.Float.fromString /. 100.0
  `${amountInFloat->Belt.Float.toString} ${currency}`
}

let getCell = (disputesData, colType): Table.cell => {
  open DisputesUtils
  switch colType {
  | DisputeId =>
    CustomCell(<HelperComponents.CopyTextCustomComp displayValue=disputesData.dispute_id />, "")
  | PaymentId =>
    CustomCell(<HelperComponents.CopyTextCustomComp displayValue=disputesData.payment_id />, "")
  | AttemptId =>
    CustomCell(<HelperComponents.CopyTextCustomComp displayValue=disputesData.attempt_id />, "")
  | Amount => Text(amountValue(disputesData.amount, disputesData.currency))
  | Currency => Text(disputesData.currency)
  | DisputeStage =>
    Label({
      title: disputesData.dispute_stage->String.toUpperCase,
      color: switch disputesData.dispute_stage->disputeStageVariantMapper {
      | PreDispute => LabelOrange
      | Dispute => LabelGreen
      | PreArbitration => LabelYellow
      | _ => LabelWhite
      },
    })
  | DisputeStatus =>
    Label({
      title: disputesData.dispute_status->String.toUpperCase,
      color: switch disputesData.dispute_status->disputeStatusVariantMapper {
      | DisputeOpened => LabelLightBlue
      | DisputeExpired => LabelRed
      | DisputeAccepted => LabelGreen
      | DisputeCancelled => LabelOrange
      | DisputeChallenged => LabelYellow
      | DisputeWon => LabelGreen
      | DisputeLost => LabelRed
      | _ => LabelWhite
      },
    })
  | Connector => Text(disputesData.connector)
  | ConnectorStatus => Text(disputesData.connector_status)
  | ConnectorDisputeId => Text(disputesData.connector_dispute_id)
  | ConnectorReason => Text(disputesData.connector_reason)
  | ConnectorReasonCode => Text(disputesData.connector_reason_code)
  | ChallengeRequiredBy => Date(disputesData.challenge_required_by)
  | ConnectorCreatedAt => Date(disputesData.connector_created_at)
  | ConnectorUpdatedAt => Date(disputesData.connector_updated_at)
  | CreatedAt => Date(disputesData.created_at)
  }
}

let itemToObjMapper = dict => {
  {
    dispute_id: dict->getString("dispute_id", ""),
    payment_id: dict->getString("payment_id", ""),
    attempt_id: dict->getString("attempt_id", ""),
    amount: dict->getString("amount", ""),
    currency: dict->getString("currency", ""),
    dispute_stage: dict->getString("dispute_stage", ""),
    dispute_status: dict->getString("dispute_status", ""),
    connector: dict->getString("connector", ""),
    connector_status: dict->getString("connector_status", ""),
    connector_dispute_id: dict->getString("connector_dispute_id", ""),
    connector_reason: dict->getString("connector_reason", ""),
    connector_reason_code: dict->getString("connector_reason_code", ""),
    challenge_required_by: dict->getString("challenge_required_by", ""),
    connector_created_at: dict->getString("connector_created_at", ""),
    connector_updated_at: dict->getString("connector_updated_at", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let getDisputes: Js.Json.t => array<disputes> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let disputesEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getDisputes,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~getCell,
  ~dataKey="",
  ~getShowLink={disputesData => `/disputes/${disputesData.dispute_id}`},
  (),
)
