open LogicUtils
open DisputeTypes

let defaultColumns = [DisputeId, Amount, DisputeStatus, PaymentId, CreatedAt]
let columnsInPaymentPage = [DisputeId, ConnectorReason, DisputeStatus, CreatedAt]

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
  DisputeStatus,
  PaymentId,
]

let useGetStatus = (dispute: disputes) => {
  open DisputesUtils
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
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
    <div className={`${fixedCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeading = colType => {
  switch colType {
  | DisputeId => Table.makeHeaderInfo(~key="dispute_id", ~title="Dispute Id")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment Id")
  | AttemptId => Table.makeHeaderInfo(~key="attempt_id", ~title="Attempt Id")
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | DisputeStatus =>
    Table.makeHeaderInfo(~key="dispute_status", ~title="Dispute Status", ~dataType=DropDown)
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector")
  | ConnectorStatus => Table.makeHeaderInfo(~key="connector_status", ~title="Connector Status")
  | ConnectorDisputeId =>
    Table.makeHeaderInfo(~key="connector_dispute_id", ~title="Connector Dispute Id")
  | ConnectorReason => Table.makeHeaderInfo(~key="connector_reason", ~title="Connector Reason")
  | ConnectorReasonCode =>
    Table.makeHeaderInfo(~key="connector_reason_code", ~title="Connector Reason Code")
  | ChallengeRequiredBy =>
    Table.makeHeaderInfo(~key="connector_required_by", ~title="Connector Required By")
  | ConnectorCreatedAt =>
    Table.makeHeaderInfo(~key="connector_created_at", ~title="Connector Created ")
  | ConnectorUpdatedAt =>
    Table.makeHeaderInfo(~key="connector_updated_at", ~title="Connector Updated ")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  }
}
let amountValue = (amount, currency) => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(currency)
  let amountInFloat = amount->Js.Float.fromString /. conversionFactor
  `${amountInFloat->Float.toString} ${currency}`
}

let getCell = (disputesData, colType, merchantId, orgId): Table.cell => {
  open DisputesUtils
  open HelperComponents
  switch colType {
  | DisputeId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/disputes/${disputesData.dispute_id}/${disputesData.profile_id}/${merchantId}/${orgId}`}
        displayValue={disputesData.dispute_id}
        copyValue={Some(disputesData.dispute_id)}
        showAlertIcon={disputesData.is_already_refunded}
      />,
      "",
    )
  | PaymentId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap" displayValue=Some(disputesData.payment_id)
      />,
      "",
    )
  | AttemptId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap" displayValue=Some(disputesData.attempt_id)
      />,
      "",
    )
  | Amount => Text(amountValue(disputesData.amount, disputesData.currency))
  | Currency => Text(disputesData.currency)
  | DisputeStatus =>
    Label({
      title: disputesData.dispute_status->String.toUpperCase,
      color: switch disputesData.dispute_status->disputeStatusVariantMapper {
      | DisputeOpened => LabelBlue
      | DisputeExpired => LabelRed
      | DisputeAccepted => LabelGreen
      | DisputeCancelled => LabelOrange
      | DisputeChallenged => LabelYellow
      | DisputeWon => LabelGreen
      | DisputeLost => LabelRed
      | _ => LabelLightGray
      },
    })
  | Connector => CustomCell(<ConnectorCustomCell connectorName={disputesData.connector} />, "")
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
    profile_id: dict->getString("profile_id", ""),
    dispute_id: dict->getString("dispute_id", ""),
    payment_id: dict->getString("payment_id", ""),
    attempt_id: dict->getString("attempt_id", ""),
    amount: dict->getString("amount", ""),
    currency: dict->getString("currency", ""),
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
    is_already_refunded: dict->getBool("is_already_refunded", false),
  }
}

let getDisputes: JSON.t => array<disputes> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let disputesEntity = (merchantId, orgId) =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=getDisputes,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell=(disputes, disputesColsType) => getCell(disputes, disputesColsType, merchantId, orgId),
    ~dataKey="",
    ~getShowLink={
      disputesData =>
        GlobalVars.appendDashboardPath(
          ~url=`/disputes/${disputesData.dispute_id}/${disputesData.profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
