open LogicUtils
open HelperComponents
open HSwitchOrderUtils

type refunds = {
  refund_id: string,
  payment_id: string,
  amount: float,
  currency: string,
  reason: string,
  status: string,
  metadata: string,
  updated_at: string,
  created_at: string,
  error_message: string,
  error_code: string,
  connector: string,
}

type refundsColType =
  | Amount
  | Created
  | Currency
  | ErrorCode
  | ErrorMessage
  | PaymentId
  | RefundReason
  | RefundId
  | RefundStatus
  | LastUpdated
  | MetaData
  | ConnectorName

let defaultColumns = [RefundId, Amount, RefundStatus, PaymentId, Created]

let refundsMapDefaultCols = Recoil.atom(. "refundsMapDefaultCols", defaultColumns)

let allColumns = [
  Amount,
  ConnectorName,
  Created,
  Currency,
  ErrorCode,
  ErrorMessage,
  LastUpdated,
  MetaData,
  PaymentId,
  RefundId,
  RefundReason,
  RefundStatus,
]

let getStatus = order => {
  let orderStatusLabel = order.status->String.toUpperCase
  let fixedCss = "text-sm text-white font-bold p-1.5 rounded-lg"
  switch order.status->statusVariantMapper {
  | Succeeded =>
    <div className={`${fixedCss} bg-hyperswitch_green dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Failed
  | Cancelled =>
    <div className={`${fixedCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Processing
  | RequiresCustomerAction
  | RequiresPaymentMethod =>
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
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount", ~showSort=false, ())
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created", ~showSort=false, ())
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency", ~showSort=false, ())
  | LastUpdated =>
    Table.makeHeaderInfo(~key="last_updated", ~title="Last Updated", ~showSort=false, ())
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID", ~showSort=false, ())
  | RefundId => Table.makeHeaderInfo(~key="refund_id", ~title="Refund ID", ~showSort=false, ())
  | RefundReason => Table.makeHeaderInfo(~key="reason", ~title="Refund Reason", ~showSort=false, ())
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code", ~showSort=false, ())
  | ErrorMessage =>
    Table.makeHeaderInfo(~key="error_message", ~title="Error Message", ~showSort=false, ())
  | RefundStatus =>
    Table.makeHeaderInfo(
      ~key="status",
      ~title="Refund Status",
      ~dataType=DropDown,
      ~showSort=false,
      (),
    )
  | MetaData =>
    Table.makeHeaderInfo(
      ~key="metaData",
      ~title="MetaData",
      ~dataType=DropDown,
      ~showSort=false,
      (),
    )
  | ConnectorName => Table.makeHeaderInfo(~key="connector", ~title="Connector", ~showSort=false, ())
  }
}

let getCell = (refundData, colType): Table.cell => {
  switch colType {
  | Amount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(refundData.amount /. 100.0)->Belt.Float.toString} currency={refundData.currency}
      />,
      "",
    )
  | Created => Date(refundData.created_at)
  | Currency => Text(refundData.currency)
  | ErrorCode => Text(refundData.error_code)
  | ErrorMessage => Text(refundData.error_message)
  | PaymentId => CustomCell(<CopyTextCustomComp displayValue=refundData.payment_id />, "")
  | RefundReason => Text(refundData.reason)
  | RefundId => CustomCell(<CopyTextCustomComp displayValue=refundData.refund_id />, "")
  | RefundStatus =>
    Label({
      title: refundData.status->String.toUpperCase,
      color: switch refundData.status->statusVariantMapper {
      | Succeeded => LabelGreen
      | Failed => LabelRed
      | Processing => LabelOrange
      | Cancelled => LabelRed
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelWhite
      | _ => LabelLightBlue
      },
    })
  | LastUpdated => Date(refundData.updated_at)
  | MetaData => Text(refundData.metadata)
  | ConnectorName =>
    CustomCell(<HSwitchUtils.ConnectorCustomCell connectorName=refundData.connector />, "")
  }
}

let itemToObjMapper = dict => {
  {
    amount: getFloat(dict, "amount", 0.0),
    created_at: getString(dict, "created_at", ""),
    currency: getString(dict, "currency", ""),
    error_message: getString(dict, "error_message", ""),
    metadata: getString(dict, "metadata", ""),
    payment_id: getString(dict, "payment_id", ""),
    reason: getString(dict, "reason", ""),
    refund_id: getString(dict, "refund_id", ""),
    status: getString(dict, "status", ""),
    updated_at: getString(dict, "updated_at", ""),
    error_code: getString(dict, "error_code", ""),
    connector: getString(dict, "connector", ""),
  }
}

let getRefunds: Js.Json.t => array<refunds> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let refundEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getRefunds,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~getCell,
  ~dataKey="",
  ~getShowLink={refundData => `/refunds/${refundData.refund_id}`},
  (),
)
